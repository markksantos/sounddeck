import Foundation
import SwiftUI
import Combine
import KeyboardShortcuts
import os.log

/// Persistence manager for sounds and folders.
/// Saves/loads JSON to ~/Library/Application Support/SoundDeck/
/// and manages audio file storage within that directory.
final class SoundStore {
    private let appState: AppState
    private let fileManager = FileManager.default
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "SoundStore")
    private var cancellables = Set<AnyCancellable>()

    private static let soundsFileName = "sounds.json"
    private static let foldersFileName = "folders.json"
    private static let audioSubdirectory = "Audio"
    private static let hasLaunchedKey = "SoundDeck_HasLaunchedBefore"

    /// The root Application Support directory for SoundDeck.
    static var appSupportDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("SoundDeck")
    }

    /// The subdirectory where imported audio files are stored.
    static var audioDirectory: URL {
        appSupportDirectory.appendingPathComponent(audioSubdirectory)
    }

    private var soundsFileURL: URL {
        Self.appSupportDirectory.appendingPathComponent(Self.soundsFileName)
    }

    private var foldersFileURL: URL {
        Self.appSupportDirectory.appendingPathComponent(Self.foldersFileName)
    }

    init(appState: AppState) {
        self.appState = appState
        ensureDirectoriesExist()
    }

    // MARK: - Directory Setup

    private func ensureDirectoriesExist() {
        do {
            try fileManager.createDirectory(at: Self.appSupportDirectory, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: Self.audioDirectory, withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create app support directories: \(error.localizedDescription)")
        }
    }

    // MARK: - Auto-Save

    /// Start observing sounds and folders for changes and auto-save.
    /// Call after loadSounds() so the initial load doesn't trigger a redundant save.
    func startAutoSaving() {
        appState.$sounds
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveSounds()
            }
            .store(in: &cancellables)

        appState.$folders
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveFolders()
            }
            .store(in: &cancellables)

        logger.info("Auto-save observers started")
    }

    // MARK: - Sounds

    func loadSounds() {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: Self.hasLaunchedKey)

        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: Self.hasLaunchedKey)
            createDefaultFolders()
            populateDefaultSounds()
            saveSounds()
            saveFolders()
            return
        }

        // Load persisted sounds
        do {
            let data = try Data(contentsOf: soundsFileURL)
            let decoder = JSONDecoder()
            let sounds = try decoder.decode([SoundItem].self, from: data)
            DispatchQueue.main.async {
                self.appState.sounds = sounds
            }
            logger.info("Loaded \(sounds.count) sounds from disk")
        } catch {
            logger.warning("Failed to load sounds, starting with empty list: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.appState.sounds = []
            }
        }

        // Load persisted folders
        loadFolders()
    }

    func saveSounds() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(appState.sounds)
            try data.write(to: soundsFileURL, options: .atomic)
            logger.info("Saved \(self.appState.sounds.count) sounds to disk")
        } catch {
            logger.error("Failed to save sounds: \(error.localizedDescription)")
        }
    }

    /// Import an audio file from an external URL into the app's audio directory.
    /// Returns the newly created SoundItem, or nil on failure.
    @discardableResult
    func importSound(url: URL) -> SoundItem? {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }

        let originalName = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension

        // Generate unique filename to avoid collisions
        let uniqueID = UUID().uuidString.prefix(8)
        let destFileName = "\(originalName)_\(uniqueID).\(fileExtension)"
        let destURL = Self.audioDirectory.appendingPathComponent(destFileName)

        do {
            try fileManager.copyItem(at: url, to: destURL)
        } catch {
            logger.error("Failed to copy audio file: \(error.localizedDescription)")
            return nil
        }

        // Store path relative to app support directory
        let relativePath = "Audio/\(destFileName)"

        let sound = SoundItem(
            name: originalName,
            fileName: relativePath,
            color: Self.randomPadColor(),
            iconName: "waveform"
        )

        DispatchQueue.main.async {
            self.appState.sounds.append(sound)
        }
        // Auto-save observer will persist when $sounds fires
        logger.info("Imported sound: \(originalName)")
        return sound
    }

    func deleteSound(_ sound: SoundItem) {
        // Remove any registered hotkey handler for this sound
        let hotkeyName = KeyboardShortcuts.Name.forSound(id: sound.id)
        KeyboardShortcuts.removeHandler(for: hotkeyName)

        // Remove the audio file
        let fileURL = Self.appSupportDirectory.appendingPathComponent(sound.fileName)
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            logger.warning("Failed to delete audio file: \(error.localizedDescription)")
        }

        // Remove from state — auto-save observer will persist when $sounds fires
        DispatchQueue.main.async {
            self.appState.sounds.removeAll { $0.id == sound.id }
        }
        logger.info("Deleted sound: \(sound.name)")
    }

    // MARK: - Folders

    func loadFolders() {
        do {
            let data = try Data(contentsOf: foldersFileURL)
            let decoder = JSONDecoder()
            let folders = try decoder.decode([SoundFolder].self, from: data)
            DispatchQueue.main.async {
                self.appState.folders = folders
            }
            logger.info("Loaded \(folders.count) folders from disk")
        } catch {
            logger.warning("Failed to load folders: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.appState.folders = []
            }
        }
    }

    func saveFolders() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(appState.folders)
            try data.write(to: foldersFileURL, options: .atomic)
            logger.info("Saved \(self.appState.folders.count) folders to disk")
        } catch {
            logger.error("Failed to save folders: \(error.localizedDescription)")
        }
    }

    // MARK: - Defaults

    private func createDefaultFolders() {
        let effectsFolder = SoundFolder(name: "Effects", iconName: "sparkles", color: .orange)
        let musicFolder = SoundFolder(name: "Music", iconName: "music.note", color: .purple)
        let voiceFolder = SoundFolder(name: "Voice", iconName: "mic.fill", color: .green)
        let customFolder = SoundFolder(name: "Custom", iconName: "folder.fill", color: .blue)

        // Set synchronously so populateDefaultSounds() can read folders immediately.
        // This is safe because loadSounds() (the caller) runs on the main thread.
        appState.folders = [effectsFolder, musicFolder, voiceFolder, customFolder]
        logger.info("Created default folders")
    }

    /// Copies default sounds from Resources/DefaultSounds/ in the app bundle.
    private func populateDefaultSounds() {
        guard let defaultSoundsURL = Bundle.main.url(forResource: "DefaultSounds", withExtension: nil) else {
            logger.info("No DefaultSounds directory found in bundle, skipping default sound population")
            return
        }

        let effectsFolderID = appState.folders.first(where: { $0.name == "Effects" })?.id

        do {
            let soundFiles = try fileManager.contentsOfDirectory(
                at: defaultSoundsURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )

            let audioExtensions: Set<String> = ["wav", "mp3", "m4a", "aac", "aif", "aiff", "caf"]
            var importedSounds: [SoundItem] = []

            for fileURL in soundFiles {
                guard audioExtensions.contains(fileURL.pathExtension.lowercased()) else { continue }

                let originalName = fileURL.deletingPathExtension().lastPathComponent
                let destFileName = fileURL.lastPathComponent
                let destURL = Self.audioDirectory.appendingPathComponent(destFileName)

                // Skip if already exists (idempotent)
                if !fileManager.fileExists(atPath: destURL.path) {
                    try fileManager.copyItem(at: fileURL, to: destURL)
                }

                let relativePath = "Audio/\(destFileName)"
                let sound = SoundItem(
                    name: originalName,
                    fileName: relativePath,
                    color: Self.randomPadColor(),
                    iconName: "waveform",
                    folderID: effectsFolderID
                )
                importedSounds.append(sound)
            }

            // Set synchronously — loadSounds() (the caller) runs on the main thread
            appState.sounds = importedSounds
            logger.info("Populated \(importedSounds.count) default sounds from bundle")
        } catch {
            logger.error("Failed to populate default sounds: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private static let padColors: [Color] = [
        .blue, .purple, .pink, .red, .orange, .yellow, .green, .teal, .cyan, .indigo
    ]

    private static func randomPadColor() -> Color {
        padColors.randomElement() ?? .blue
    }
}
