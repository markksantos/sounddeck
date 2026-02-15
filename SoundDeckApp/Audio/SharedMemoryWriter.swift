import Foundation
import SoundDeckCommon
import os.log

/// Writes mixed audio into POSIX shared memory for the virtual microphone driver to read.
/// Uses the lock-free SPSC ring buffer defined in SoundDeckCommon.
///
/// Thread safety: `write(frames:frameCount:)` is RT-safe and designed to be called from
/// an audio render callback. `setVolume(_:)` and `setMuted(_:)` use atomic stores.
final class SharedMemoryWriter {
    private let logger = Logger(subsystem: "com.sounddeck.app", category: "SharedMemoryWriter")

    private var shmFD: Int32 = -1
    private var mappedMemory: UnsafeMutableRawPointer?
    private var mappedSize: Int = 0
    private var buffer: UnsafeMutablePointer<SharedAudioBuffer>?
    private var didOpen = false

    /// Whether the shared memory region is currently mapped and ready.
    var isReady: Bool {
        return buffer != nil
    }

    // MARK: - Lifecycle

    /// Opens (or creates) the shared memory region and initializes the ring buffer.
    /// Call this before starting the audio engine.
    func open() -> Bool {
        guard buffer == nil else {
            logger.info("Shared memory already open")
            return true
        }

        let bufferFrames = UInt32(kSoundDeckRingBufferFrames)
        let channelCount = UInt32(kSoundDeckChannelCount)
        let totalSize = SharedAudioBufferSize(bufferFrames, channelCount)

        // Open or create the shared memory object
        let name = kSoundDeckSHMName
        shmFD = SHM_Open(name, O_CREAT | O_RDWR, 0o666)
        guard shmFD >= 0 else {
            logger.error("shm_open failed: \(String(cString: strerror(errno)))")
            return false
        }

        // Set the size
        if ftruncate(shmFD, off_t(totalSize)) != 0 {
            logger.error("ftruncate failed: \(String(cString: strerror(errno)))")
            closeFileDescriptor()
            return false
        }

        // Memory-map the region
        let mapped = mmap(nil, totalSize, PROT_READ | PROT_WRITE, MAP_SHARED, shmFD, 0)
        guard mapped != MAP_FAILED else {
            logger.error("mmap failed: \(String(cString: strerror(errno)))")
            closeFileDescriptor()
            return false
        }

        mappedMemory = mapped
        mappedSize = totalSize
        buffer = mapped!.assumingMemoryBound(to: SharedAudioBuffer.self)

        // Initialize the ring buffer header and zero the audio data
        RingBuffer_Init(
            buffer,
            bufferFrames,
            channelCount,
            kSoundDeckSampleRate
        )

        didOpen = true
        logger.info("Shared memory opened: \(totalSize) bytes, \(bufferFrames) frames")
        return true
    }

    // MARK: - RT-Safe Write

    /// Writes interleaved float audio frames into the ring buffer.
    /// This method is RT-safe: no locks, no allocations, no ObjC dispatch.
    ///
    /// - Parameters:
    ///   - frames: Pointer to interleaved float samples.
    ///   - frameCount: Number of frames to write.
    /// - Returns: Number of frames actually written.
    @inline(__always)
    func write(frames: UnsafePointer<Float>, frameCount: UInt32) -> UInt32 {
        guard let buf = buffer else { return 0 }
        return RingBuffer_Write(buf, frames, frameCount)
    }

    // MARK: - Atomic Controls

    /// Sets the master volume on the shared buffer (read by the driver).
    func setVolume(_ volume: Float) {
        guard let buf = buffer else { return }
        let clamped = min(max(volume, 0.0), 1.0)
        SharedAudioBuffer_SetVolume(buf, clamped)
    }

    /// Sets the muted flag on the shared buffer (read by the driver).
    func setMuted(_ muted: Bool) {
        guard let buf = buffer else { return }
        SharedAudioBuffer_SetMuted(buf, muted ? 1 : 0)
    }

    // MARK: - Cleanup

    /// Unmaps and unlinks the shared memory region.
    func cleanup() {
        if let mapped = mappedMemory, mappedSize > 0 {
            munmap(mapped, mappedSize)
            mappedMemory = nil
            mappedSize = 0
            buffer = nil
        }

        closeFileDescriptor()

        // Only unlink if we successfully opened the shared memory
        if didOpen {
            SHM_Unlink(kSoundDeckSHMName)
            didOpen = false
        }
        logger.info("Shared memory cleaned up")
    }

    private func closeFileDescriptor() {
        if shmFD >= 0 {
            close(shmFD)
            shmFD = -1
        }
    }

    deinit {
        cleanup()
    }
}
