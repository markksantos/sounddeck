<div align="center">

# 🎚️ SoundDeck

**Virtual audio mixer and soundboard for macOS with keyboard shortcuts**

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-13+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-007AFF?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/swiftui)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager)

[Features](#-features) · [Getting Started](#-getting-started) · [Tech Stack](#️-tech-stack)

</div>

---

## ✨ Features

- **Virtual Audio Device** — Route sound effects through a virtual microphone for use in video calls, streams, and recordings
- **Hotkey Playback** — Assign keyboard shortcuts to trigger any sound effect instantly
- **Sound Library** — Organize audio files into folders with drag-and-drop import
- **Headphone Preview** — Preview sounds privately through headphones before playing them on the virtual mic
- **Multi-Format Support** — Import MP3, WAV, M4A, and other audio formats
- **Menu Bar App** — Lightweight, always-accessible interface from the macOS menu bar
- **Audio Driver** — Includes a system audio extension for virtual device functionality
- **Subscription/Licensing** — Built-in licensing system with StoreKit 2 support
- **Auto-Updates** — Sparkle integration for seamless app updates
- **Stop All** — Kill switch to instantly stop all playing sounds

## 🚀 Getting Started

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0+
- Swift 5.9+

### Installation

```bash
# Clone the repository
git clone https://github.com/markksantos/sounddeck.git

# Navigate to project directory
cd sounddeck

# Generate Xcode project using XcodeGen
xcodegen generate

# Open the project
open SoundDeck.xcodeproj
```

### Building

1. Open `SoundDeck.xcodeproj` in Xcode
2. Select the SoundDeck scheme
3. Build and run (Cmd+R)
4. Grant audio driver permissions when prompted

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Build System | XcodeGen, Swift Package Manager |
| Audio | CoreAudio, Audio Unit Extensions |
| Hotkeys | KeyboardShortcuts (SPM) |
| Updates | Sparkle 2.5+ |
| Licensing | StoreKit 2 |
| Platform | macOS 13+ |

## 📁 Project Structure

```
sounddeck/
├── SoundDeckApp/           # Main application
│   ├── App/                # Core app logic and delegates
│   ├── Audio/              # Audio playback and routing
│   ├── Hotkeys/            # Keyboard shortcut management
│   ├── Views/              # SwiftUI views
│   ├── Models/             # Data models
│   ├── Services/           # Audio services and managers
│   ├── Subscription/       # StoreKit integration
│   └── Licensing/          # License validation
├── SoundDeckDriver/        # Audio driver extension
├── SoundDeckCommon/        # Shared code between app and driver
├── SoundDeckInstaller/     # Driver installation utility
├── Tests/                  # Unit tests
├── Resources/              # Assets and resources
├── project.yml             # XcodeGen configuration
└── Package.swift           # Swift Package Manager manifest
```

## 📄 License

MIT License © 2025 Mark Santos
