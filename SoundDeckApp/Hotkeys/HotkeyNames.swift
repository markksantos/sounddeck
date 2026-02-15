import Foundation
import KeyboardShortcuts

/// Static hotkey name definitions for global actions and per-sound triggers.
extension KeyboardShortcuts.Name {
    // MARK: - Global Actions

    /// Toggle microphone mute/unmute.
    static let globalMute = Self("globalMute")

    /// Stop all currently playing sounds.
    static let stopAll = Self("stopAll")

    /// Toggle the voice changer on/off.
    static let toggleVoiceChanger = Self("toggleVoiceChanger")

    // MARK: - Per-Sound Hotkeys

    /// Creates a unique hotkey name for a specific sound identified by its UUID.
    /// The name format is "sound_<UUID>" to avoid collisions.
    static func forSound(id: UUID) -> Self {
        return Self("sound_\(id.uuidString)")
    }

    /// Extracts the sound UUID from a per-sound hotkey name, if applicable.
    /// Returns nil if the name does not match the "sound_<UUID>" pattern.
    var soundID: UUID? {
        let prefix = "sound_"
        guard rawValue.hasPrefix(prefix) else { return nil }
        let uuidString = String(rawValue.dropFirst(prefix.count))
        return UUID(uuidString: uuidString)
    }
}
