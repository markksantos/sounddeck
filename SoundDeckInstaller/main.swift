// main.swift — SoundDeck Driver Installer
//
// CLI tool to install or uninstall the SoundDeck virtual audio driver.
// Must be run as root (via sudo) because:
//   1. The HAL plugin directory /Library/Audio/Plug-Ins/HAL/ requires root to write
//   2. Restarting coreaudiod requires root privileges
//
// Usage:
//   sudo SoundDeckInstaller install
//   sudo SoundDeckInstaller uninstall

import Foundation

// MARK: - Constants

let driverBundleName = "SoundDeckDriver.driver"
let installDirectory = "/Library/Audio/Plug-Ins/HAL"
let installPath = "\(installDirectory)/\(driverBundleName)"
let coreaudiodService = "system/com.apple.audio.coreaudiod"

// MARK: - Helpers

func printError(_ message: String) {
    let stderr = FileHandle.standardError
    stderr.write(Data("[ERROR] \(message)\n".utf8))
}

func printStatus(_ message: String) {
    print("[SoundDeckInstaller] \(message)")
}

func isRunningAsRoot() -> Bool {
    return getuid() == 0
}

@discardableResult
func runShellCommand(_ command: String, arguments: [String]) -> (exitCode: Int32, output: String, error: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        return (-1, "", "Failed to launch \(command): \(error.localizedDescription)")
    }

    let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
    let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
    let stdoutStr = String(data: stdoutData, encoding: .utf8) ?? ""
    let stderrStr = String(data: stderrData, encoding: .utf8) ?? ""

    return (process.terminationStatus, stdoutStr, stderrStr)
}

func restartCoreaudiod() -> Bool {
    printStatus("Restarting coreaudiod...")

    let result = runShellCommand("/bin/launchctl", arguments: ["kickstart", "-kp", coreaudiodService])

    if result.exitCode != 0 {
        printError("Failed to restart coreaudiod (exit code \(result.exitCode))")
        if !result.error.isEmpty {
            printError("  stderr: \(result.error.trimmingCharacters(in: .whitespacesAndNewlines))")
        }
        return false
    }

    printStatus("coreaudiod restarted successfully.")
    return true
}

func findDriverBundle() -> String? {
    // Strategy 1: Look next to the installer binary
    let installerPath = CommandLine.arguments[0]
    let installerDir = (installerPath as NSString).deletingLastPathComponent

    // The driver bundle is expected to be in the same build products directory
    // or in a well-known relative location
    let candidates = [
        "\(installerDir)/\(driverBundleName)",
        "\(installerDir)/../PlugIns/\(driverBundleName)",
        "\(installerDir)/../Library/Audio/Plug-Ins/HAL/\(driverBundleName)",
        // When built via Xcode, the driver may be alongside the installer in DerivedData
        "\(installerDir)/../../../SoundDeckDriver.driver",
    ]

    for candidate in candidates {
        let standardized = (candidate as NSString).standardizingPath
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: standardized, isDirectory: &isDir), isDir.boolValue {
            return standardized
        }
    }

    return nil
}

// MARK: - Install

func install() -> Int32 {
    printStatus("Installing SoundDeck virtual audio driver...")

    // Find the driver bundle
    guard let sourcePath = findDriverBundle() else {
        printError("Could not find \(driverBundleName) bundle.")
        printError("Make sure the driver is built and located next to this installer.")
        printError("Expected locations relative to installer binary:")
        let installerDir = (CommandLine.arguments[0] as NSString).deletingLastPathComponent
        printError("  \(installerDir)/\(driverBundleName)")
        return 1
    }

    printStatus("Found driver bundle at: \(sourcePath)")

    // Ensure the HAL plug-ins directory exists
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: installDirectory) {
        do {
            try fileManager.createDirectory(atPath: installDirectory,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            printStatus("Created directory: \(installDirectory)")
        } catch {
            printError("Failed to create directory \(installDirectory): \(error.localizedDescription)")
            return 1
        }
    }

    // Remove existing installation if present
    if fileManager.fileExists(atPath: installPath) {
        printStatus("Removing existing installation at \(installPath)...")
        do {
            try fileManager.removeItem(atPath: installPath)
        } catch {
            printError("Failed to remove existing driver: \(error.localizedDescription)")
            return 1
        }
    }

    // Copy the driver bundle
    do {
        try fileManager.copyItem(atPath: sourcePath, toPath: installPath)
    } catch {
        printError("Failed to copy driver to \(installPath): \(error.localizedDescription)")
        return 1
    }

    printStatus("Driver installed to \(installPath)")

    // Set proper ownership and permissions
    let chownResult = runShellCommand("/usr/sbin/chown", arguments: ["-R", "root:wheel", installPath])
    if chownResult.exitCode != 0 {
        printError("Warning: failed to set ownership on driver bundle")
    }

    let chmodResult = runShellCommand("/bin/chmod", arguments: ["-R", "755", installPath])
    if chmodResult.exitCode != 0 {
        printError("Warning: failed to set permissions on driver bundle")
    }

    // Restart coreaudiod to pick up the new driver
    if !restartCoreaudiod() {
        printError("Driver was installed but coreaudiod restart failed.")
        printError("You may need to restart coreaudiod manually or reboot.")
        return 1
    }

    printStatus("Installation complete. 'SoundDeck Virtual Mic' should now appear in audio input devices.")
    return 0
}

// MARK: - Uninstall

func uninstall() -> Int32 {
    printStatus("Uninstalling SoundDeck virtual audio driver...")

    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: installPath) {
        printStatus("Driver not found at \(installPath). Nothing to uninstall.")
        return 0
    }

    // Remove the driver bundle
    do {
        try fileManager.removeItem(atPath: installPath)
    } catch {
        printError("Failed to remove driver at \(installPath): \(error.localizedDescription)")
        return 1
    }

    printStatus("Driver removed from \(installPath)")

    // Restart coreaudiod to unload the driver
    if !restartCoreaudiod() {
        printError("Driver was removed but coreaudiod restart failed.")
        printError("You may need to restart coreaudiod manually or reboot.")
        return 1
    }

    printStatus("Uninstallation complete. 'SoundDeck Virtual Mic' has been removed.")
    return 0
}

// MARK: - Main

func printUsage() {
    print("""
    SoundDeck Driver Installer

    Usage: sudo SoundDeckInstaller <command>

    Commands:
      install     Install the virtual audio driver and restart coreaudiod
      uninstall   Remove the virtual audio driver and restart coreaudiod

    This tool must be run as root (use sudo).
    """)
}

func main() -> Int32 {
    let args = CommandLine.arguments

    guard args.count >= 2 else {
        printUsage()
        return 1
    }

    let command = args[1].lowercased()

    // Check for root privileges
    guard isRunningAsRoot() else {
        printError("This tool must be run as root.")
        printError("Usage: sudo \(args[0]) \(command)")
        return 1
    }

    switch command {
    case "install":
        return install()
    case "uninstall":
        return uninstall()
    case "-h", "--help", "help":
        printUsage()
        return 0
    default:
        printError("Unknown command: '\(command)'")
        printUsage()
        return 1
    }
}

exit(main())
