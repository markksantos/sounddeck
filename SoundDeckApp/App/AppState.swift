import SwiftUI
import Combine
import CoreAudio

/// Central observable state for the entire app.
/// All managers reference this; UI binds to it.
final class AppState: ObservableObject {
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let isMuted = "SoundDeck_IsMuted"
        static let pitchShiftCents = "SoundDeck_PitchShiftCents"
        static let isVoiceChangerEnabled = "SoundDeck_IsVoiceChangerEnabled"
        static let selectedInputDeviceID = "SoundDeck_SelectedInputDeviceID"
        static let selectedOutputDeviceID = "SoundDeck_SelectedOutputDeviceID"
        static let isSFXMonitorEnabled = "SoundDeck_IsSFXMonitorEnabled"
        static let isVoiceMonitorEnabled = "SoundDeck_IsVoiceMonitorEnabled"
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Audio State
    @Published var isEngineRunning = false
    @Published var isMuted = false
    @Published var inputLevel: Float = 0.0   // RMS level 0.0–1.0 for VU meter

    // MARK: - Monitoring
    @Published var isSFXMonitorEnabled = true    // Hear SFX locally through headphones
    @Published var isVoiceMonitorEnabled = false  // Hear own mic through headphones
    @Published var waveformLevels: [Float] = Array(repeating: 0, count: 60)  // Rolling RMS history

    // MARK: - Voice Changer
    @Published var isVoiceChangerEnabled = false
    @Published var pitchShiftCents: Float = 0.0  // -1200 to +1200

    // MARK: - Sound Management
    @Published var sounds: [SoundItem] = []
    @Published var folders: [SoundFolder] = []
    @Published var selectedFolderID: UUID? = nil
    @Published var currentlyPlayingSoundIDs: Set<UUID> = []

    // MARK: - Device Selection
    @Published var selectedInputDeviceID: AudioDeviceID? = nil
    @Published var selectedOutputDeviceID: AudioDeviceID? = nil

    // MARK: - Subscription
    @Published var isPro = false
    @Published var currentPlan: SubscriptionPlan = .free

    enum SubscriptionPlan {
        case free, pro
    }

    // MARK: - Feature Gates
    var canUseVoiceChanger: Bool { isPro }
    var canUsePerSoundHotkeys: Bool { isPro }
    var canUseTrimEditor: Bool { isPro }
    var canAccessProLibrary: Bool { isPro }
    var showWatermark: Bool { !isPro }
    var maxFreeSounds: Int { 8 }
    var canAddMoreSounds: Bool { isPro || sounds.count < maxFreeSounds }

    // MARK: - Debug
    #if DEBUG
    /// When true, SubscriptionManager won't override isPro.
    var debugProOverride = false
    #endif

    // MARK: - Onboarding
    @Published var isDriverInstalled = false
    @Published var hasMicPermission = false
    @Published var showOnboarding = false

    // MARK: - Computed
    var filteredSounds: [SoundItem] {
        guard let folderID = selectedFolderID else { return sounds }
        return sounds.filter { $0.folderID == folderID }
    }

    // MARK: - Init

    init() {
        loadFromUserDefaults()
        observeForPersistence()
    }

    // MARK: - Persistence

    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard

        isMuted = defaults.bool(forKey: Keys.isMuted)
        pitchShiftCents = defaults.float(forKey: Keys.pitchShiftCents)
        isVoiceChangerEnabled = defaults.bool(forKey: Keys.isVoiceChangerEnabled)

        // SFX monitor defaults to true even when key doesn't exist yet
        if defaults.object(forKey: Keys.isSFXMonitorEnabled) != nil {
            isSFXMonitorEnabled = defaults.bool(forKey: Keys.isSFXMonitorEnabled)
        }
        isVoiceMonitorEnabled = defaults.bool(forKey: Keys.isVoiceMonitorEnabled)

        // AudioDeviceID is UInt32; store as Int (0 means not set / system default)
        let inputID = defaults.integer(forKey: Keys.selectedInputDeviceID)
        selectedInputDeviceID = inputID != 0 ? AudioDeviceID(inputID) : nil

        let outputID = defaults.integer(forKey: Keys.selectedOutputDeviceID)
        selectedOutputDeviceID = outputID != 0 ? AudioDeviceID(outputID) : nil
    }

    private func observeForPersistence() {
        let defaults = UserDefaults.standard

        $isMuted
            .dropFirst()
            .sink { defaults.set($0, forKey: Keys.isMuted) }
            .store(in: &cancellables)

        $pitchShiftCents
            .dropFirst()
            .sink { defaults.set($0, forKey: Keys.pitchShiftCents) }
            .store(in: &cancellables)

        $isVoiceChangerEnabled
            .dropFirst()
            .sink { defaults.set($0, forKey: Keys.isVoiceChangerEnabled) }
            .store(in: &cancellables)

        $selectedInputDeviceID
            .dropFirst()
            .sink { defaults.set(Int($0 ?? 0), forKey: Keys.selectedInputDeviceID) }
            .store(in: &cancellables)

        $selectedOutputDeviceID
            .dropFirst()
            .sink { defaults.set(Int($0 ?? 0), forKey: Keys.selectedOutputDeviceID) }
            .store(in: &cancellables)

        $isSFXMonitorEnabled
            .dropFirst()
            .sink { defaults.set($0, forKey: Keys.isSFXMonitorEnabled) }
            .store(in: &cancellables)

        $isVoiceMonitorEnabled
            .dropFirst()
            .sink { defaults.set($0, forKey: Keys.isVoiceMonitorEnabled) }
            .store(in: &cancellables)
    }
}
