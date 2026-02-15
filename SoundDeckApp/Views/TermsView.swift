import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header("Terms of Service")

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Last updated: February 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    section("Acceptance of Terms") {
                        "By downloading, installing, or using SoundDeck, you agree to be bound by these Terms of Service. If you do not agree, do not use the app."
                    }

                    section("License") {
                        "SoundDeck grants you a limited, non-exclusive, non-transferable license to use the application on macOS devices you own or control, subject to these terms and Apple's App Store terms."
                    }

                    section("Subscriptions") {
                        """
                        SoundDeck offers a free tier and a paid Pro subscription:

                        \u{2022} Free Plan: Limited to 8 sounds, basic hotkeys, includes watermark audio
                        \u{2022} Pro Plan: Unlimited sounds, voice changer, per-sound hotkeys, Pro sound library, trim editor, no watermark

                        Pro subscriptions are billed monthly ($4.99/month) or yearly ($29.99/year) through the Apple App Store. Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current billing period. You can manage or cancel your subscription in your Apple ID settings.
                        """
                    }

                    section("Virtual Audio Driver") {
                        "SoundDeck installs a virtual audio driver on your system to route audio. The driver requires administrator privileges to install and is placed in /Library/Audio/Plug-Ins/HAL/. You can uninstall the driver at any time through SoundDeck's settings."
                    }

                    section("Acceptable Use") {
                        """
                        You agree not to use SoundDeck to:

                        \u{2022} Violate any applicable laws or regulations
                        \u{2022} Deceive, harass, or harm others
                        \u{2022} Infringe on the intellectual property rights of others
                        \u{2022} Interfere with or disrupt any services or systems

                        You are responsible for the sounds you import and play through SoundDeck.
                        """
                    }

                    section("Pro Sound Library") {
                        "The Pro Sound Library provides access to sounds from third-party sources. These sounds are provided as-is. SoundDeck does not claim ownership of third-party sound content. You are responsible for ensuring your use of downloaded sounds complies with applicable copyright laws."
                    }

                    section("Disclaimer of Warranties") {
                        "SoundDeck is provided \"as is\" without warranties of any kind, either express or implied, including but not limited to implied warranties of merchantability, fitness for a particular purpose, and non-infringement. We do not warrant that the app will be uninterrupted, error-free, or free of harmful components."
                    }

                    section("Limitation of Liability") {
                        "To the maximum extent permitted by law, SoundDeck and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or related to your use of the app."
                    }

                    section("Changes to Terms") {
                        "We reserve the right to modify these Terms of Service at any time. Changes will take effect when posted in the updated app. Your continued use of SoundDeck after changes constitutes acceptance."
                    }

                    section("Contact") {
                        "For questions about these terms, contact us at support@sounddeck.app."
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
