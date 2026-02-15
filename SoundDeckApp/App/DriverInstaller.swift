import Foundation
import os.log

/// Installs the SoundDeck virtual audio driver using macOS admin privileges.
/// Finds the driver bundle embedded in the app's Resources, then uses
/// AppleScript `with administrator privileges` to copy it to the HAL
/// directory and restart coreaudiod.
enum DriverInstaller {
    private static let logger = Logger(subsystem: "com.sounddeck.app", category: "DriverInstaller")
    private static let halDirectory = "/Library/Audio/Plug-Ins/HAL"
    private static let driverName = "SoundDeckDriver.driver"
    private static let installPath = "/Library/Audio/Plug-Ins/HAL/SoundDeckDriver.driver"

    enum InstallError: LocalizedError {
        case driverNotFound
        case userCancelled
        case scriptFailed(String)

        var errorDescription: String? {
            switch self {
            case .driverNotFound:
                return "Could not find SoundDeckDriver.driver in the app bundle."
            case .userCancelled:
                return "Installation was cancelled."
            case .scriptFailed(let message):
                return "Installation failed: \(message)"
            }
        }
    }

    /// Whether the driver is currently installed in the HAL directory.
    static var isInstalled: Bool {
        FileManager.default.fileExists(atPath: installPath)
    }

    /// Find the driver bundle path inside our app bundle's Resources.
    private static func findDriverBundle() -> String? {
        // Check app bundle Resources
        if let path = Bundle.main.path(forResource: "SoundDeckDriver", ofType: "driver") {
            return path
        }

        // Check next to the app executable (development builds)
        let execDir = Bundle.main.bundlePath + "/Contents/MacOS"
        let candidate = (execDir as NSString).appendingPathComponent(driverName)
        if FileManager.default.fileExists(atPath: candidate) {
            return candidate
        }

        return nil
    }

    /// Uninstall the driver with admin privileges. Runs asynchronously.
    /// - Parameter completion: Called on the main thread with the result.
    static func uninstall(completion: @escaping (Result<Void, InstallError>) -> Void) {
        let escapedDest = installPath.replacingOccurrences(of: "'", with: "'\\''")

        let shellScript = """
        rm -rf '\(escapedDest)' && \
        launchctl kickstart -kp system/com.apple.audio.coreaudiod
        """

        let appleScript = """
        do shell script "\(shellScript)" with administrator privileges
        """

        DispatchQueue.global(qos: .userInitiated).async {
            let script = NSAppleScript(source: appleScript)
            var errorDict: NSDictionary?
            script?.executeAndReturnError(&errorDict)

            DispatchQueue.main.async {
                if let error = errorDict {
                    let errorNumber = error[NSAppleScript.errorNumber] as? Int ?? -1
                    if errorNumber == -128 {
                        logger.info("User cancelled driver uninstall")
                        completion(.failure(.userCancelled))
                    } else {
                        let message = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                        logger.error("Driver uninstall failed: \(message)")
                        completion(.failure(.scriptFailed(message)))
                    }
                } else {
                    logger.info("Driver uninstalled successfully")
                    completion(.success(()))
                }
            }
        }
    }

    /// Install the driver with admin privileges. Runs asynchronously.
    /// - Parameter completion: Called on the main thread with the result.
    static func install(completion: @escaping (Result<Void, InstallError>) -> Void) {
        guard let driverSource = findDriverBundle() else {
            logger.error("Driver bundle not found in app bundle")
            DispatchQueue.main.async { completion(.failure(.driverNotFound)) }
            return
        }

        logger.info("Found driver at: \(driverSource)")

        // Build the shell commands:
        // 1. Remove any existing driver
        // 2. Copy the new driver bundle
        // 3. Set ownership to root:wheel
        // 4. Set permissions to 755
        // 5. Restart coreaudiod
        let escapedSource = driverSource.replacingOccurrences(of: "'", with: "'\\''")
        let escapedDest = installPath.replacingOccurrences(of: "'", with: "'\\''")
        let escapedDir = halDirectory.replacingOccurrences(of: "'", with: "'\\''")

        let shellScript = """
        rm -rf '\(escapedDest)' && \
        mkdir -p '\(escapedDir)' && \
        cp -R '\(escapedSource)' '\(escapedDest)' && \
        chown -R root:wheel '\(escapedDest)' && \
        chmod -R 755 '\(escapedDest)' && \
        launchctl kickstart -kp system/com.apple.audio.coreaudiod
        """

        // Use AppleScript to prompt for admin password
        let appleScript = """
        do shell script "\(shellScript)" with administrator privileges
        """

        DispatchQueue.global(qos: .userInitiated).async {
            let script = NSAppleScript(source: appleScript)
            var errorDict: NSDictionary?
            script?.executeAndReturnError(&errorDict)

            DispatchQueue.main.async {
                if let error = errorDict {
                    let errorNumber = error[NSAppleScript.errorNumber] as? Int ?? -1
                    // -128 = user cancelled the auth dialog
                    if errorNumber == -128 {
                        logger.info("User cancelled driver installation")
                        completion(.failure(.userCancelled))
                    } else {
                        let message = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
                        logger.error("Driver install failed: \(message)")
                        completion(.failure(.scriptFailed(message)))
                    }
                } else {
                    logger.info("Driver installed successfully")
                    completion(.success(()))
                }
            }
        }
    }
}
