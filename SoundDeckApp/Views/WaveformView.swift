import SwiftUI

/// Scrolling mirrored waveform visualization driven by `appState.waveformLevels`.
/// Draws bars above and below a center line with a green-to-cyan gradient.
struct WaveformView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            let levels = appState.waveformLevels
            let barWidth = geometry.size.width / CGFloat(levels.count)
            let halfHeight = geometry.size.height / 2.0

            ZStack {
                // Center line
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 1)
                    .position(x: geometry.size.width / 2, y: halfHeight)

                // Waveform bars
                Path { path in
                    for (index, level) in levels.enumerated() {
                        let x = CGFloat(index) * barWidth
                        let barHeight = CGFloat(level) * halfHeight

                        // Bar above center
                        path.addRect(CGRect(
                            x: x,
                            y: halfHeight - barHeight,
                            width: max(barWidth - 0.5, 0.5),
                            height: barHeight
                        ))

                        // Mirror below center
                        path.addRect(CGRect(
                            x: x,
                            y: halfHeight,
                            width: max(barWidth - 0.5, 0.5),
                            height: barHeight
                        ))
                    }
                }
                .fill(
                    LinearGradient(
                        colors: [.green, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
        }
    }
}

#Preview {
    WaveformView()
        .frame(width: 300, height: 20)
        .padding()
        .background(Color.black)
        .environmentObject({
            let state = AppState()
            state.waveformLevels = (0..<60).map { _ in Float.random(in: 0...0.8) }
            return state
        }())
}
