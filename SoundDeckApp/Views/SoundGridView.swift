import SwiftUI
import UniformTypeIdentifiers

/// Scrollable grid of sound pads with a trailing "Add Sound" button.
struct SoundGridView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.audioActions) private var audioActions

    @State private var showUpgradeLimitAlert = false
    @State private var showUpgrade = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        Group {
            if appState.filteredSounds.isEmpty {
                emptyState
            } else {
                soundGrid
            }
        }
        .alert("Sound Limit Reached", isPresented: $showUpgradeLimitAlert) {
            Button("Upgrade") {
                showUpgrade = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Free plan is limited to \(appState.maxFreeSounds) sounds. Upgrade to Pro for unlimited sounds.")
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
                .environmentObject(appState)
        }
    }

    // MARK: - Sound Grid

    private var soundGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(appState.filteredSounds) { sound in
                    SoundPadView(sound: sound)
                }

                addSoundButton
            }
            .padding(8)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "waveform.badge.plus")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(.secondary.opacity(0.5))

            Text(appState.selectedFolderID != nil && !appState.sounds.isEmpty
                 ? "No Sounds in This Folder"
                 : "No Sounds Yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(appState.selectedFolderID != nil && !appState.sounds.isEmpty
                 ? "Drag sounds here or tap Add\nto add sounds to this folder."
                 : "Add audio files to start building\nyour soundboard.")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)

            Button {
                if appState.canAddMoreSounds {
                    audioActions.pickAndImportSounds(appState.selectedFolderID)
                } else {
                    showUpgradeLimitAlert = true
                }
            } label: {
                Label("Add Sound", systemImage: "plus.circle.fill")
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.2))
                    )
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Add Sound Button

    private var addSoundButton: some View {
        Button {
            if appState.canAddMoreSounds {
                audioActions.pickAndImportSounds(appState.selectedFolderID)
            } else {
                showUpgradeLimitAlert = true
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)

                Text("Add")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color.white.opacity(0.12), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
            )
        }
        .buttonStyle(.plain)
    }

}

#Preview {
    SoundGridView()
        .frame(width: 300, height: 400)
        .environmentObject(AppState())
}
