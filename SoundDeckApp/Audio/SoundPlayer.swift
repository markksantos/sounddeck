import AVFoundation
import os.log

/// Pool-based sound effect player that connects to the SFX mixer node.
/// Supports concurrent playback of up to 8 simultaneous sounds.
///
/// Preloads audio files into AVAudioPCMBuffers for low-latency triggering.
/// Respects per-sound trim points and volume.
final class SoundPlayer {
    private let engine: AVAudioEngine
    private let mixerNode: AVAudioMixerNode
    private let appState: AppState
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "SoundPlayer")

    private static let poolSize = 8

    // Player pool
    private var playerNodes: [AVAudioPlayerNode] = []
    private var playerAssignment: [Int: UUID] = [:]  // playerIndex → soundID

    // Preloaded buffers cache: soundID → (buffer, format)
    private var bufferCache: [UUID: (buffer: AVAudioPCMBuffer, format: AVAudioFormat)] = [:]

    // Queue for thread-safe access to player assignments
    private let assignmentQueue = DispatchQueue(label: "com.sounddeck.soundplayer.assignment")

    init(engine: AVAudioEngine, mixerNode: AVAudioMixerNode, appState: AppState) {
        self.engine = engine
        self.mixerNode = mixerNode
        self.appState = appState
        setupPlayerPool()
    }

    // MARK: - Pool Setup

    private func setupPlayerPool() {
        for _ in 0..<Self.poolSize {
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            let format = AVAudioFormat(
                standardFormatWithSampleRate: kSoundDeckSampleRate,
                channels: AVAudioChannelCount(kSoundDeckChannelCount)
            )!
            engine.connect(playerNode, to: mixerNode, format: format)
            playerNodes.append(playerNode)
        }
        logger.info("Created \(Self.poolSize) player nodes in pool")
    }

    // MARK: - Preloading

    /// Preloads an audio file into a PCM buffer for low-latency playback.
    func preload(sound: SoundItem) {
        guard bufferCache[sound.id] == nil else { return }

        let fileURL = sound.fileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            logger.warning("Audio file not found: \(fileURL.path)")
            return
        }

        do {
            let audioFile = try AVAudioFile(forReading: fileURL)
            let fileFormat = audioFile.processingFormat
            let totalFrames = AVAudioFrameCount(audioFile.length)

            guard totalFrames > 0 else {
                logger.warning("Audio file is empty: \(sound.name)")
                return
            }

            // Calculate trim frames
            let sampleRate = fileFormat.sampleRate
            let trimStartFrame = AVAudioFramePosition(sound.trimStart * sampleRate)
            let trimEndFrame: AVAudioFramePosition
            if sound.trimEnd > 0 {
                trimEndFrame = AVAudioFramePosition(sound.trimEnd * sampleRate)
            } else {
                trimEndFrame = AVAudioFramePosition(totalFrames)
            }

            let effectiveStartFrame = max(0, min(trimStartFrame, AVAudioFramePosition(totalFrames)))
            let effectiveEndFrame = max(effectiveStartFrame, min(trimEndFrame, AVAudioFramePosition(totalFrames)))
            let frameCount = AVAudioFrameCount(effectiveEndFrame - effectiveStartFrame)

            guard frameCount > 0 else {
                logger.warning("Trim results in zero frames for: \(sound.name)")
                return
            }

            // Seek to trim start
            audioFile.framePosition = effectiveStartFrame

            // Read into buffer
            guard let sourceBuffer = AVAudioPCMBuffer(pcmFormat: fileFormat, frameCapacity: frameCount) else {
                logger.error("Failed to create PCM buffer for: \(sound.name)")
                return
            }
            try audioFile.read(into: sourceBuffer, frameCount: frameCount)

            // Convert to our target format if needed
            let targetFormat = AVAudioFormat(
                standardFormatWithSampleRate: kSoundDeckSampleRate,
                channels: AVAudioChannelCount(kSoundDeckChannelCount)
            )!

            if fileFormat.sampleRate != targetFormat.sampleRate ||
               fileFormat.channelCount != targetFormat.channelCount {

                guard let converter = AVAudioConverter(from: fileFormat, to: targetFormat) else {
                    logger.error("Failed to create format converter for: \(sound.name)")
                    return
                }

                let ratio = targetFormat.sampleRate / fileFormat.sampleRate
                let convertedFrameCount = AVAudioFrameCount(Double(frameCount) * ratio)
                guard let convertedBuffer = AVAudioPCMBuffer(
                    pcmFormat: targetFormat,
                    frameCapacity: convertedFrameCount
                ) else {
                    logger.error("Failed to create converted buffer for: \(sound.name)")
                    return
                }

                var error: NSError?
                var inputConsumed = false
                converter.convert(to: convertedBuffer, error: &error) { _, outStatus -> AVAudioBuffer? in
                    if inputConsumed {
                        outStatus.pointee = .endOfStream
                        return nil
                    }
                    outStatus.pointee = .haveData
                    inputConsumed = true
                    return sourceBuffer
                }

                if let error = error {
                    logger.error("Format conversion failed for \(sound.name): \(error.localizedDescription)")
                    return
                }

                bufferCache[sound.id] = (convertedBuffer, targetFormat)
            } else {
                bufferCache[sound.id] = (sourceBuffer, fileFormat)
            }

            logger.info("Preloaded sound: \(sound.name) (\(frameCount) frames)")
        } catch {
            logger.error("Failed to preload \(sound.name): \(error.localizedDescription)")
        }
    }

    /// Removes a preloaded buffer from the cache.
    func unload(sound: SoundItem) {
        bufferCache.removeValue(forKey: sound.id)
    }

    // MARK: - Buffer Access

    /// Returns the preloaded buffer for a sound, if available.
    /// The buffer is read-only safe to share across engines.
    func getBuffer(for soundID: UUID) -> AVAudioPCMBuffer? {
        bufferCache[soundID]?.buffer
    }

    // MARK: - Playback

    /// Plays a sound effect through the SFX mixer.
    /// Finds an available player from the pool and schedules the buffer.
    func play(sound: SoundItem) {
        guard engine.isRunning else {
            logger.warning("Engine not running, cannot play: \(sound.name)")
            return
        }

        // Ensure sound is preloaded
        if bufferCache[sound.id] == nil {
            preload(sound: sound)
        }

        guard let cached = bufferCache[sound.id] else {
            logger.error("No buffer available for: \(sound.name)")
            return
        }

        assignmentQueue.sync {
            guard let playerIndex = findAvailablePlayer() else {
                logger.warning("All \(Self.poolSize) players busy, cannot play: \(sound.name)")
                return
            }

            let player = playerNodes[playerIndex]
            playerAssignment[playerIndex] = sound.id

            // Set per-sound volume
            player.volume = sound.volume

            // Schedule and play
            player.scheduleBuffer(cached.buffer, at: nil, options: []) { [weak self] in
                self?.handlePlaybackComplete(playerIndex: playerIndex, soundID: sound.id)
            }
            player.play()

            DispatchQueue.main.async {
                self.appState.currentlyPlayingSoundIDs.insert(sound.id)
            }

            logger.info("Playing sound: \(sound.name) on player \(playerIndex)")
        }
    }

    /// Stops a specific sound if it is currently playing.
    func stop(sound: SoundItem) {
        assignmentQueue.sync {
            for (index, assignedID) in playerAssignment where assignedID == sound.id {
                playerNodes[index].stop()
                playerAssignment.removeValue(forKey: index)
            }
        }

        DispatchQueue.main.async {
            self.appState.currentlyPlayingSoundIDs.remove(sound.id)
        }
        logger.info("Stopped sound: \(sound.name)")
    }

    /// Stops all currently playing sounds.
    func stopAll() {
        assignmentQueue.sync {
            for (index, _) in playerAssignment {
                playerNodes[index].stop()
            }
            playerAssignment.removeAll()
        }

        DispatchQueue.main.async {
            self.appState.currentlyPlayingSoundIDs.removeAll()
        }
        logger.info("Stopped all sounds")
    }

    /// Returns whether a specific sound is currently playing.
    func isPlaying(sound: SoundItem) -> Bool {
        return assignmentQueue.sync {
            playerAssignment.values.contains(sound.id)
        }
    }

    // MARK: - Private

    /// Finds the index of an available (not currently playing) player node.
    /// Must be called within assignmentQueue.
    private func findAvailablePlayer() -> Int? {
        for i in 0..<playerNodes.count {
            if playerAssignment[i] == nil {
                return i
            }
        }
        return nil
    }

    /// Called when a scheduled buffer finishes playing.
    private func handlePlaybackComplete(playerIndex: Int, soundID: UUID) {
        assignmentQueue.sync {
            // Only clear if this sound is still assigned to this player
            if playerAssignment[playerIndex] == soundID {
                playerAssignment.removeValue(forKey: playerIndex)
            }
        }

        DispatchQueue.main.async {
            // Only remove from playing set if no other player has this sound
            let stillPlaying = self.assignmentQueue.sync {
                self.playerAssignment.values.contains(soundID)
            }
            if !stillPlaying {
                self.appState.currentlyPlayingSoundIDs.remove(soundID)
            }
        }
    }
}

// MARK: - Convenience for kSoundDeckSampleRate

import SoundDeckCommon

private let kSoundDeckSampleRate = Double(SoundDeckCommon.kSoundDeckSampleRate)
private let kSoundDeckChannelCount = UInt32(SoundDeckCommon.kSoundDeckChannelCount)
