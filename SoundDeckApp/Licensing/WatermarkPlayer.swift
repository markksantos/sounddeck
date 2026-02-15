import AVFoundation
import Combine
import os.log

/// Anti-piracy watermark that plays a short 1kHz beep through the SFX mixer
/// every 60 seconds when the trial has expired and no valid license exists.
///
/// Automatically starts/stops based on appState license state changes.
final class WatermarkPlayer {
    private let appState: AppState
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "WatermarkPlayer")

    /// The SFX mixer node on the main audio engine to inject beeps into.
    private weak var mixerNode: AVAudioMixerNode?
    private weak var engine: AVAudioEngine?

    private var playerNode: AVAudioPlayerNode?
    private var beepBuffer: AVAudioPCMBuffer?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var isActive = false

    // Watermark configuration
    private static let beepFrequency: Double = 1000.0   // Hz
    private static let beepDuration: Double = 0.15       // seconds
    private static let beepAmplitude: Float = 0.3        // moderate volume
    private static let intervalSeconds: TimeInterval = 60.0

    init(appState: AppState) {
        self.appState = appState
        observeLicenseState()
    }

    /// Configure the watermark player with the audio engine and SFX mixer.
    /// Call after the audio engine is set up.
    func configure(engine: AVAudioEngine, mixerNode: AVAudioMixerNode) {
        self.engine = engine
        self.mixerNode = mixerNode
        generateBeepBuffer()
        setupPlayerNode()
        evaluateState()
    }

    // MARK: - Beep Generation

    /// Generates a short 1kHz sine wave beep into a PCM buffer.
    private func generateBeepBuffer() {
        let sampleRate: Double = 48000.0
        let frameCount = AVAudioFrameCount(sampleRate * Self.beepDuration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            logger.error("Failed to create beep buffer")
            return
        }

        buffer.frameLength = frameCount

        guard let floatData = buffer.floatChannelData?[0] else { return }

        let omega = 2.0 * Double.pi * Self.beepFrequency / sampleRate

        for frame in 0..<Int(frameCount) {
            // Sine wave with envelope to avoid clicks
            let t = Double(frame) / Double(frameCount)
            let envelope: Float

            // Short fade in/out (5ms each)
            let fadeSamples = Int(sampleRate * 0.005)
            if frame < fadeSamples {
                envelope = Float(frame) / Float(fadeSamples)
            } else if frame > Int(frameCount) - fadeSamples {
                envelope = Float(Int(frameCount) - frame) / Float(fadeSamples)
            } else {
                envelope = 1.0
            }

            let sample = Self.beepAmplitude * envelope * Float(sin(omega * Double(frame)))
            floatData[frame] = sample
        }

        beepBuffer = buffer
    }

    // MARK: - Player Node

    private func setupPlayerNode() {
        guard let engine = engine, let mixerNode = mixerNode else { return }

        let node = AVAudioPlayerNode()
        engine.attach(node)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 48000.0, channels: 1) else {
            logger.error("Failed to create audio format for watermark player node")
            return
        }
        engine.connect(node, to: mixerNode, format: format)

        playerNode = node
    }

    // MARK: - Start / Stop

    /// Starts the watermark timer. Beeps play every 60 seconds.
    func start() {
        guard !isActive else { return }
        guard beepBuffer != nil, playerNode != nil else {
            logger.warning("Watermark not configured, cannot start")
            return
        }

        isActive = true

        // Play an initial beep immediately
        playBeep()

        // Schedule recurring beeps
        timer = Timer.scheduledTimer(withTimeInterval: Self.intervalSeconds, repeats: true) { [weak self] _ in
            self?.playBeep()
        }

        logger.info("Watermark started (beep every \(Self.intervalSeconds)s)")
    }

    /// Stops the watermark timer and any playing beep.
    func stop() {
        guard isActive else { return }

        timer?.invalidate()
        timer = nil
        playerNode?.stop()
        isActive = false

        logger.info("Watermark stopped")
    }

    // MARK: - Playback

    private func playBeep() {
        guard let player = playerNode,
              let buffer = beepBuffer,
              let engine = engine,
              engine.isRunning else { return }

        player.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
            self?.logger.info("Watermark beep played")
        }
        player.play()
    }

    // MARK: - License State Observation

    private func observeLicenseState() {
        appState.$isPro
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPro in
                self?.handleStateChange(isPro: isPro)
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(isPro: Bool) {
        let shouldBeActive = !isPro

        if shouldBeActive && !isActive {
            start()
        } else if !shouldBeActive && isActive {
            stop()
        }
    }

    private func evaluateState() {
        handleStateChange(isPro: appState.isPro)
    }

    deinit {
        stop()
    }
}
