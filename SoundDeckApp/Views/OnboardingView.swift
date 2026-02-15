import SwiftUI
import AVFoundation

/// First-run onboarding experience.
/// Four steps: Welcome, Install Driver, Microphone Permission, Quick Tutorial.
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    @State private var currentStep = 0
    @State private var isNavigatingForward = true
    @State private var isInstallingDriver = false
    @State private var isRequestingMic = false

    private let totalSteps = 4

    var body: some View {
        VStack(spacing: 0) {
            // Step Content
            Group {
                switch currentStep {
                case 0: welcomeStep
                case 1: driverStep
                case 2: microphoneStep
                case 3: tutorialStep
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(currentStep)
            .transition(.asymmetric(
                insertion: .move(edge: isNavigatingForward ? .trailing : .leading).combined(with: .opacity),
                removal: .move(edge: isNavigatingForward ? .leading : .trailing).combined(with: .opacity)
            ))

            Spacer()

            // Bottom: Progress Dots + Navigation
            VStack(spacing: 16) {
                progressDots

                navigationButtons
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: 500)
        .background(
            ZStack {
                Color(nsColor: .windowBackgroundColor)

                // Subtle gradient accent
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.08), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "speaker.wave.2.circle.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.accentColor, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Welcome to SoundDeck")
                .font(.system(size: 22, weight: .bold))

            Text("The professional soundboard for your Mac.\nPlay sounds, change your voice, and control\naudio right from your menu bar.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            VStack(alignment: .leading, spacing: 10) {
                featureRow(icon: "square.grid.2x2.fill", text: "Instant sound pad triggers")
                featureRow(icon: "waveform.circle.fill", text: "Real-time voice changer")
                featureRow(icon: "keyboard", text: "Global hotkey support")
                featureRow(icon: "mic.fill", text: "Works with any app")
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Step 2: Driver Installation

    private var driverStep: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "cpu")
                .font(.system(size: 52, weight: .light))
                .foregroundColor(.accentColor)

            Text("Install Audio Driver")
                .font(.system(size: 20, weight: .bold))

            Text("SoundDeck needs a virtual audio driver\nto route sounds into your calls and streams.\nThis is a one-time setup.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            if appState.isDriverInstalled {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 18))
                    Text("Driver installed successfully!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            } else {
                Button {
                    installDriver()
                } label: {
                    HStack(spacing: 8) {
                        if isInstallingDriver {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.down.circle.fill")
                        }
                        Text(isInstallingDriver ? "Installing..." : "Install Driver")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(width: 200)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .disabled(isInstallingDriver)
                .padding(.top, 8)

                Text("Requires administrator password")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.6))
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Step 3: Microphone Permission

    private var microphoneStep: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "mic.circle.fill")
                .font(.system(size: 52, weight: .light))
                .foregroundColor(.orange)

            Text("Microphone Access")
                .font(.system(size: 20, weight: .bold))

            Text("SoundDeck needs microphone access\nto pass your voice through to calls\nand apply voice effects.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            if appState.hasMicPermission {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 18))
                    Text("Microphone access granted!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.top, 8)
            } else {
                Button {
                    requestMicrophonePermission()
                } label: {
                    HStack(spacing: 8) {
                        if isRequestingMic {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "mic.fill")
                        }
                        Text("Grant Permission")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(width: 200)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(isRequestingMic)
                .padding(.top, 8)

                Text("You can change this in System Settings later")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.6))
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Step 4: Tutorial

    private var tutorialStep: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "hand.tap.fill")
                .font(.system(size: 52, weight: .light))
                .foregroundColor(.purple)

            Text("You're All Set!")
                .font(.system(size: 20, weight: .bold))

            Text("Here's a quick overview of your\nnew soundboard.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            VStack(alignment: .leading, spacing: 14) {
                tutorialRow(
                    icon: "square.grid.2x2.fill",
                    color: .blue,
                    title: "Sound Grid",
                    description: "Tap any pad to play a sound instantly"
                )
                tutorialRow(
                    icon: "folder.fill",
                    color: .orange,
                    title: "Folders",
                    description: "Organize sounds into custom folders"
                )
                tutorialRow(
                    icon: "waveform.circle.fill",
                    color: .purple,
                    title: "Voice Changer",
                    description: "Shift your pitch in real-time"
                )
                tutorialRow(
                    icon: "keyboard",
                    color: .green,
                    title: "Hotkeys",
                    description: "Trigger sounds from any app"
                )
            }
            .padding(.top, 4)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Components

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.accentColor)
                .frame(width: 22)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.primary.opacity(0.8))
        }
    }

    private func tutorialRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))

                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index == currentStep ? Color.accentColor : Color.white.opacity(0.15))
                    .frame(width: index == currentStep ? 8 : 6, height: index == currentStep ? 8 : 6)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button {
                    isNavigatingForward = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                } label: {
                    Text("Back")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            if currentStep < totalSteps - 1 {
                Button {
                    isNavigatingForward = true
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(skipAllowed ? "Next" : "Skip")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 11))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            } else {
                Button {
                    completeOnboarding()
                } label: {
                    Text("Get Started")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
        }
    }

    // MARK: - Actions

    private var skipAllowed: Bool {
        switch currentStep {
        case 1: return appState.isDriverInstalled
        case 2: return appState.hasMicPermission
        default: return true
        }
    }

    private func installDriver() {
        isInstallingDriver = true

        DriverInstaller.install { result in
            switch result {
            case .success:
                appState.isDriverInstalled = true
            case .failure:
                appState.isDriverInstalled = DriverInstaller.isInstalled
            }
            isInstallingDriver = false
        }
    }

    private func requestMicrophonePermission() {
        isRequestingMic = true

        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            appState.hasMicPermission = true
            isRequestingMic = false

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    appState.hasMicPermission = granted
                    isRequestingMic = false
                }
            }

        case .denied, .restricted:
            // Open System Settings for the user to grant permission manually
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                NSWorkspace.shared.open(url)
            }
            isRequestingMic = false

        @unknown default:
            isRequestingMic = false
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeOut(duration: 0.3)) {
            appState.showOnboarding = false
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
