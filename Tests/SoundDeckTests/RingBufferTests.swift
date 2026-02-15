import XCTest
import SoundDeckCommon

final class RingBufferTests: XCTestCase {

    private func makeBuffer() -> UnsafeMutablePointer<SharedAudioBuffer> {
        let frames: UInt32 = 4096
        let channels: UInt32 = 1
        let size = SharedAudioBufferSize(frames, channels)
        let memory = UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: MemoryLayout<Float>.alignment)
        let buf = memory.bindMemory(to: SharedAudioBuffer.self, capacity: 1)
        RingBuffer_Init(buf, frames, channels, 48000.0)
        return buf
    }

    private func destroyBuffer(_ buf: UnsafeMutablePointer<SharedAudioBuffer>) {
        buf.deinitialize(count: 1)
        buf.deallocate()
    }

    func testInitialState() {
        let buf = makeBuffer()
        defer { destroyBuffer(buf) }

        XCTAssertEqual(RingBuffer_AvailableForRead(buf), 0)
        XCTAssertEqual(RingBuffer_AvailableForWrite(buf), 4096)
    }

    func testWriteAndRead() {
        let buf = makeBuffer()
        defer { destroyBuffer(buf) }

        var writeData: [Float] = [1.0, 2.0, 3.0, 4.0]
        let written = RingBuffer_Write(buf, &writeData, 4)
        XCTAssertEqual(written, 4)
        XCTAssertEqual(RingBuffer_AvailableForRead(buf), 4)

        var readData = [Float](repeating: 0, count: 4)
        let read = RingBuffer_Read(buf, &readData, 4)
        XCTAssertEqual(read, 4)
        XCTAssertEqual(readData, [1.0, 2.0, 3.0, 4.0])
        XCTAssertEqual(RingBuffer_AvailableForRead(buf), 0)
    }

    func testPartialRead() {
        let buf = makeBuffer()
        defer { destroyBuffer(buf) }

        var writeData: [Float] = [10.0, 20.0]
        RingBuffer_Write(buf, &writeData, 2)

        // Try to read more than available
        var readData = [Float](repeating: -1, count: 4)
        let read = RingBuffer_Read(buf, &readData, 4)
        XCTAssertEqual(read, 2)
        XCTAssertEqual(readData[0], 10.0)
        XCTAssertEqual(readData[1], 20.0)
        // Remaining should be zero-filled
        XCTAssertEqual(readData[2], 0.0)
        XCTAssertEqual(readData[3], 0.0)
    }

    func testWrapAround() {
        let buf = makeBuffer()
        defer { destroyBuffer(buf) }

        let capacity: UInt32 = 4096

        // Fill most of the buffer
        var fillData = [Float](repeating: 0.5, count: Int(capacity - 2))
        RingBuffer_Write(buf, &fillData, capacity - 2)

        // Read it all back to advance read head
        var drain = [Float](repeating: 0, count: Int(capacity - 2))
        RingBuffer_Read(buf, &drain, capacity - 2)

        // Now write data that wraps around
        var wrapData: [Float] = [100.0, 200.0, 300.0, 400.0]
        let written = RingBuffer_Write(buf, &wrapData, 4)
        XCTAssertEqual(written, 4)

        var readBack = [Float](repeating: 0, count: 4)
        let read = RingBuffer_Read(buf, &readBack, 4)
        XCTAssertEqual(read, 4)
        XCTAssertEqual(readBack, [100.0, 200.0, 300.0, 400.0])
    }

    func testFullBuffer() {
        let buf = makeBuffer()
        defer { destroyBuffer(buf) }

        let capacity: UInt32 = 4096
        var data = [Float](repeating: 1.0, count: Int(capacity))
        let written = RingBuffer_Write(buf, &data, capacity)
        XCTAssertEqual(written, capacity)
        XCTAssertEqual(RingBuffer_AvailableForWrite(buf), 0)

        // Writing to full buffer should return 0
        var extra: [Float] = [99.0]
        let writtenExtra = RingBuffer_Write(buf, &extra, 1)
        XCTAssertEqual(writtenExtra, 0)
    }

    func testEmptyRead() {
        let buf = makeBuffer()
        defer { destroyBuffer(buf) }

        var readData = [Float](repeating: -1, count: 4)
        let read = RingBuffer_Read(buf, &readData, 4)
        XCTAssertEqual(read, 0)
        // Should be zero-filled
        XCTAssertEqual(readData, [0.0, 0.0, 0.0, 0.0])
    }

    func testVolumeAndMute() {
        let buf = makeBuffer()
        defer { destroyBuffer(buf) }

        // Default values (use C accessor functions for _Atomic fields)
        XCTAssertEqual(SharedAudioBuffer_GetVolume(buf), 1.0, accuracy: 0.001)
        XCTAssertEqual(SharedAudioBuffer_GetMuted(buf), 0)

        // Modify via atomic accessors
        SharedAudioBuffer_SetVolume(buf, 0.5)
        SharedAudioBuffer_SetMuted(buf, 1)
        XCTAssertEqual(SharedAudioBuffer_GetVolume(buf), 0.5, accuracy: 0.001)
        XCTAssertEqual(SharedAudioBuffer_GetMuted(buf), 1)
    }

    func testMultipleWriteReadCycles() {
        let buf = makeBuffer()
        defer { destroyBuffer(buf) }

        for i in 0..<100 {
            var writeData = [Float](repeating: Float(i), count: 256)
            let written = RingBuffer_Write(buf, &writeData, 256)
            XCTAssertEqual(written, 256)

            var readData = [Float](repeating: 0, count: 256)
            let read = RingBuffer_Read(buf, &readData, 256)
            XCTAssertEqual(read, 256)
            XCTAssertEqual(readData[0], Float(i))
        }
    }
}
