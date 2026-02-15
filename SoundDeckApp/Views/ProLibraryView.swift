import SwiftUI
import os.log

/// Browsable sound library for Pro subscribers, powered by the MyInstants API.
/// Presented as a sheet with search, category tabs, and a scrollable grid.
struct ProLibraryView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedTab: Tab = .trending
    @State private var sounds: [MyInstantsService.Sound] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var downloadingIDs: Set<String> = []
    @State private var downloadedIDs: Set<String> = []
    @State private var previewingID: String?
    @State private var searchTask: Task<Void, Never>?

    private let service = MyInstantsService.shared
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "ProLibraryView")
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    enum Tab: String, CaseIterable {
        case trending = "Trending"
        case popular = "Popular"
        case recent = "Recent"
        case search = "Search"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchBar
            tabBar
            Divider().opacity(0.3)
            contentArea
        }
        .frame(width: 500, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .task {
            await loadSounds()
        }
        .onDisappear {
            // Cancel any pending tasks and stop preview
            searchTask?.cancel()
            searchTask = nil
            if previewingID != nil {
                if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                    appDelegate.previewEngine.stopPreview()
                }
                previewingID = nil
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.purple)

                Text("Pro Sound Library")
                    .font(.title2.bold())
            }

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
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            TextField("Search sounds...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .onSubmit {
                    performSearch()
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    if selectedTab == .search {
                        selectedTab = .trending
                        searchTask?.cancel()
                        searchTask = Task { await loadSounds() }
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(Tab.allCases, id: \.self) { tab in
                if tab == .search && searchText.isEmpty { EmptyView() } else {
                    tabButton(tab)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button {
            selectedTab = tab
            searchTask?.cancel()
            searchTask = Task { await loadSounds() }
        } label: {
            Text(tab.rawValue)
                .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular))
                .foregroundColor(selectedTab == tab ? .white : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(selectedTab == tab ? Color.purple.opacity(0.6) : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        Group {
            if isLoading {
                loadingView
            } else if let errorMessage {
                errorView(errorMessage)
            } else if sounds.isEmpty {
                emptyView
            } else {
                soundGrid
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading sounds...")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.6))
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Try Again") {
                searchTask?.cancel()
                searchTask = Task { await loadSounds() }
            }
            .buttonStyle(.bordered)
            .font(.system(size: 12))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.6))
            Text(selectedTab == .search ? "No sounds found for \"\(searchText)\"" : "No sounds available.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Sound Grid

    private var soundGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(sounds) { sound in
                    soundCard(sound)
                }
            }
            .padding(20)
        }
    }

    private func soundCard(_ sound: MyInstantsService.Sound) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(sound.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 30)

            // Tags (if available)
            if let tags = sound.tags, !tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(Color.white.opacity(0.06))
                            )
                    }
                }
            }

            Spacer(minLength: 0)

            // Action buttons
            HStack(spacing: 6) {
                // Preview button
                Button {
                    previewSound(sound)
                } label: {
                    Image(systemName: previewingID == sound.id ? "stop.fill" : "play.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.purple.opacity(0.7)))
                }
                .buttonStyle(.plain)
                .help("Preview")

                Spacer()

                // Add to Library button
                if downloadedIDs.contains(sound.id) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                        .help("Added to library")
                } else if downloadingIDs.contains(sound.id) {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 16, height: 16)
                } else {
                    Button {
                        addToLibrary(sound)
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help("Add to Library")
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: - Actions

    private func performSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        selectedTab = .search
        searchTask?.cancel()
        searchTask = Task { await loadSounds() }
    }

    private func loadSounds() async {
        isLoading = true
        errorMessage = nil

        do {
            switch selectedTab {
            case .trending:
                sounds = try await service.trending()
            case .popular:
                sounds = try await service.best()
            case .recent:
                sounds = try await service.recent()
            case .search:
                let trimmed = searchText.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else {
                    sounds = []
                    isLoading = false
                    return
                }
                sounds = try await service.search(query: trimmed)
            }
        } catch {
            logger.error("Failed to load sounds: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            sounds = []
        }

        isLoading = false
    }

    private func previewSound(_ sound: MyInstantsService.Sound) {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }

        // If already previewing this sound, stop it
        if previewingID == sound.id {
            appDelegate.previewEngine.stopPreview()
            previewingID = nil
            return
        }

        // Download to temp and preview
        previewingID = sound.id

        Task {
            do {
                let tempDir = FileManager.default.temporaryDirectory
                let tempFile = tempDir.appendingPathComponent("preview_\(sound.id).mp3")
                try await service.downloadSound(from: sound.mp3, to: tempFile)

                // PreviewEngine expects a relative path via fileURL; use a direct approach
                await MainActor.run {
                    previewSoundFile(tempFile, engine: appDelegate.previewEngine)
                }
            } catch {
                logger.error("Preview download failed: \(error.localizedDescription)")
                await MainActor.run { previewingID = nil }
            }
        }
    }

    /// Preview an audio file directly via the PreviewEngine using AVFoundation.
    private func previewSoundFile(_ fileURL: URL, engine: PreviewEngine) {
        // Create a SoundItem that points to the absolute temp path.
        // SoundItem.fileURL prepends appSupportDirectory, so we use a workaround:
        // Write a small helper that plays directly. Since PreviewEngine.preview
        // uses sound.fileURL which builds from SoundStore.appSupportDirectory,
        // we instead compute a relative path from that directory.
        let appSupport = SoundStore.appSupportDirectory.path
        let filePath = fileURL.path

        // If the file is outside app support, copy it into a temp location inside app support
        if !filePath.hasPrefix(appSupport) {
            let destName = fileURL.lastPathComponent
            let destURL = SoundStore.audioDirectory.appendingPathComponent(destName)
            let fm = FileManager.default
            do {
                if fm.fileExists(atPath: destURL.path) {
                    try fm.removeItem(at: destURL)
                }
                try fm.copyItem(at: fileURL, to: destURL)

                let relativePath = "Audio/\(destName)"
                let tempSound = SoundItem(
                    name: "Preview",
                    fileName: relativePath,
                    color: .purple,
                    iconName: "waveform"
                )
                engine.preview(sound: tempSound)

                // Clean up preview file after a delay
                DispatchQueue.global().asyncAfter(deadline: .now() + 15) {
                    try? fm.removeItem(at: destURL)
                }
            } catch {
                logger.error("Failed to stage preview file: \(error.localizedDescription)")
                previewingID = nil
            }
        }
    }

    private func addToLibrary(_ sound: MyInstantsService.Sound) {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { return }

        downloadingIDs.insert(sound.id)

        Task {
            do {
                let tempDir = FileManager.default.temporaryDirectory
                let sanitizedTitle = sound.title
                    .replacingOccurrences(of: "/", with: "-")
                    .replacingOccurrences(of: ":", with: "-")
                let tempFile = tempDir.appendingPathComponent("\(sanitizedTitle)_\(sound.id).mp3")

                try await service.downloadSound(from: sound.mp3, to: tempFile)

                // Import via SoundStore on the main thread
                await MainActor.run {
                    let imported = appDelegate.soundStore.importSound(url: tempFile)

                    downloadingIDs.remove(sound.id)

                    if imported != nil {
                        downloadedIDs.insert(sound.id)
                        logger.info("Added to library: \(sound.title)")
                    }

                    // Clean up temp file
                    try? FileManager.default.removeItem(at: tempFile)
                }
            } catch {
                logger.error("Download failed for \(sound.title): \(error.localizedDescription)")
                await MainActor.run {
                    downloadingIDs.remove(sound.id)
                }
            }
        }
    }
}

#Preview {
    ProLibraryView()
        .environmentObject(AppState())
}
