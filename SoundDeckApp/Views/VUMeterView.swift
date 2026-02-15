import SwiftUI

/// Compact horizontal audio level meter with 20 colored segments.
/// Green (0-60%), yellow (60-80%), red (80-100%).
struct VUMeterView: View {
    @EnvironmentObject private var appState: AppState

    private let segmentCount = 20
    private let segmentSpacing: CGFloat = 1.5
    private let cornerRadius: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            let segmentWidth = (geometry.size.width - CGFloat(segmentCount - 1) * segmentSpacing) / CGFloat(segmentCount)
            let litSegments = Int(appState.inputLevel * Float(segmentCount))

            HStack(spacing: segmentSpacing) {
                ForEach(0..<segmentCount, id: \.self) { index in
                    let isLit = index < litSegments
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isLit ? segmentColor(for: index) : Color.white.opacity(0.08))
                        .frame(width: segmentWidth)
                }
            }
            .animation(.interpolatingSpring(stiffness: 300, damping: 24), value: appState.inputLevel)
        }
    }

    /// Returns the appropriate color for a segment at the given index.
    private func segmentColor(for index: Int) -> Color {
        let fraction = Double(index) / Double(segmentCount)
        if fraction < 0.6 {
            return Color.green
        } else if fraction < 0.8 {
            return Color.yellow
        } else {
            return Color.red
        }
    }
}

#Preview {
    VUMeterView()
        .frame(width: 300, height: 14)
        .padding()
        .environmentObject({
            let state = AppState()
            state.inputLevel = 0.65
            return state
        }())
}
