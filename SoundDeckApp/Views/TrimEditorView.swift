import SwiftUI
import AVFoundation

/// Sheet for trimming a sound's start and end points.
/// Displays a waveform drawn from the audio file with draggable handles.
struct TrimEditorView: View {
    @Binding var sound: SoundItem
    @Environment(\.dismiss) private var dismiss

    @State private var waveformSamples: [Float] = []
    @State private var trimStart: Double = 0.0
    @State private var trimEnd: Double = 1.0
    @State private var isLoadingWaveform = true
    @State private var audioDuration: Double = 0.0
    @State private var isPreviewPlaying = false
    @State private var previewPlayer: AVAudioPlayer?
    @State private var errorMessage: String?

    private let waveformHeight: CGFloat = 120
    private let handleWidth: CGFloat = 12

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Trim Audio")
                    .font(.headline)

                Spacer()

                Text(sound.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Waveform + Handles
            if isLoadingWaveform {
                waveformPlaceholder
            } else if let error = errorMessage {
                errorView(error)
            } else {
                waveformEditor
            }

            // Time Labels
            HStack {
                Text(formatTime(trimStart * audioDuration))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)

                Spacer()

                let duration = (trimEnd - trimStart) * audioDuration
                Text("Duration: \(formatTime(duration))")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)

                Spacer()

                Text(formatTime(trimEnd * audioDuration))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            // Controls
            HStack(spacing: 16) {
                // Preview Button
                Button {
                    togglePreview()
                } label: {
                    Label(
                        isPreviewPlaying ? "Stop" : "Preview",
                        systemImage: isPreviewPlaying ? "stop.fill" : "play.fill"
                    )
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.15))
                    )
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Cancel", role: .cancel) {
                    stopPreview()
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Button("Save") {
                    // Convert normalized fractions back to seconds
                    sound.trimStart = trimStart * audioDuration
                    sound.trimEnd = trimEnd * audioDuration
                    stopPreview()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
        }
        .padding(20)
        .frame(width: 420, height: 300)
        .onAppear {
            loadWaveform()
        }
        .onDisappear {
            stopPreview()
        }
    }

    // MARK: - Waveform Editor

    private var waveformEditor: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let startX = CGFloat(trimStart) * totalWidth
            let endX = CGFloat(trimEnd) * totalWidth

            ZStack(alignment: .leading) {
                // Waveform background (dimmed outside trim region)
                waveformShape(in: geometry.size)
                    .fill(Color.white.opacity(0.1))

                // Active waveform region
                waveformShape(in: geometry.size)
                    .fill(Color.accentColor.opacity(0.5))
                    .mask(
                        Rectangle()
                            .offset(x: startX)
                            .frame(width: endX - startX)
                    )

                // Dimmed overlay outside trim
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: startX)

                    Spacer()

                    Rectangle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: totalWidth - endX)
                }

                // Start Handle
                trimHandle(color: .green)
                    .offset(x: startX - handleWidth / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newStart = Double(max(0, min(value.location.x, CGFloat(trimEnd) * totalWidth - 20)) / totalWidth)
                                trimStart = min(max(newStart, 0), trimEnd - 0.02)
                            }
                    )

                // End Handle
                trimHandle(color: .red)
                    .offset(x: endX - handleWidth / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newEnd = Double(min(totalWidth, max(value.location.x, CGFloat(trimStart) * totalWidth + 20)) / totalWidth)
                                trimEnd = max(min(newEnd, 1.0), trimStart + 0.02)
                            }
                    )
            }
        }
        .frame(height: waveformHeight)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Waveform Drawing

    private func waveformShape(in size: CGSize) -> Path {
        Path { path in
            guard !waveformSamples.isEmpty else { return }

            let midY = size.height / 2
            let sampleCount = waveformSamples.count
            let stepX = size.width / CGFloat(sampleCount)

            path.move(to: CGPoint(x: 0, y: midY))

            // Top half
            for i in 0..<sampleCount {
                let x = CGFloat(i) * stepX
                let amplitude = CGFloat(waveformSamples[i]) * midY * 0.9
                path.addLine(to: CGPoint(x: x, y: midY - amplitude))
            }

            // Bottom half (mirror)
            for i in stride(from: sampleCount - 1, through: 0, by: -1) {
                let x = CGFloat(i) * stepX
                let amplitude = CGFloat(waveformSamples[i]) * midY * 0.9
                path.addLine(to: CGPoint(x: x, y: midY + amplitude))
            }

            path.closeSubpath()
        }
    }

    // MARK: - Trim Handle

    private func trimHandle(color: Color) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: handleWidth, height: waveformHeight)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 0)
            .contentShape(Rectangle().size(width: handleWidth + 16, height: waveformHeight))
    }

    // MARK: - Placeholder / Error

    private var waveformPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.03))
            .frame(height: waveformHeight)
            .overlay {
                ProgressView()
                    .scaleEffect(0.8)
            }
    }

    private func errorView(_ message: String) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.03))
            .frame(height: waveformHeight)
            .overlay {
                VStack(spacing: 4) {
                    Image(systemName: "waveform.slash")
                        .foregroundColor(.secondary)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
    }

    // MARK: - Waveform Loading

    private func loadWaveform() {
        isLoadingWaveform = true

        let fileURL = sound.fileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Generate placeholder waveform for preview/demo
            generatePlaceholderWaveform()
            initTrimFromModel()
            return
        }

        Task {
            do {
                let samples = try await extractWaveformSamples(from: fileURL, count: 200)
                await MainActor.run {
                    waveformSamples = samples
                    initTrimFromModel()
                    isLoadingWaveform = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Could not load waveform"
                    isLoadingWaveform = false
                }
            }
        }
    }

    /// Convert stored seconds to normalized 0.0–1.0 fractions for the UI.
    private func initTrimFromModel() {
        guard audioDuration > 0 else {
            trimStart = 0.0
            trimEnd = 1.0
            return
        }
        trimStart = sound.trimStart / audioDuration
        trimEnd = sound.trimEnd > 0 ? sound.trimEnd / audioDuration : 1.0
    }

    private func generatePlaceholderWaveform() {
        // Generate realistic-looking placeholder data
        var samples: [Float] = []
        for i in 0..<200 {
            let t = Float(i) / 200.0
            let envelope = sin(Float.pi * t) // fade in/out shape
            let noise = Float.random(in: 0.2...1.0)
            samples.append(envelope * noise * 0.8)
        }
        waveformSamples = samples
        audioDuration = 5.0 // placeholder
        isLoadingWaveform = false
    }

    /// Reads audio samples from a file and reduces them to `count` peak values.
    private func extractWaveformSamples(from url: URL, count: Int) async throws -> [Float] {
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        let totalFrames = Int(file.length)

        audioDuration = Double(totalFrames) / format.sampleRate

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalFrames)) else {
            throw WaveformError.bufferCreationFailed
        }

        try file.read(into: buffer)

        guard let channelData = buffer.floatChannelData?[0] else {
            throw WaveformError.noChannelData
        }

        let framesPerBin = max(1, totalFrames / count)
        var peaks: [Float] = []

        for bin in 0..<count {
            let start = bin * framesPerBin
            let end = min(start + framesPerBin, totalFrames)
            var peak: Float = 0

            for frame in start..<end {
                let value = abs(channelData[frame])
                if value > peak {
                    peak = value
                }
            }
            peaks.append(peak)
        }

        // Normalize
        let maxPeak = peaks.max() ?? 1.0
        if maxPeak > 0 {
            peaks = peaks.map { $0 / maxPeak }
        }

        return peaks
    }

    // MARK: - Preview Playback

    private func togglePreview() {
        if isPreviewPlaying {
            stopPreview()
        } else {
            startPreview()
        }
    }

    private func startPreview() {
        let fileURL = sound.fileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: fileURL)
            player.currentTime = trimStart * player.duration
            player.play()
            previewPlayer = player
            isPreviewPlaying = true

            // Schedule stop at trim end
            let playDuration = (trimEnd - trimStart) * player.duration
            DispatchQueue.main.asyncAfter(deadline: .now() + playDuration) { [weak previewPlayer] in
                previewPlayer?.stop()
                isPreviewPlaying = false
            }
        } catch {
            // Silently fail -- file may not exist during development
        }
    }

    private func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
        isPreviewPlaying = false
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%d:%02d.%d", mins, secs, ms)
    }

    enum WaveformError: Error {
        case bufferCreationFailed
        case noChannelData
    }
}

#Preview {
    TrimEditorView(sound: .constant(
        SoundItem(name: "Airhorn", fileName: "airhorn.mp3", color: .red)
    ))
}
