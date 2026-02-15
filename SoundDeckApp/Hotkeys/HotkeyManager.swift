import Foundation
import KeyboardShortcuts
import Combine
import os.log

/// Manages global keyboard shortcut registration for app-wide actions
/// and per-sound trigger hotkeys.
///
/// Registers hotkeys on startup and re-registers when the sound list changes.
final class HotkeyManager {
    private let appState: AppState
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "HotkeyManager")
    private var cancellables = Set<AnyCancellable>()

    /// Weak reference to the audio engine's sound player.
    /// Set this after AudioEngineManager is initialized.
    weak var audioEngineManager: AudioEngineManager?

    /// Weak reference to preview engine for SFX monitoring.
    weak var previewEngine: PreviewEngine?

    init(appState: AppState) {
        self.appState = appState
        observeSoundChanges()
    }

    // MARK: - Registration

    /// Registers all global and per-sound hotkeys.
    /// Call on startup and whenever the sound list changes.
    func registerHotkeys() {
        registerGlobalActions()
        registerSoundHotkeys()
        logger.info("Hotkeys registered")
    }

    /// Unregisters all hotkeys. Call during cleanup.
    func unregisterAll() {
        KeyboardShortcuts.removeHandler(for: .globalMute)
        KeyboardShortcuts.removeHandler(for: .stopAll)
        KeyboardShortcuts.removeHandler(for: .toggleVoiceChanger)

        for sound in appState.sounds {
            let name = KeyboardShortcuts.Name.forSound(id: sound.id)
            KeyboardShortcuts.removeHandler(for: name)
        }

        logger.info("All hotkeys unregistered")
    }

    // MARK: - Global Actions

    private func registerGlobalActions() {
        // Global mute toggle
        KeyboardShortcuts.onKeyUp(for: .globalMute) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.appState.isMuted.toggle()
                self.logger.info("Global mute toggled: \(self.appState.isMuted)")
            }
        }

        // Stop all playing sounds
        KeyboardShortcuts.onKeyUp(for: .stopAll) { [weak self] in
            guard let self = self else { return }
            self.audioEngineManager?.soundPlayer?.stopAll()
            self.previewEngine?.stopAllSFXMonitor()
            self.logger.info("Stop all triggered via hotkey")
        }

        // Toggle voice changer (Pro only)
        KeyboardShortcuts.onKeyUp(for: .toggleVoiceChanger) { [weak self] in
            guard let self = self else { return }
            guard self.appState.canUseVoiceChanger else { return }
            DispatchQueue.main.async {
                self.appState.isVoiceChangerEnabled.toggle()
                self.logger.info("Voice changer toggled: \(self.appState.isVoiceChangerEnabled)")
            }
        }
    }

    // MARK: - Per-Sound Hotkeys

    private func registerSoundHotkeys() {
        // Per-sound hotkeys require Pro subscription
        guard appState.canUsePerSoundHotkeys else {
            // Remove any previously registered per-sound handlers
            for sound in appState.sounds {
                let name = KeyboardShortcuts.Name.forSound(id: sound.id)
                KeyboardShortcuts.removeHandler(for: name)
            }
            logger.info("Per-sound hotkeys disabled (requires Pro)")
            return
        }

        for sound in appState.sounds {
            guard sound.hotkeyName != nil else { continue }

            let name = KeyboardShortcuts.Name.forSound(id: sound.id)
            let soundID = sound.id

            KeyboardShortcuts.onKeyUp(for: name) { [weak self] in
                guard let self = self else { return }
                self.triggerSound(id: soundID)
            }
        }
    }

    /// Triggers playback for a specific sound by ID.
    /// If the sound is already playing, it stops it (toggle behavior).
    private func triggerSound(id: UUID) {
        guard let sound = appState.sounds.first(where: { $0.id == id }) else {
            logger.warning("Hotkey triggered for unknown sound ID: \(id)")
            return
        }

        guard let soundPlayer = audioEngineManager?.soundPlayer else {
            logger.warning("Sound player not available")
            return
        }

        if soundPlayer.isPlaying(sound: sound) {
            soundPlayer.stop(sound: sound)
            previewEngine?.stopSFXMonitor(soundID: sound.id)
            logger.info("Hotkey stopped sound: \(sound.name)")
        } else {
            soundPlayer.play(sound: sound)
            // Dual-play: also play through PreviewEngine for local monitoring
            if appState.isSFXMonitorEnabled,
               let buffer = soundPlayer.getBuffer(for: sound.id) {
                previewEngine?.playSFXMonitor(buffer: buffer, soundID: sound.id, volume: sound.volume)
            }
            logger.info("Hotkey played sound: \(sound.name)")
        }
    }

    // MARK: - Observation

    /// Re-registers per-sound hotkeys when the sounds list or Pro status changes.
    private func observeSoundChanges() {
        appState.$sounds
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.registerSoundHotkeys()
            }
            .store(in: &cancellables)

        appState.$isPro
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.registerSoundHotkeys()
            }
            .store(in: &cancellables)
    }

    deinit {
        unregisterAll()
    }
}
