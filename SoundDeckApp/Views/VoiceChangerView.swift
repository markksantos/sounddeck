import SwiftUI

/// Voice pitch-shift controls presented as a sheet.
/// Slider from -12 to +12 semitones with preset buttons.
struct VoiceChangerView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    /// Map cents to semitones for display.
    private var semitones: Float {
        appState.pitchShiftCents / 100.0
    }

    @State private var showUpgrade = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Voice Changer")
                    .font(.headline)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            if appState.canUseVoiceChanger {
                // Enable Toggle
                HStack {
                    Label("Enabled", systemImage: "waveform.circle.fill")
                        .foregroundColor(appState.isVoiceChangerEnabled ? .purple : .secondary)

                    Spacer()

                    Toggle("", isOn: $appState.isVoiceChangerEnabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .tint(.purple)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.05))
                )

                // Pitch Display
                VStack(spacing: 4) {
                    Text(pitchDisplayText)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(appState.isVoiceChangerEnabled ? pitchColor : .secondary)

                    Text("semitones")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                // Slider
                VStack(spacing: 6) {
                    Slider(
                        value: $appState.pitchShiftCents,
                        in: -1200...1200,
                        step: 100
                    ) {
                        Text("Pitch")
                    } minimumValueLabel: {
                        Text("-12")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Text("+12")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .tint(.purple)
                    .disabled(!appState.isVoiceChangerEnabled)
                }

                // Presets
                HStack(spacing: 8) {
                    presetButton(label: "Deep", cents: -600, icon: "arrow.down.circle.fill")
                    presetButton(label: "Normal", cents: 0, icon: "circle.fill")
                    presetButton(label: "High", cents: 600, icon: "arrow.up.circle.fill")
                    presetButton(label: "Chipmunk", cents: 1200, icon: "hare.fill")
                }
                .disabled(!appState.isVoiceChangerEnabled)
            } else {
                voiceChangerLockedView
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
                .environmentObject(appState)
        }
    }

    // MARK: - Locked State

    private var voiceChangerLockedView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))

            Text("Voice Changer is a Pro Feature")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            Text("Shift your voice pitch in real time during calls.\nUpgrade to Pro to unlock.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Button {
                showUpgrade = true
            } label: {
                Text("Upgrade to Pro")
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.3))
                    )
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Preset Button

    private func presetButton(label: String, cents: Float, icon: String) -> some View {
        let isSelected = appState.pitchShiftCents == cents

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                appState.pitchShiftCents = cents
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))

                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.purple.opacity(0.3) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(isSelected ? .purple : .secondary)
    }

    // MARK: - Helpers

    private var pitchDisplayText: String {
        let st = semitones
        if st == 0 {
            return "0"
        } else if st > 0 {
            return "+\(String(format: "%.0f", st))"
        } else {
            return String(format: "%.0f", st)
        }
    }

    private var pitchColor: Color {
        if semitones == 0 {
            return .primary
        } else if semitones > 0 {
            return .purple
        } else {
            return .blue
        }
    }
}

#Preview {
    VoiceChangerView()
        .environmentObject({
            let state = AppState()
            state.isVoiceChangerEnabled = true
            state.pitchShiftCents = 600
            return state
        }())
}
