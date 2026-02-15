import SwiftUI

/// Root view displayed inside the menu bar popover.
/// Fixed at 400x500, dark-themed with a top bar, sidebar + grid, and bottom bar.
struct PopoverContentView: View {
    @EnvironmentObject private var appState: AppState

    @State private var showSettings = false
    @State private var showVoiceChanger = false
    @State private var showUpgrade = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Bar
            topBar

            Divider()
                .background(Color.white.opacity(0.1))

            // MARK: - Main Content
            HStack(spacing: 0) {
                FolderSidebarView()
                    .frame(width: 100)

                Divider()
                    .background(Color.white.opacity(0.1))

                SoundGridView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // MARK: - Bottom Bar
            bottomBar
        }
        .frame(width: 400, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showVoiceChanger) {
            VoiceChangerView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
                .environmentObject(appState)
        }
        .overlay {
            if appState.showOnboarding {
                OnboardingView()
                    .environmentObject(appState)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 10) {
            // Waveform
            WaveformView()
                .frame(maxWidth: .infinity)
                .frame(height: 20)

            // SFX Monitor Toggle
            Button {
                appState.isSFXMonitorEnabled.toggle()
            } label: {
                Image(systemName: appState.isSFXMonitorEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(appState.isSFXMonitorEnabled ? .cyan : .primary)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(appState.isSFXMonitorEnabled ? Color.cyan.opacity(0.2) : Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .help(appState.isSFXMonitorEnabled ? "SFX Monitor On" : "SFX Monitor Off")

            // Voice Monitor Toggle
            Button {
                appState.isVoiceMonitorEnabled.toggle()
            } label: {
                Image(systemName: "headphones")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(appState.isVoiceMonitorEnabled ? .orange : .primary)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(appState.isVoiceMonitorEnabled ? Color.orange.opacity(0.2) : Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .help(appState.isVoiceMonitorEnabled ? "Voice Monitor On" : "Voice Monitor Off")

            // Mute Button
            Button {
                appState.isMuted.toggle()
            } label: {
                Image(systemName: appState.isMuted ? "mic.slash.fill" : "mic.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(appState.isMuted ? .red : .primary)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(appState.isMuted ? Color.red.opacity(0.2) : Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .help(appState.isMuted ? "Unmute Microphone" : "Mute Microphone")

            // Voice Changer Toggle
            Button {
                if appState.canUseVoiceChanger {
                    showVoiceChanger.toggle()
                } else {
                    showUpgrade = true
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(appState.isVoiceChangerEnabled ? .purple : .primary)

                    if !appState.canUseVoiceChanger {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 7))
                            .foregroundColor(.secondary)
                            .offset(x: 3, y: -3)
                    }
                }
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(appState.isVoiceChangerEnabled ? Color.purple.opacity(0.2) : Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .help("Voice Changer")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            // Settings
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings")

            Spacer()

            // Plan Status
            planBadge

            Spacer()

            // Engine status indicator
            Circle()
                .fill(appState.isEngineRunning ? Color.green : Color.red.opacity(0.6))
                .frame(width: 7, height: 7)
                .help(appState.isEngineRunning ? "Audio Engine Running" : "Audio Engine Stopped")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var planBadge: some View {
        if appState.isPro {
            Label("Pro", systemImage: "crown.fill")
                .font(.caption2.weight(.semibold))
                .foregroundColor(.yellow.opacity(0.9))
        } else {
            Button {
                showUpgrade = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 10))
                    Text("Upgrade")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    PopoverContentView()
        .environmentObject(AppState())
}
