import SwiftUI

/// Narrow sidebar listing "All Sounds" and user-created folders.
/// Selection filters the sound grid.
struct FolderSidebarView: View {
    @EnvironmentObject private var appState: AppState

    @State private var showAddFolderAlert = false
    @State private var newFolderName = ""
    @State private var renamingFolderID: UUID?
    @State private var renameFolderText = ""
    @State private var folderPendingDeletion: SoundFolder?
    @State private var showProLibrary = false
    @State private var showUpgrade = false
    private let maxFolderNameLength = 80

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 2) {
                    // All Sounds
                    allSoundsRow

                    // Pro Library
                    proLibraryRow

                    Divider()
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)

                    // Folders
                    ForEach(appState.folders) { folder in
                        folderRow(folder)
                    }
                }
                .padding(.vertical, 8)
            }

            Divider()

            // Add Folder Button
            Button {
                newFolderName = ""
                showAddFolderAlert = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 11))
                    Text("Folder")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .background(Color.white.opacity(0.02))
        .alert("New Folder", isPresented: $showAddFolderAlert) {
            TextField("Folder Name", text: $newFolderName)
            Button("Cancel", role: .cancel) {}
            Button("Create") {
                let trimmed = newFolderName.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                let folder = SoundFolder(
                    name: String(trimmed.prefix(maxFolderNameLength)),
                    iconName: "folder.fill",
                    color: randomFolderColor()
                )
                appState.folders.append(folder)
            }
        }
        .alert("Rename Folder", isPresented: Binding(
            get: { renamingFolderID != nil },
            set: { if !$0 { renamingFolderID = nil } }
        )) {
            TextField("Name", text: $renameFolderText)
            Button("Cancel", role: .cancel) { renamingFolderID = nil }
            Button("Rename") {
                let trimmed = renameFolderText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    renamingFolderID = nil
                    return
                }
                if let id = renamingFolderID,
                   let index = appState.folders.firstIndex(where: { $0.id == id }) {
                    appState.folders[index].name = String(trimmed.prefix(maxFolderNameLength))
                }
                renamingFolderID = nil
            }
        }
        .alert("Delete Folder?", isPresented: Binding(
            get: { folderPendingDeletion != nil },
            set: { if !$0 { folderPendingDeletion = nil } }
        )) {
            Button("Cancel", role: .cancel) { folderPendingDeletion = nil }
            Button("Delete", role: .destructive) {
                if let folder = folderPendingDeletion {
                    deleteFolder(folder)
                }
                folderPendingDeletion = nil
            }
        } message: {
            Text(folderDeleteMessage)
        }
        .sheet(isPresented: $showProLibrary) {
            ProLibraryView()
                .environmentObject(appState)
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
                .environmentObject(appState)
        }
    }

    // MARK: - All Sounds Row

    private var allSoundsRow: some View {
        let isSelected = appState.selectedFolderID == nil
        return Button {
            appState.selectedFolderID = nil
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                Text("All")
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)

                Spacer()

                Text("\(appState.sounds.count)")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(
                        Capsule().fill(Color.white.opacity(0.08))
                    )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pro Library Row

    private var proLibraryRow: some View {
        Button {
            if appState.canAccessProLibrary {
                showProLibrary = true
            } else {
                showUpgrade = true
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: appState.canAccessProLibrary ? "crown.fill" : "lock.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.purple)

                Text("Pro Library")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.clear)
            )
            .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Folder Row

    private func folderRow(_ folder: SoundFolder) -> some View {
        let isSelected = appState.selectedFolderID == folder.id
        let count = appState.sounds.filter { $0.folderID == folder.id }.count

        return Button {
            appState.selectedFolderID = folder.id
        } label: {
            HStack(spacing: 6) {
                Image(systemName: folder.iconName)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? folder.color : .secondary)

                Text(folder.name)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                Text("\(count)")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(
                        Capsule().fill(Color.white.opacity(0.08))
                    )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? folder.color.opacity(0.15) : Color.clear)
            )
            .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                renameFolderText = folder.name
                renamingFolderID = folder.id
            } label: {
                Label("Rename", systemImage: "pencil")
            }

            Button(role: .destructive) {
                folderPendingDeletion = folder
            } label: {
                Label("Delete Folder", systemImage: "trash")
            }
        }
    }

    // MARK: - Helpers

    private func randomFolderColor() -> Color {
        let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .cyan, .indigo, .mint, .teal, .red]
        return colors.randomElement() ?? .blue
    }

    private var folderDeleteMessage: String {
        guard let folder = folderPendingDeletion else { return "" }
        let count = appState.sounds.filter { $0.folderID == folder.id }.count

        if count == 0 {
            return "This removes the folder. No sounds will be deleted."
        }

        let noun = count == 1 ? "sound" : "sounds"
        return "This removes the folder and moves \(count) \(noun) back to All Sounds. No audio files will be deleted."
    }

    private func deleteFolder(_ folder: SoundFolder) {
        for i in appState.sounds.indices where appState.sounds[i].folderID == folder.id {
            appState.sounds[i].folderID = nil
        }
        appState.folders.removeAll { $0.id == folder.id }
        if appState.selectedFolderID == folder.id {
            appState.selectedFolderID = nil
        }
    }
}

#Preview {
    FolderSidebarView()
        .frame(width: 100, height: 400)
        .environmentObject({
            let state = AppState()
            state.folders = [
                SoundFolder(name: "Effects", iconName: "bolt.fill", color: .yellow),
                SoundFolder(name: "Music", iconName: "music.note", color: .purple),
            ]
            return state
        }())
}
