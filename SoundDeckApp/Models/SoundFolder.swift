import SwiftUI

/// A folder used to organize sounds in the sidebar.
struct SoundFolder: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var iconName: String
    var colorHex: String

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "folder.fill",
        color: Color = .accentColor
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = color.hexString
    }

    var color: Color {
        get { Color(hex: colorHex) ?? .accentColor }
        set { colorHex = newValue.hexString }
    }
}
