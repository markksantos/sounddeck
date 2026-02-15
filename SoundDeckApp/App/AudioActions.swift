import SwiftUI

/// Closure-based actions injected into the SwiftUI environment so views
/// can trigger audio playback without directly referencing managers.
struct AudioActions {
    /// Play a sound into the virtual mic (main mix).
    var play: (SoundItem) -> Void = { _ in }

    /// Stop a specific sound.
    var stop: (SoundItem) -> Void = { _ in }

    /// Preview a sound through headphones only.
    var preview: (SoundItem) -> Void = { _ in }

    /// Stop all currently playing sounds.
    var stopAll: () -> Void = {}

    /// Import a file URL into the sound library, optionally into a folder.
    var importSound: (_ url: URL, _ folderID: UUID?) -> Void = { _, _ in }

    /// Open a file picker and import the selected sounds into a folder.
    var pickAndImportSounds: (_ folderID: UUID?) -> Void = { _ in }

    /// Delete a sound (removes file, hotkey handler, and state).
    var deleteSound: (SoundItem) -> Void = { _ in }
}

// MARK: - Environment Key

private struct AudioActionsKey: EnvironmentKey {
    static let defaultValue = AudioActions()
}

extension EnvironmentValues {
    var audioActions: AudioActions {
        get { self[AudioActionsKey.self] }
        set { self[AudioActionsKey.self] = newValue }
    }
}
