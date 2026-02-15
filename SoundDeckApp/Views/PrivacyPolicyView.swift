import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header("Privacy Policy")

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Last updated: February 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    section("Overview") {
                        "SoundDeck is designed with privacy in mind. We collect minimal data and never sell your personal information to third parties."
                    }

                    section("Audio Data") {
                        "All audio processing happens locally on your Mac. Your microphone audio, sound effects, and voice changer output are processed entirely on-device and are never transmitted to our servers. We do not record, store, or have access to any audio that passes through SoundDeck."
                    }

                    section("Subscription Data") {
                        "Subscriptions are handled entirely through Apple's App Store. We do not collect or store your payment information. Apple processes all transactions and manages your subscription. We receive only a confirmation of your subscription status — no payment details."
                    }

                    section("Sound Library") {
                        "When you browse the Pro Sound Library, search queries are sent to a third-party API (MyInstants) to fetch sound results. We do not log or store your search queries. Downloaded sounds are stored locally on your Mac."
                    }

                    section("Local Storage") {
                        "SoundDeck stores your preferences, sound library, folder organization, and hotkey assignments locally in ~/Library/Application Support/SoundDeck/. This data stays on your device and is not synced to any server."
                    }

                    section("Analytics & Crash Reporting") {
                        "SoundDeck does not include any analytics, tracking, or crash reporting frameworks. We do not collect usage data, device information, or crash logs."
                    }

                    section("Third-Party Services") {
                        """
                        SoundDeck uses the following third-party services:

                        \u{2022} Apple StoreKit — Subscription management
                        \u{2022} Sparkle — Update checking (sends your app version to check for updates)
                        \u{2022} MyInstants API — Pro Sound Library browsing (sends search queries)

                        Each service has its own privacy policy and data handling practices.
                        """
                    }

                    section("Children's Privacy") {
                        "SoundDeck is not directed at children under 13. We do not knowingly collect personal information from children."
                    }

                    section("Changes to This Policy") {
                        "We may update this Privacy Policy from time to time. Changes will be reflected in the app with an updated date. Continued use of SoundDeck after changes constitutes acceptance of the updated policy."
                    }

                    section("Contact") {
                        "If you have questions about this Privacy Policy, please reach out via our support page or email support@sounddeck.app."
                    }
                }
                .padding(24)
            }
        }
        .frame(width: 460, height: 520)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func header(_ title: String) -> some View {
        HStack {
            Text(title)
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
    }

    private func section(_ title: String, body: () -> String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
            Text(body())
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
    }
}
