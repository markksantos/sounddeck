import SwiftUI
import UniformTypeIdentifiers

/// Scrollable grid of sound pads with search, sorting, drag import, and a trailing Add Sound button.
struct SoundGridView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.audioActions) private var audioActions

    @AppStorage("SoundDeck_SoundSortOption") private var soundSortOptionRaw = SortOption.manual.rawValue

    @State private var searchQuery = ""
    @State private var showUpgradeLimitAlert = false
    @State private var showUpgrade = false
    @State private var isDropTargeted = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    private enum SortOption: String, CaseIterable, Identifiable {
        case manual
        case name
        case volume

        var id: String { rawValue }

        var title: String {
            switch self {
            case .manual: return "Manual"
            case .name: return "Name"
            case .volume: return "Volume"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !appState.filteredSounds.isEmpty {
                toolbar
            }

            Group {
                if displayedSounds.isEmpty {
                    emptyState
                } else {
                    soundGrid
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(dropOverlay)
        .onDrop(of: [.audio, .fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
        }
        .alert("Sound Limit Reached", isPresented: $showUpgradeLimitAlert) {
            Button("Upgrade") {
                showUpgrade = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Free plan includes the bundled default sounds and is limited to \(appState.maxFreeSounds) custom sounds. Upgrade to Pro for unlimited custom sounds.")
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
                .environmentObject(appState)
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        VStack(spacing: 6) {
            TextField("Search sounds", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 11))

            HStack(spacing: 6) {
                Text("Sort")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Picker("Sort", selection: $soundSortOptionRaw) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.title).tag(option.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()

                Spacer()

                Text("\(displayedSounds.count)")
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Sound Grid

    private var soundGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(displayedSounds) { sound in
                    SoundPadView(sound: sound)
                }

                addSoundButton
            }
            .padding(8)
        }
    }

    private var displayedSounds: [SoundItem] {
        var sounds = appState.filteredSounds

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            sounds = sounds.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }

        switch SortOption(rawValue: soundSortOptionRaw) ?? .manual {
        case .manual:
            return sounds
        case .name:
            return sounds.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .volume:
            return sounds.sorted { $0.volume > $1.volume }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.audio.identifier) ||
               provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

                    let audioExtensions: Set<String> = ["mp3", "wav", "m4a", "aac", "aif", "aiff", "caf"]
                    guard audioExtensions.contains(url.pathExtension.lowercased()) else { return }

                    DispatchQueue.main.async {
                        guard appState.canAddMoreSounds else {
                            showUpgradeLimitAlert = true
                            return
                        }
                        audioActions.importSound(url, appState.selectedFolderID)
                    }
                }
                handled = true
            }
        }
        return handled
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: searchQuery.isEmpty ? "waveform.badge.plus" : "magnifyingglass")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(.secondary.opacity(0.5))

            Text(emptyStateTitle)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(emptyStateMessage)
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)

            if searchQuery.isEmpty {
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
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateTitle: String {
        if !searchQuery.isEmpty {
            return "No Matching Sounds"
        }
        return appState.selectedFolderID != nil && !appState.sounds.isEmpty
            ? "No Sounds in This Folder"
            : "No Sounds Yet"
    }

    private var emptyStateMessage: String {
        if !searchQuery.isEmpty {
            return "Try a different search or clear the field."
        }
        return appState.selectedFolderID != nil && !appState.sounds.isEmpty
            ? "Drag audio files here or tap Add\nto add sounds to this folder."
            : "Drag audio files here or tap Add\nto start building your soundboard."
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

    @ViewBuilder
    private var dropOverlay: some View {
        if isDropTargeted {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.08))
                )
                .overlay {
                    Label("Drop audio to import", systemImage: "arrow.down.doc.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: Capsule())
                }
                .padding(6)
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    SoundGridView()
        .frame(width: 300, height: 400)
        .environmentObject(AppState())
}
