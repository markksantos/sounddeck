import AVFoundation
import os.log

/// Wraps AVAudioUnitTimePitch to provide voice pitch shifting with presets.
/// Adjusts overlap for better quality at extreme pitch shifts.
final class VoiceChanger {
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "VoiceChanger")
    private let pitchUnit: AVAudioUnitTimePitch

    /// Current pitch shift in cents (-1200 to +1200).
    /// One octave down = -1200, one octave up = +1200.
    var pitchCents: Float {
        get { pitchUnit.pitch }
        set {
            let clamped = min(max(newValue, -1200.0), 1200.0)
            pitchUnit.pitch = clamped
            adjustOverlap(for: clamped)
            logger.info("Pitch set to \(clamped) cents")
        }
    }

    /// Whether the voice changer is currently active.
    private(set) var isEnabled: Bool = false

    // MARK: - Presets

    enum Preset: String, CaseIterable, Identifiable {
        case deep = "Deep"
        case normal = "Normal"
        case high = "High"
        case chipmunk = "Chipmunk"

        var id: String { rawValue }

        var cents: Float {
            switch self {
            case .deep:      return -600.0
            case .normal:    return 0.0
            case .high:      return 600.0
            case .chipmunk:  return 1200.0
            }
        }

        var iconName: String {
            switch self {
            case .deep:      return "waveform.path.ecg"
            case .normal:    return "person.fill"
            case .high:      return "waveform"
            case .chipmunk:  return "hare.fill"
            }
        }
    }

    // MARK: - Init

    init(pitchUnit: AVAudioUnitTimePitch) {
        self.pitchUnit = pitchUnit
        // Start with bypass enabled (no pitch shift)
        pitchUnit.bypass = true
        pitchUnit.pitch = 0.0
        pitchUnit.rate = 1.0
    }

    // MARK: - Enable / Disable

    /// Enables the voice changer (removes bypass).
    func enable() {
        pitchUnit.bypass = false
        isEnabled = true
        logger.info("Voice changer enabled (pitch: \(self.pitchUnit.pitch) cents)")
    }

    /// Disables the voice changer (sets bypass).
    func disable() {
        pitchUnit.bypass = true
        isEnabled = false
        logger.info("Voice changer disabled")
    }

    /// Applies a preset.
    func apply(preset: Preset) {
        pitchCents = preset.cents
        if preset == .normal {
            disable()
        } else {
            enable()
        }
    }

    // MARK: - Quality Tuning

    /// Adjusts the overlap parameter based on the pitch shift amount.
    /// Higher overlap improves quality for extreme shifts at the cost of CPU.
    private func adjustOverlap(for cents: Float) {
        let absCents = abs(cents)

        // AVAudioUnitTimePitch overlap ranges from 3.0 to 32.0 (default 8.0)
        let overlap: Float
        if absCents < 200 {
            overlap = 8.0    // Default — low shift, minimal artifacts
        } else if absCents < 600 {
            overlap = 12.0   // Moderate shift — slightly higher quality
        } else if absCents < 1000 {
            overlap = 16.0   // High shift — more overlap needed
        } else {
            overlap = 24.0   // Extreme shift — maximum quality
        }

        pitchUnit.overlap = overlap
    }
}
