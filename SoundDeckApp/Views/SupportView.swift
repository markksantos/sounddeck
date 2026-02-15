import SwiftUI

struct SupportView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Support")
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
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 16) {
                    // Quick Help
                    supportSection(title: "Quick Help", icon: "questionmark.circle") {
                        VStack(alignment: .leading, spacing: 12) {
                            helpItem(
                                question: "How do I use SoundDeck with Zoom/Meet/Discord?",
                                answer: "Open your app's audio settings and select \"SoundDeck Virtual Mic\" as your microphone input. SoundDeck passes your voice through and mixes in any sounds you trigger."
                            )
                            Divider().opacity(0.3)
                            helpItem(
                                question: "The virtual mic isn't showing up",
                                answer: "Go to Settings > Audio Driver and click \"Install Driver\" or \"Reinstall Driver\". This requires your admin password. After installation, restart the app you're using."
                            )
                            Divider().opacity(0.3)
                            helpItem(
                                question: "I hear a beep every 60 seconds",
                                answer: "The watermark beep plays on the Free plan. Upgrade to SoundDeck Pro to remove it."
                            )
                            Divider().opacity(0.3)
                            helpItem(
                                question: "Sounds aren't playing into my call",
                                answer: "Make sure the audio engine is running (green dot in the bottom-right of the popover) and that the other app is using \"SoundDeck Virtual Mic\" as its input."
                            )
                            Divider().opacity(0.3)
                            helpItem(
                                question: "How do I uninstall SoundDeck?",
                                answer: "Go to Settings > Audio Driver > Uninstall to remove the virtual audio driver, then move SoundDeck.app to Trash."
                            )
                        }
                    }

                    // Contact
                    supportSection(title: "Contact Us", icon: "envelope") {
                        VStack(spacing: 10) {
                            contactRow(
                                icon: "envelope.fill",
                                label: "Email Support",
                                detail: "support@sounddeck.app"
                            ) {
                                if let url = URL(string: "mailto:support@sounddeck.app") {
                                    NSWorkspace.shared.open(url)
                                }
                            }

                            contactRow(
                                icon: "globe",
                                label: "Website",
                                detail: "sounddeck.app"
                            ) {
                                if let url = URL(string: "https://sounddeck.app") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                        }
                    }

                    // System Info
                    supportSection(title: "System Info", icon: "info.circle") {
                        VStack(spacing: 6) {
                            infoRow(label: "App Version", value: appVersion)
                            infoRow(label: "macOS", value: ProcessInfo.processInfo.operatingSystemVersionString)
                            infoRow(label: "Plan", value: appState.isPro ? "Pro" : "Free")
                            infoRow(label: "Driver", value: appState.isDriverInstalled ? "Installed" : "Not Installed")
                            infoRow(label: "Audio Engine", value: appState.isEngineRunning ? "Running" : "Stopped")
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(width: 460, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Components

    private func supportSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.system(size: 13, weight: .semibold))

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

    private func helpItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(question)
                .font(.system(size: 12, weight: .medium))
            Text(answer)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
    }

    private func contactRow(
        icon: String,
        label: String,
        detail: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.accentColor)
                    .frame(width: 20)

                Text(label)
                    .font(.system(size: 12))

                Spacer()

                Text(detail)
                    .font(.system(size: 11))
                    .foregroundColor(.accentColor)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, design: .monospaced))
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
