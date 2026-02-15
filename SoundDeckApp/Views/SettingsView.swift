import SwiftUI
import AVFoundation
import CoreAudio
import KeyboardShortcuts

/// Full settings panel presented as a sheet from the popover.
/// Organized into sections: Audio, Hotkeys, Subscription, Driver, About.
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showUpgrade = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showSupport = false
    @State private var inputDevices: [AudioDevice] = []
    @State private var outputDevices: [AudioDevice] = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2.bold())

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)

            // Scrollable content
            ScrollView {
                VStack(spacing: 20) {
                    audioDevicesSection
                    hotkeySection
                    subscriptionSection
                    #if DEBUG
                    debugSection
                    #endif
                    driverSection
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 420, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            refreshAudioDevices()
        }
    }

    // MARK: - Audio Devices Section

    private var audioDevicesSection: some View {
        SettingsSection(title: "Audio", icon: "speaker.wave.2.fill") {
            VStack(spacing: 12) {
                // Input Device
                VStack(alignment: .leading, spacing: 4) {
                    Text("Microphone Input")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    Picker("Input", selection: Binding(
                        get: { appState.selectedInputDeviceID ?? 0 },
                        set: { appState.selectedInputDeviceID = $0 }
                    )) {
                        Text("System Default").tag(UInt32(0))
                        ForEach(inputDevices) { device in
                            Text(device.name).tag(device.id)
                        }
                    }
                    .labelsHidden()
                }

                // Output Device
                VStack(alignment: .leading, spacing: 4) {
                    Text("Preview / Monitor Output")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    Picker("Output", selection: Binding(
                        get: { appState.selectedOutputDeviceID ?? 0 },
                        set: { appState.selectedOutputDeviceID = $0 }
                    )) {
                        Text("System Default").tag(UInt32(0))
                        ForEach(outputDevices) { device in
                            Text(device.name).tag(device.id)
                        }
                    }
                    .labelsHidden()
                }

            }
        }
    }

    // MARK: - Hotkey Section

    private var hotkeySection: some View {
        SettingsSection(title: "Hotkeys", icon: "keyboard") {
            if appState.sounds.isEmpty {
                Text("Add sounds to configure hotkeys.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(appState.sounds) { sound in
                        HStack {
                            Image(systemName: sound.iconName)
                                .font(.system(size: 11))
                                .foregroundColor(sound.color)
                                .frame(width: 18)

                            Text(sound.name)
                                .font(.system(size: 12))
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer()

                            if appState.canUsePerSoundHotkeys {
                                KeyboardShortcuts.Recorder(for: .forSound(id: sound.id))
                                    .frame(width: 120)
                            } else {
                                Label("Pro", systemImage: "lock.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary.opacity(0.5))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        SettingsSection(title: "Subscription", icon: "crown.fill") {
            VStack(spacing: 10) {
                if appState.isPro {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("SoundDeck Pro Active")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Label("Manage Subscription", systemImage: "arrow.up.right.square")
                            .font(.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                } else {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                        Text("Free Plan")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        showUpgrade = true
                    } label: {
                        Label("Upgrade to Pro", systemImage: "crown.fill")
                            .font(.system(size: 12, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }

                Button {
                    restoreSubscription()
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
                .environmentObject(appState)
        }
    }

    // MARK: - Driver Section

    private var driverSection: some View {
        SettingsSection(title: "Audio Driver", icon: "cpu") {
            VStack(spacing: 10) {
                HStack {
                    Circle()
                        .fill(appState.isDriverInstalled ? Color.green : Color.red.opacity(0.6))
                        .frame(width: 8, height: 8)

                    Text(appState.isDriverInstalled ? "SoundDeck Driver Installed" : "Driver Not Installed")
                        .font(.system(size: 12))
                        .foregroundColor(appState.isDriverInstalled ? .primary : .red)

                    Spacer()
                }

                HStack(spacing: 8) {
                    Button {
                        installDriver()
                    } label: {
                        Label(
                            appState.isDriverInstalled ? "Reinstall Driver" : "Install Driver",
                            systemImage: "arrow.down.circle.fill"
                        )
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(appState.isDriverInstalled ? .secondary : .accentColor)

                    if appState.isDriverInstalled {
                        Button {
                            uninstallDriver()
                        } label: {
                            Label("Uninstall", systemImage: "trash")
                                .font(.system(size: 12, weight: .medium))
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "info.circle") {
            VStack(spacing: 10) {
                HStack {
                    Text("SoundDeck")
                        .font(.system(size: 12, weight: .semibold))

                    Spacer()

                    Text("v\(appVersion)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Button {
                    checkForUpdates()
                } label: {
                    Label("Check for Updates", systemImage: "arrow.clockwise.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)

                Divider()

                HStack(spacing: 0) {
                    Button("Support") { showSupport = true }
                    Text(" \u{00B7} ")
                        .foregroundColor(.secondary.opacity(0.5))
                    Button("Privacy") { showPrivacy = true }
                    Text(" \u{00B7} ")
                        .foregroundColor(.secondary.opacity(0.5))
                    Button("Terms") { showTerms = true }
                }
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .buttonStyle(.plain)

                Divider()

                Button {
                    // Dismiss the sheet first, then terminate on the next run loop cycle.
                    // terminate(nil) doesn't work directly from inside a .sheet.
                    dismiss()
                    DispatchQueue.main.async {
                        NSApplication.shared.terminate(nil)
                    }
                } label: {
                    Label("Quit SoundDeck", systemImage: "power")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .sheet(isPresented: $showSupport) {
            SupportView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTerms) {
            TermsView()
        }
    }

    // MARK: - Debug Section

    #if DEBUG
    private var debugSection: some View {
        SettingsSection(title: "Debug", icon: "ladybug.fill") {
            Toggle("Pro Mode", isOn: Binding(
                get: { appState.isPro },
                set: { newValue in
                    appState.debugProOverride = newValue
                    appState.isPro = newValue
                    appState.currentPlan = newValue ? .pro : .free
                }
            ))
            .font(.system(size: 12))
        }
    }
    #endif

    // MARK: - Audio Device Discovery

    private func refreshAudioDevices() {
        inputDevices = discoverAudioDevices(forInput: true)
        outputDevices = discoverAudioDevices(forInput: false)
    }

    private func discoverAudioDevices(forInput: Bool) -> [AudioDevice] {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        let status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            &dataSize
        )
        guard status == noErr else { return [] }

        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

        let status2 = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0, nil,
            &dataSize,
            &deviceIDs
        )
        guard status2 == noErr else { return [] }

        return deviceIDs.compactMap { deviceID -> AudioDevice? in
            // Check if device has input/output channels
            var streamAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyStreamConfiguration,
                mScope: forInput ? kAudioDevicePropertyScopeInput : kAudioDevicePropertyScopeOutput,
                mElement: kAudioObjectPropertyElementMain
            )

            var streamSize: UInt32 = 0
            guard AudioObjectGetPropertyDataSize(deviceID, &streamAddress, 0, nil, &streamSize) == noErr else {
                return nil
            }

            let bufferListRaw = UnsafeMutableRawPointer.allocate(
                byteCount: Int(streamSize),
                alignment: MemoryLayout<AudioBufferList>.alignment
            )
            defer { bufferListRaw.deallocate() }

            let bufferListPointer = bufferListRaw.bindMemory(to: AudioBufferList.self, capacity: 1)
            guard AudioObjectGetPropertyData(deviceID, &streamAddress, 0, nil, &streamSize, bufferListPointer) == noErr else {
                return nil
            }

            let bufferList = UnsafeMutableAudioBufferListPointer(bufferListPointer)
            let channelCount = bufferList.reduce(0) { $0 + Int($1.mNumberChannels) }
            guard channelCount > 0 else { return nil }

            // Get device name
            var nameAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceNameCFString,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )

            var name: CFString = "" as CFString
            var nameSize = UInt32(MemoryLayout<CFString>.size)
            guard AudioObjectGetPropertyData(deviceID, &nameAddress, 0, nil, &nameSize, &name) == noErr else {
                return nil
            }

            return AudioDevice(id: deviceID, name: name as String)
        }
    }

    // MARK: - Actions

    private func restoreSubscription() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }
        Task {
            await appDelegate.subscriptionManager.restorePurchases()
        }
    }

    private func installDriver() {
        DriverInstaller.install { result in
            switch result {
            case .success:
                appState.isDriverInstalled = true
            case .failure:
                appState.isDriverInstalled = DriverInstaller.isInstalled
            }
        }
    }

    private func uninstallDriver() {
        DriverInstaller.uninstall { result in
            switch result {
            case .success:
                appState.isDriverInstalled = false
            case .failure:
                appState.isDriverInstalled = DriverInstaller.isInstalled
            }
        }
    }

    private func checkForUpdates() {
        // In production, this calls SUUpdater.shared().checkForUpdates(self)
        // via the Sparkle framework integration
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

}

// MARK: - Audio Device Model

struct AudioDevice: Identifiable {
    let id: UInt32
    let name: String
}

// MARK: - Settings Section Component

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)

            content()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
