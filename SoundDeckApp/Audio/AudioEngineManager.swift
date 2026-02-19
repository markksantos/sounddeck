import AVFoundation
import Combine
import os.log
import SoundDeckCommon

/// Manages the main AVAudioEngine graph for microphone pass-through,
/// voice changing, SFX mixing, and writing the final mix to shared memory
/// for the virtual microphone driver.
///
/// Audio Graph:
///   InputNode → AVAudioUnitTimePitch (voice changer) → mainMixerNode
///   sfxMixerNode → mainMixerNode
///   mainMixerNode → AVAudioSinkNode (writes to SharedMemoryWriter)
///
/// A metering tap on mainMixerNode provides RMS levels for the VU meter.
final class AudioEngineManager {
    private let appState: AppState
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "AudioEngine")

    // Audio engine & nodes
    private let engine = AVAudioEngine()
    private let pitchUnit = AVAudioUnitTimePitch()
    private let sfxMixerNode = AVAudioMixerNode()
    private var sinkNode: AVAudioSinkNode?

    // Shared memory IPC
    let sharedMemoryWriter = SharedMemoryWriter()

    // Sound player pool (attached to sfxMixerNode)
    private(set) var soundPlayer: SoundPlayer?

    // Voice changer wrapper
    private(set) var voiceChanger: VoiceChanger!

    // Preview engine for local monitoring (SFX + voice)
    weak var previewEngine: PreviewEngine?

    // Metering
    private let meteringSampleCount: Int = 1024
    private var cancellables = Set<AnyCancellable>()

    // Target format for the shared memory output
    private let outputFormat: AVAudioFormat

    // Format converter for sample rate mismatch
    private var formatConverter: AVAudioConverter?

    // Pre-allocated buffers for RT-safe format conversion
    private var preAllocatedOutputBuffer: AVAudioPCMBuffer?
    private var preAllocatedInputBuffer: AVAudioPCMBuffer?

    init(appState: AppState) {
        self.appState = appState
        self.outputFormat = AVAudioFormat(
            standardFormatWithSampleRate: kSoundDeckSampleRate,
            channels: AVAudioChannelCount(kSoundDeckChannelCount)
        )!
        self.voiceChanger = VoiceChanger(pitchUnit: pitchUnit)

        setupNotifications()
        observeAppState()
    }

    // MARK: - Engine Lifecycle

    func start() {
        guard !engine.isRunning else {
            logger.info("Engine already running")
            return
        }

        // Open shared memory
        guard sharedMemoryWriter.open() else {
            logger.error("Failed to open shared memory, cannot start engine")
            return
        }

        do {
            try buildGraph()
            try engine.start()
            DispatchQueue.main.async {
                self.appState.isEngineRunning = true
            }
            logger.info("Audio engine started")
        } catch {
            logger.error("Failed to start audio engine: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.appState.isEngineRunning = false
            }
        }
    }

    func stop() {
        soundPlayer?.stopAll()
        soundPlayer = nil
        engine.stop()
        removeMeteringTap()
        removeVoiceMonitorTap()
        sharedMemoryWriter.cleanup()
        DispatchQueue.main.async {
            self.appState.isEngineRunning = false
            self.appState.inputLevel = 0.0
        }
        logger.info("Audio engine stopped")
    }

    // MARK: - Graph Construction

    private func buildGraph() throws {
        // Remove existing taps before resetting (safe to call if no tap installed)
        removeMeteringTap()
        removeVoiceMonitorTap()

        // Reset any previous configuration
        engine.reset()

        let inputNode = engine.inputNode
        let mainMixer = engine.mainMixerNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        logger.info("Input device format: \(inputFormat.sampleRate) Hz, \(inputFormat.channelCount) ch")

        // Attach nodes
        engine.attach(pitchUnit)
        engine.attach(sfxMixerNode)

        // Build the voice path: input → pitchUnit → mainMixer
        // Use the input node's native format for the connection to pitchUnit
        engine.connect(inputNode, to: pitchUnit, format: inputFormat)
        engine.connect(pitchUnit, to: mainMixer, format: inputFormat)

        // Build the SFX path: sfxMixerNode → mainMixer
        let sfxFormat = AVAudioFormat(
            standardFormatWithSampleRate: kSoundDeckSampleRate,
            channels: AVAudioChannelCount(kSoundDeckChannelCount)
        )!
        engine.connect(sfxMixerNode, to: mainMixer, format: sfxFormat)

        // Create the sound player pool connected to the SFX mixer
        soundPlayer = SoundPlayer(engine: engine, mixerNode: sfxMixerNode, appState: appState)

        // Set up format converter if the main mixer output doesn't match our target
        let mixerOutputFormat = mainMixer.outputFormat(forBus: 0)
        if mixerOutputFormat.sampleRate != outputFormat.sampleRate ||
           mixerOutputFormat.channelCount != outputFormat.channelCount {
            formatConverter = AVAudioConverter(from: mixerOutputFormat, to: outputFormat)
            logger.info("Format converter created: \(mixerOutputFormat.sampleRate) → \(self.outputFormat.sampleRate)")

            // Pre-allocate buffers for RT-safe format conversion (no allocations on audio thread)
            let maxFrames: AVAudioFrameCount = 4096
            let maxOutputFrames = AVAudioFrameCount(
                Double(maxFrames) * (outputFormat.sampleRate / mixerOutputFormat.sampleRate) + 1
            )
            preAllocatedOutputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: maxOutputFrames)
            preAllocatedInputBuffer = AVAudioPCMBuffer(pcmFormat: mixerOutputFormat, frameCapacity: maxFrames)
        } else {
            formatConverter = nil
            preAllocatedOutputBuffer = nil
            preAllocatedInputBuffer = nil
        }

        // Create sink node that captures the final mixed audio and writes to shared memory.
        // The sink node callback is RT-safe: just a memcpy into the ring buffer.
        let writer = sharedMemoryWriter
        let converter = formatConverter
        let outputBuf = preAllocatedOutputBuffer
        let inputBuf = preAllocatedInputBuffer

        sinkNode = AVAudioSinkNode { timestamp, frameCount, inputData -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer(mutating: inputData))

            guard let firstBuffer = ablPointer.first,
                  let srcData = firstBuffer.mData else {
                return noErr
            }

            if let converter = converter,
               let convertedBuffer = outputBuf,
               let inputPCM = inputBuf {
                // Reuse pre-allocated buffers (RT-safe, no heap allocation)
                convertedBuffer.frameLength = 0
                inputPCM.frameLength = frameCount
                if let destData = inputPCM.floatChannelData?[0] {
                    memcpy(destData, srcData, Int(frameCount) * MemoryLayout<Float>.size)
                }

                var error: NSError?
                var inputConsumed = false
                let inputBlock: AVAudioConverterInputBlock = { _, outStatus -> AVAudioBuffer? in
                    if inputConsumed {
                        outStatus.pointee = .endOfStream
                        return nil
                    }
                    outStatus.pointee = .haveData
                    inputConsumed = true
                    return inputPCM
                }

                converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)

                if let floatData = convertedBuffer.floatChannelData?[0] {
                    _ = writer.write(frames: floatData, frameCount: convertedBuffer.frameLength)
                }
            } else {
                // Direct path: format matches, just write
                let floatPtr = srcData.assumingMemoryBound(to: Float.self)
                _ = writer.write(frames: floatPtr, frameCount: frameCount)
            }

            return noErr
        }

        engine.attach(sinkNode!)
        engine.connect(mainMixer, to: sinkNode!, format: mixerOutputFormat)

        // Install metering tap
        installMeteringTap()

        // Install voice monitor tap on pitchUnit output (separate from metering)
        installVoiceMonitorTap()

        // Apply current voice changer state
        if appState.isVoiceChangerEnabled {
            voiceChanger.pitchCents = appState.pitchShiftCents
            voiceChanger.enable()
        } else {
            voiceChanger.disable()
        }

        // Apply mute state
        sharedMemoryWriter.setMuted(appState.isMuted)

        engine.prepare()
    }

    // MARK: - Metering

    private func installMeteringTap() {
        let mainMixer = engine.mainMixerNode
        let format = mainMixer.outputFormat(forBus: 0)

        mainMixer.installTap(onBus: 0, bufferSize: AVAudioFrameCount(meteringSampleCount), format: format) { [weak self] buffer, _ in
            guard let self = self else { return }

            let channelData = buffer.floatChannelData
            let channelCount = Int(buffer.format.channelCount)
            let frameLength = Int(buffer.frameLength)

            guard frameLength > 0, channelCount > 0, let channels = channelData else { return }

            // Calculate RMS across all channels
            var sumSquares: Float = 0.0
            for channel in 0..<channelCount {
                let samples = channels[channel]
                for frame in 0..<frameLength {
                    let sample = samples[frame]
                    sumSquares += sample * sample
                }
            }

            let rms = sqrtf(sumSquares / Float(frameLength * channelCount))
            // Clamp to 0-1 range
            let level = min(max(rms, 0.0), 1.0)

            DispatchQueue.main.async {
                self.appState.inputLevel = level
                // Push RMS into scrolling waveform history
                self.appState.waveformLevels.removeFirst()
                self.appState.waveformLevels.append(level)
            }
        }
    }

    private func removeMeteringTap() {
        engine.mainMixerNode.removeTap(onBus: 0)
    }

    // MARK: - Voice Monitor Tap

    private func installVoiceMonitorTap() {
        let format = pitchUnit.outputFormat(forBus: 0)

        pitchUnit.installTap(onBus: 0, bufferSize: AVAudioFrameCount(meteringSampleCount), format: format) { [weak self] buffer, _ in
            guard let self = self,
                  self.appState.isVoiceMonitorEnabled,
                  let previewEngine = self.previewEngine else { return }

            // Copy buffer since tap may reuse it (allocation OK — tap callback is not RT thread)
            guard let copy = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: buffer.frameLength) else { return }
            copy.frameLength = buffer.frameLength
            if let src = buffer.floatChannelData, let dst = copy.floatChannelData {
                for ch in 0..<Int(buffer.format.channelCount) {
                    memcpy(dst[ch], src[ch], Int(buffer.frameLength) * MemoryLayout<Float>.size)
                }
            }

            previewEngine.scheduleVoiceMonitorBuffer(copy)
        }
    }

    private func removeVoiceMonitorTap() {
        pitchUnit.removeTap(onBus: 0)
    }

    // MARK: - Controls

    func updatePitchShift(cents: Float) {
        voiceChanger.pitchCents = cents
    }

    func setMuted(_ muted: Bool) {
        sharedMemoryWriter.setMuted(muted)
    }

    /// Configures a WatermarkPlayer with this engine's audio graph.
    func configureWatermark(_ watermarkPlayer: WatermarkPlayer) {
        watermarkPlayer.configure(engine: engine, mixerNode: sfxMixerNode)
    }

    // MARK: - Configuration Change Handling

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleConfigurationChange),
            name: .AVAudioEngineConfigurationChange,
            object: engine
        )
    }

    @objc private func handleConfigurationChange(_ notification: Notification) {
        logger.warning("Audio engine configuration changed, rebuilding graph")

        let wasRunning = engine.isRunning
        if wasRunning {
            engine.stop()
        }

        // Rebuild and restart
        do {
            try buildGraph()
            if wasRunning {
                try engine.start()
                logger.info("Audio engine restarted after configuration change")
            }
        } catch {
            logger.error("Failed to rebuild audio engine after config change: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.appState.isEngineRunning = false
            }
        }
    }

    // MARK: - AppState Observation

    private func observeAppState() {
        // Observe mute changes
        appState.$isMuted
            .removeDuplicates()
            .sink { [weak self] muted in
                self?.setMuted(muted)
            }
            .store(in: &cancellables)

        // Observe pitch shift changes
        appState.$pitchShiftCents
            .removeDuplicates()
            .sink { [weak self] cents in
                self?.updatePitchShift(cents: cents)
            }
            .store(in: &cancellables)

        // Observe voice changer toggle
        appState.$isVoiceChangerEnabled
            .removeDuplicates()
            .sink { [weak self] enabled in
                if enabled {
                    self?.voiceChanger.enable()
                } else {
                    self?.voiceChanger.disable()
                }
            }
            .store(in: &cancellables)

        // Observe voice monitor toggle — stop playback when disabled
        appState.$isVoiceMonitorEnabled
            .removeDuplicates()
            .sink { [weak self] enabled in
                if !enabled {
                    self?.previewEngine?.stopVoiceMonitor()
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
    }
}
