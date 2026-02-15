import SwiftUI
import KeyboardShortcuts

/// A single sound pad in the user's library.
struct SoundItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var fileName: String        // relative to app support directory
    var colorHex: String        // hex color string
    var iconName: String        // SF Symbol name
    var hotkeyName: String?     // KeyboardShortcuts.Name raw value
    var folderID: UUID?
    var trimStart: Double       // seconds
    var trimEnd: Double         // seconds, 0 = no trim (use full duration)
    var volume: Float           // 0.0–1.0, default 1.0

    init(
        id: UUID = UUID(),
        name: String,
        fileName: String,
        color: Color = .blue,
        iconName: String = "speaker.wave.2.fill",
        hotkeyName: String? = nil,
        folderID: UUID? = nil,
        trimStart: Double = 0.0,
        trimEnd: Double = 0.0,
        volume: Float = 1.0
    ) {
        self.id = id
        self.name = name
        self.fileName = fileName
        self.colorHex = color.hexString
        self.iconName = iconName
        self.hotkeyName = hotkeyName
        self.folderID = folderID
        self.trimStart = trimStart
        self.trimEnd = trimEnd
        self.volume = volume
    }

    // MARK: - Computed

    var color: Color {
        get { Color(hex: colorHex) ?? .blue }
        set { colorHex = newValue.hexString }
    }

    var hotkey: KeyboardShortcuts.Name? {
        guard let name = hotkeyName else { return nil }
        return KeyboardShortcuts.Name(name)
    }

    /// Full file URL within the app's Application Support directory.
    var fileURL: URL {
        SoundStore.appSupportDirectory.appendingPathComponent(fileName)
    }
}

// MARK: - Color Hex Helpers

extension Color {
    /// Returns a hex string representation suitable for persistence.
    var hexString: String {
        let nsColor = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        let r = Int(nsColor.redComponent * 255)
        let g = Int(nsColor.greenComponent * 255)
        let b = Int(nsColor.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    /// Creates a Color from a hex string like "#FF00AA".
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        guard hexSanitized.count == 6, let hexNumber = UInt64(hexSanitized, radix: 16) else {
            return nil
        }
        let r = Double((hexNumber >> 16) & 0xFF) / 255.0
        let g = Double((hexNumber >> 8) & 0xFF) / 255.0
        let b = Double(hexNumber & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
