#ifndef SharedAudioBuffer_h
#define SharedAudioBuffer_h

#include <stdatomic.h>
#include <stdint.h>
#include "SharedAudioConstants.h"

/// Shared memory layout for app→driver audio IPC.
/// The app writes mixed audio into the ring buffer; the driver reads it.
/// Lock-free SPSC (single-producer, single-consumer) design.
typedef struct {
    // Header — control fields
    _Atomic uint64_t writeHead;       // Frame index of next write position (app increments)
    _Atomic uint64_t readHead;        // Frame index of next read position (driver increments)
    uint32_t bufferFrames;            // Total ring buffer capacity in frames
    uint32_t channelCount;            // Number of audio channels (1 = mono)
    double sampleRate;                // Sample rate in Hz (48000)
    _Atomic float volume;             // Master volume 0.0–1.0 (set by app, read by driver)
    _Atomic uint32_t muted;           // 1 = muted, 0 = active (set by app, read by driver)
    uint32_t _reserved[8];            // Padding for future use / cache alignment

    // Audio data — flexible array member
    // Actual size = bufferFrames * channelCount * sizeof(float)
    float audioData[];
} SharedAudioBuffer;

/// Calculate total shared memory size needed
static inline size_t SharedAudioBufferSize(uint32_t bufferFrames, uint32_t channelCount) {
    return sizeof(SharedAudioBuffer) + (bufferFrames * channelCount * sizeof(float));
}

#endif /* SharedAudioBuffer_h */
