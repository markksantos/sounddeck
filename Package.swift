// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SoundDeck",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SoundDeckCommon", targets: ["SoundDeckCommon"]),
    ],
    targets: [
        .target(
            name: "SoundDeckCommon",
            path: "SoundDeckCommon",
            sources: ["Sources"],
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "SoundDeckTests",
            dependencies: ["SoundDeckCommon"],
            path: "Tests/SoundDeckTests"
        ),
    ]
)
