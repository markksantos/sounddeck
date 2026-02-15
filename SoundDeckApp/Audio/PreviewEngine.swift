import AVFoundation
import CoreAudio
import AudioToolbox
import os.log

/// A separate audio engine for local audio monitoring through headphones.
///
/// Routes audio to the selected output device only — never through the
/// virtual microphone. Supports three independent playback paths:
///
/// - **Preview**: Long-press preview of a single sound (existing behavior)
/// - **SFX Monitor**: Pool of players for hearing SFX locally during calls
/// - **Voice Monitor**: Dedicated player for hearing your own mic
///
/// All nodes mix into `engine.mainMixerNode → engine.outputNode`.
final class PreviewEngine {
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "PreviewEngine")

    private let engine = AVAudioEngine()

    // Shared format for all monitoring playback (48 kHz mono)
    private let monitorFormat: AVAudioFormat

    // -- Preview (existing long-press behavior) --
    private let previewPlayerNode = AVAudioPlayerNode()

    // -- SFX Monitor (pool of concurrent players) --
    private static let sfxPoolSize = 4
    private var sfxPlayerNodes: [AVAudioPlayerNode] = []
    private var sfxAssignment: [Int: UUID] = [:]  // playerIndex → soundID
    private let sfxQueue = DispatchQueue(label: "com.sounddeck.previewengine.sfx")

    // -- Voice Monitor --
    private let voiceMonitorNode = AVAudioPlayerNode()

    /// The AudioDeviceID of the output device to route preview audio to.
    /// Set this before calling preview() to route to headphones.
    var outputDeviceID: AudioObjectID? {
        didSet {
            if let deviceID = outputDeviceID {
                setOutputDevice(deviceID)
            }
        }
    }

    private var isSetUp = false

    init() {
        self.monitorFormat = AVAudioFormat(
            standardFormatWithSampleRate: 48000.0,
            channels: 1
        )!
        setup()
    }

    // MARK: - Setup

    private func setup() {
        let mixer = engine.mainMixerNode

        // Preview player (existing)
        engine.attach(previewPlayerNode)
        engine.connect(previewPlayerNode, to: mixer, format: monitorFormat)

        // SFX monitor pool
        for _ in 0..<Self.sfxPoolSize {
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: mixer, format: monitorFormat)
            sfxPlayerNodes.append(node)
        }

        // Voice monitor player
        engine.attach(voiceMonitorNode)
        engine.connect(voiceMonitorNode, to: mixer, format: monitorFormat)

        engine.connect(mixer, to: engine.outputNode, format: monitorFormat)
        engine.prepare()
        isSetUp = true
    }

    // MARK: - Output Device

    private func setOutputDevice(_ deviceID: AudioObjectID) {
        let outputNode = engine.outputNode
        guard let audioUnit = outputNode.audioUnit else {
            logger.error("Output node has no audio unit, cannot set device")
            return
        }

        var deviceIDVar = deviceID
        let status = AudioUnitSetProperty(
            audioUnit,
            kAudioOutputUnitProperty_CurrentDevice,
            kAudioUnitScope_Global,
            0,
            &deviceIDVar,
            UInt32(MemoryLayout<AudioObjectID>.size)
        )

        if status != noErr {
            logger.error("Failed to set preview output device: \(status)")
        } else {
            logger.info("Preview output device set to \(deviceID)")
        }
    }

    // MARK: - Engine Lifecycle

    /// Starts the engine if it isn't already running.
    func ensureRunning() {
        guard isSetUp, !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            logger.error("Failed to start preview engine: \(error.localizedDescription)")
        }
    }

    // MARK: - Preview (long-press)

    /// Previews a sound through the output device (headphones).
    /// This does NOT route through the virtual microphone.
    func preview(sound: SoundItem) {
        let fileURL = sound.fileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            logger.warning("Preview file not found: \(fileURL.path)")
            return
        }

        do {
            let audioFile = try AVAudioFile(forReading: fileURL)
            let fileFormat = audioFile.processingFormat
            let totalFrames = AVAudioFrameCount(audioFile.length)

            guard totalFrames > 0 else {
                logger.warning("Preview file is empty: \(sound.name)")
                return
            }

            // Apply trim
            let sampleRate = fileFormat.sampleRate
            let trimStartFrame = AVAudioFramePosition(sound.trimStart * sampleRate)
            let trimEndFrame: AVAudioFramePosition
            if sound.trimEnd > 0 {
                trimEndFrame = AVAudioFramePosition(sound.trimEnd * sampleRate)
            } else {
                trimEndFrame = AVAudioFramePosition(totalFrames)
            }

            let effectiveStart = max(0, min(trimStartFrame, AVAudioFramePosition(totalFrames)))
            let effectiveEnd = max(effectiveStart, min(trimEndFrame, AVAudioFramePosition(totalFrames)))
            let frameCount = AVAudioFrameCount(effectiveEnd - effectiveStart)

            guard frameCount > 0 else { return }

            audioFile.framePosition = effectiveStart

            guard let buffer = AVAudioPCMBuffer(pcmFormat: fileFormat, frameCapacity: frameCount) else {
                logger.error("Failed to create preview buffer")
                return
            }
            try audioFile.read(into: buffer, frameCount: frameCount)

            // Stop any currently previewing sound
            previewPlayerNode.stop()

            // Reconnect with the file's format if different
            engine.disconnectNodeOutput(previewPlayerNode)
            engine.connect(previewPlayerNode, to: engine.mainMixerNode, format: fileFormat)

            ensureRunning()

            // Set volume
            previewPlayerNode.volume = sound.volume

            // Schedule and play
            previewPlayerNode.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
                self?.logger.info("Preview finished: \(sound.name)")
            }
            previewPlayerNode.play()

            logger.info("Previewing: \(sound.name)")
        } catch {
            logger.error("Preview failed for \(sound.name): \(error.localizedDescription)")
        }
    }

    /// Stops the currently previewing sound.
    func stopPreview() {
        previewPlayerNode.stop()
    }

    // MARK: - SFX Monitor

    /// Plays a preloaded SFX buffer through the monitor output for local listening.
    func playSFXMonitor(buffer: AVAudioPCMBuffer, soundID: UUID, volume: Float) {
        ensureRunning()

        sfxQueue.sync {
            guard let index = findAvailableSFXPlayer() else {
                logger.warning("All SFX monitor players busy, cannot play \(soundID)")
                return
            }

            let player = sfxPlayerNodes[index]
            sfxAssignment[index] = soundID
            player.volume = volume

            player.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
                self?.sfxQueue.sync {
                    if self?.sfxAssignment[index] == soundID {
                        self?.sfxAssignment.removeValue(forKey: index)
                    }
                }
            }
            player.play()
        }
    }

    /// Stops SFX monitor playback for a specific sound.
    func stopSFXMonitor(soundID: UUID) {
        sfxQueue.sync {
            for (index, assignedID) in sfxAssignment where assignedID == soundID {
                sfxPlayerNodes[index].stop()
                sfxAssignment.removeValue(forKey: index)
            }
        }
    }

    /// Stops all SFX monitor playback.
    func stopAllSFXMonitor() {
        sfxQueue.sync {
            for (index, _) in sfxAssignment {
                sfxPlayerNodes[index].stop()
            }
            sfxAssignment.removeAll()
        }
    }

    private func findAvailableSFXPlayer() -> Int? {
        for i in 0..<sfxPlayerNodes.count {
            if sfxAssignment[i] == nil {
                return i
            }
        }
        return nil
    }

    // MARK: - Voice Monitor

    /// Schedules a voice buffer for local playback through headphones.
    func scheduleVoiceMonitorBuffer(_ buffer: AVAudioPCMBuffer) {
        ensureRunning()
        voiceMonitorNode.scheduleBuffer(buffer, at: nil, options: [])
        if !voiceMonitorNode.isPlaying {
            voiceMonitorNode.play()
        }
    }

    /// Stops voice monitor playback.
    func stopVoiceMonitor() {
        voiceMonitorNode.stop()
    }

    deinit {
        engine.stop()
    }
}
