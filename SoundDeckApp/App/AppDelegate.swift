import SwiftUI
import Combine
import AVFoundation
import Sparkle
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: EventMonitor?
    private var cancellables = Set<AnyCancellable>()

    let appState = AppState()
    lazy var audioEngine = AudioEngineManager(appState: appState)
    lazy var previewEngine = PreviewEngine()
    lazy var soundStore = SoundStore(appState: appState)
    lazy var hotkeyManager = HotkeyManager(appState: appState)
    lazy var subscriptionManager = SubscriptionManager(appState: appState)
    lazy var watermarkPlayer = WatermarkPlayer(appState: appState)
    private var updaterController: SPUStandardUpdaterController?

    var isUpdaterConfigured: Bool {
        let info = Bundle.main.infoDictionary
        let publicKey = (info?["SUPublicEDKey"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let feedURLString = (info?["SUFeedURL"] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !publicKey.isEmpty,
              let feedURL = URL(string: feedURLString),
              feedURL.scheme == "https" else {
            return false
        }

        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupEventMonitor()
        loadState()
        startUpdaterIfConfigured()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "SoundDeck")
            button.action = #selector(statusItemClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let muteTitle = appState.isMuted ? "Unmute Microphone" : "Mute Microphone"
        let muteItem = NSMenuItem(title: muteTitle, action: #selector(toggleMute), keyEquivalent: "m")
        muteItem.target = self
        menu.addItem(muteItem)

        let stopItem = NSMenuItem(title: "Stop All Sounds", action: #selector(stopAllSounds), keyEquivalent: "")
        stopItem.target = self
        menu.addItem(stopItem)

        menu.addItem(.separator())

        let planTitle = appState.isPro ? "SoundDeck Pro" : "Free Plan"
        let planItem = NSMenuItem(title: planTitle, action: nil, keyEquivalent: "")
        planItem.isEnabled = false
        menu.addItem(planItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit SoundDeck", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            closePopover()
            statusItem.menu = buildMenu()
            statusItem.button?.performClick(nil)
            // Clear the menu so left-click goes back to popover
            statusItem.menu = nil
        } else {
            togglePopover()
        }
    }

    @objc private func toggleMute() {
        appState.isMuted.toggle()
    }

    @objc private func stopAllSounds() {
        audioEngine.soundPlayer?.stopAll()
        previewEngine.stopAllSFXMonitor()
        previewEngine.stopPreview()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func checkForUpdates() {
        guard isUpdaterConfigured else {
            let alert = NSAlert()
            alert.messageText = "Update checking is not configured"
            alert.informativeText = "SoundDeck needs a Sparkle public key in the app bundle before update checks can run."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }

        startUpdaterIfConfigured()
        updaterController?.checkForUpdates(nil)
    }

    private func startUpdaterIfConfigured() {
        guard isUpdaterConfigured, updaterController == nil else { return }
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    private func openFilePicker(folderID: UUID?) {
        guard appState.canAddMoreSounds else { return }

        // Close the popover first so NSOpenPanel can take focus cleanly
        closePopover()

        let panel = NSOpenPanel()
        panel.title = "Add Sounds"
        panel.allowedContentTypes = supportedAudioContentTypes
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false

        panel.begin { [weak self] response in
            guard response == .OK else { return }
            for url in panel.urls {
                guard self?.appState.canAddMoreSounds == true else { break }
                _ = self?.soundStore.importSound(url: url, folderID: folderID)
            }
        }
    }

    private var supportedAudioContentTypes: [UTType] {
        var types: [UTType] = [.audio, .mp3, .wav, .aiff, .mpeg4Audio]
        ["aac", "caf", "m4a"].compactMap { UTType(filenameExtension: $0) }.forEach { type in
            if !types.contains(type) {
                types.append(type)
            }
        }
        return types
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient

        let actions = AudioActions(
            play: { [weak self] sound in
                guard let self = self else { return }
                // Play through virtual mic if engine is running
                self.audioEngine.soundPlayer?.play(sound: sound)
                // Play locally through speakers/headphones
                if self.appState.isSFXMonitorEnabled {
                    if let buffer = self.audioEngine.soundPlayer?.getBuffer(for: sound.id) {
                        self.previewEngine.playSFXMonitor(buffer: buffer, soundID: sound.id, volume: sound.volume)
                    } else {
                        // Fallback: engine not running, play directly via preview
                        self.previewEngine.preview(sound: sound)
                    }
                }
            },
            stop: { [weak self] sound in
                guard let self = self else { return }
                self.audioEngine.soundPlayer?.stop(sound: sound)
                self.previewEngine.stopSFXMonitor(soundID: sound.id)
                self.previewEngine.stopPreview()
            },
            preview: { [weak self] sound in
                self?.previewEngine.preview(sound: sound)
            },
            stopAll: { [weak self] in
                guard let self = self else { return }
                self.audioEngine.soundPlayer?.stopAll()
                self.previewEngine.stopAllSFXMonitor()
                self.previewEngine.stopPreview()
            },
            importSound: { [weak self] url, folderID in
                guard self?.appState.canAddMoreSounds == true else { return }
                _ = self?.soundStore.importSound(url: url, folderID: folderID)
            },
            pickAndImportSounds: { [weak self] folderID in
                self?.openFilePicker(folderID: folderID)
            },
            duplicateSound: { [weak self] sound in
                guard let self = self, self.appState.canAddMoreSounds else { return }
                _ = self.soundStore.duplicateSound(sound)
            },
            deleteSound: { [weak self] sound in
                guard let self = self else { return }
                self.audioEngine.soundPlayer?.stop(sound: sound)
                self.previewEngine.stopSFXMonitor(soundID: sound.id)
                self.previewEngine.stopPreview()
                self.appState.currentlyPlayingSoundIDs.remove(sound.id)
                self.soundStore.deleteSound(sound)
            }
        )

        popover.contentViewController = NSHostingController(
            rootView: PopoverContentView()
                .environmentObject(appState)
                .environment(\.audioActions, actions)
        )
    }

    private func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let popover = self?.popover, popover.isShown {
                self?.closePopover()
            }
        }
    }

    private func loadState() {
        soundStore.loadSounds()
        soundStore.startAutoSaving()

        // Check subscription status
        Task {
            await subscriptionManager.loadProducts()
            await subscriptionManager.updateEntitlementStatus()
        }

        // Check if driver is installed
        appState.isDriverInstalled = FileManager.default.fileExists(
            atPath: "/Library/Audio/Plug-Ins/HAL/SoundDeckDriver.driver"
        )

        // Check actual microphone permission state
        appState.hasMicPermission = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized

        // Show onboarding if needed
        if !appState.isDriverInstalled || !appState.hasMicPermission {
            appState.showOnboarding = true
        }

        // Start engine if ready
        if appState.isDriverInstalled && appState.hasMicPermission {
            audioEngine.start()
            // Configure watermark player with the running audio engine
            audioEngine.configureWatermark(watermarkPlayer)
        }

        // Wire preview engine to audio engine for monitoring
        audioEngine.previewEngine = previewEngine

        // Wire hotkey manager to audio engine for sound playback
        hotkeyManager.audioEngineManager = audioEngine
        hotkeyManager.previewEngine = previewEngine
        hotkeyManager.registerHotkeys()

        // Sync preview engine output device with AppState selection
        if let outputID = appState.selectedOutputDeviceID, outputID != 0 {
            previewEngine.outputDeviceID = outputID
        }
        appState.$selectedOutputDeviceID
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] deviceID in
                if let deviceID, deviceID != 0 {
                    self?.previewEngine.outputDeviceID = deviceID
                } else {
                    self?.previewEngine.outputDeviceID = nil
                }
            }
            .store(in: &cancellables)

        // Observe driver install/uninstall mid-session to start/stop engine
        appState.$isDriverInstalled
            .removeDuplicates()
            .dropFirst() // skip the initial value already handled above
            .receive(on: DispatchQueue.main)
            .sink { [weak self] installed in
                guard let self = self else { return }
                if installed && self.appState.hasMicPermission {
                    self.audioEngine.start()
                    self.audioEngine.configureWatermark(self.watermarkPlayer)
                } else if !installed {
                    self.audioEngine.stop()
                }
            }
            .store(in: &cancellables)

        // Observe mic permission granted mid-session (e.g. during onboarding)
        appState.$hasMicPermission
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] granted in
                guard let self = self else { return }
                if granted && self.appState.isDriverInstalled {
                    self.audioEngine.start()
                    self.audioEngine.configureWatermark(self.watermarkPlayer)
                }
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                closePopover()
            } else {
                showPopover()
            }
        }
    }

    private func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            eventMonitor?.start()
        }
    }

    private func closePopover() {
        popover.performClose(nil)
        eventMonitor?.stop()
    }
}
