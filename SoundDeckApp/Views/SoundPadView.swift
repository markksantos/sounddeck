import SwiftUI

/// Individual sound pad displayed in the grid.
/// Click to play into mic, long-press to preview in headphones, right-click for options.
struct SoundPadView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.audioActions) private var audioActions

    let sound: SoundItem

    @State private var isHovering = false
    @State private var isPressing = false
    @State private var showRenameAlert = false
    @State private var showColorPicker = false
    @State private var showIconPicker = false
    @State private var showTrimEditor = false
    @State private var renameText = ""

    private var isPlaying: Bool {
        appState.currentlyPlayingSoundIDs.contains(sound.id)
    }

    var body: some View {
        padContent
        .onTapGesture {
            togglePlayback()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            audioActions.preview(sound)
        }
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu { contextMenuItems }
        .alert("Rename Sound", isPresented: $showRenameAlert) {
            TextField("Name", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("Rename") {
                if let index = appState.sounds.firstIndex(where: { $0.id == sound.id }) {
                    appState.sounds[index].name = renameText
                }
            }
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(soundID: sound.id)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerSheet(soundID: sound.id)
                .environmentObject(appState)
        }
        .sheet(isPresented: $showTrimEditor) {
            if let index = appState.sounds.firstIndex(where: { $0.id == sound.id }) {
                TrimEditorView(sound: $appState.sounds[index])
            }
        }
    }

    // MARK: - Pad Content

    private var padContent: some View {
        VStack(spacing: 4) {
            Image(systemName: sound.iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)

            Text(sound.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .truncationMode(.tail)

            // Hotkey badge
            if sound.hotkeyName != nil {
                Text(sound.hotkeyName ?? "")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(sound.color.gradient)
                    .opacity(isHovering ? 0.9 : 0.75)

                // Playing glow
                if isPlaying {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(sound.color)
                        .opacity(0.3)
                        .blur(radius: 8)

                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(isHovering ? 0.2 : 0.08), lineWidth: 1)
        )
        .scaleEffect(isPlaying ? 1.04 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
        .animation(.easeInOut(duration: 0.15), value: isHovering)
    }

    // MARK: - Context Menu

    @ViewBuilder
    private var contextMenuItems: some View {
        Button {
            renameText = sound.name
            showRenameAlert = true
        } label: {
            Label("Rename", systemImage: "pencil")
        }

        Button {
            showColorPicker = true
        } label: {
            Label("Change Color", systemImage: "paintpalette")
        }

        Button {
            showIconPicker = true
        } label: {
            Label("Change Icon", systemImage: "star.square.on.square")
        }

        Divider()

        if appState.canUseTrimEditor {
            Button {
                showTrimEditor = true
            } label: {
                Label("Trim Audio", systemImage: "scissors")
            }
        } else {
            Label("Trim (Pro)", systemImage: "scissors")
                .foregroundColor(.secondary)
        }

        Divider()

        Button(role: .destructive) {
            audioActions.deleteSound(sound)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Playback

    private func togglePlayback() {
        if isPlaying {
            audioActions.stop(sound)
        } else {
            audioActions.play(sound)
        }
    }
}

// MARK: - Color Picker Sheet

struct ColorPickerSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let soundID: UUID

    private let presetColors: [Color] = [
        .red, .orange, .yellow, .green, .mint,
        .teal, .cyan, .blue, .indigo, .purple,
        .pink, .brown
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose Color")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(36), spacing: 10), count: 6), spacing: 10) {
                ForEach(presetColors, id: \.self) { color in
                    Circle()
                        .fill(color.gradient)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: currentColor == color ? 2.5 : 0)
                        )
                        .onTapGesture {
                            if let index = appState.sounds.firstIndex(where: { $0.id == soundID }) {
                                appState.sounds[index].colorHex = color.hexString
                            }
                            dismiss()
                        }
                }
            }

            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 280)
    }

    private var currentColor: Color {
        appState.sounds.first(where: { $0.id == soundID })?.color ?? .blue
    }
}

// MARK: - Icon Picker Sheet

struct IconPickerSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let soundID: UUID

    private let icons: [String] = [
        "music.note", "music.mic", "guitars.fill", "pianokeys",
        "speaker.wave.2.fill", "bell.fill", "megaphone.fill", "horn.fill",
        "waveform", "headphones", "hifispeaker.fill", "radio.fill",
        "flame.fill", "bolt.fill", "star.fill", "heart.fill",
        "hand.thumbsup.fill", "face.smiling.fill", "bubble.left.fill", "exclamationmark.triangle.fill",
        "alarm.fill", "gamecontroller.fill", "theatermasks.fill", "party.popper.fill"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose Icon")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.fixed(36), spacing: 10), count: 6), spacing: 10) {
                ForEach(icons, id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .frame(width: 36, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(currentIcon == icon ? 0.15 : 0.05))
                        )
                        .onTapGesture {
                            if let index = appState.sounds.firstIndex(where: { $0.id == soundID }) {
                                appState.sounds[index].iconName = icon
                            }
                            dismiss()
                        }
                }
            }

            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 280)
    }

    private var currentIcon: String {
        appState.sounds.first(where: { $0.id == soundID })?.iconName ?? "music.note"
    }
}

#Preview {
    let state = AppState()
    state.sounds = [
        SoundItem(name: "Airhorn", fileName: "airhorn.mp3", color: .red, iconName: "megaphone.fill"),
        SoundItem(name: "Applause", fileName: "applause.wav", color: .green, iconName: "hands.clap.fill")
    ]
    return HStack {
        SoundPadView(sound: state.sounds[0])
            .frame(width: 80)
        SoundPadView(sound: state.sounds[1])
            .frame(width: 80)
    }
    .padding()
    .environmentObject(state)
}
