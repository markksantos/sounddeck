// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SoundDeck",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SoundDeckCommon", targets: ["SoundDeckCommon"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "2.0.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.5.0"),
    ],
    targets: [
        .target(
            name: "SoundDeckCommon",
            path: "SoundDeckCommon/Sources",
            publicHeadersPath: "../include/SoundDeckCommon"
        ),
        .testTarget(
            name: "SoundDeckTests",
            dependencies: ["SoundDeckCommon"],
            path: "Tests/SoundDeckTests"
        ),
    ]
)
