#ifndef RingBuffer_h
#define RingBuffer_h

#include "SharedAudioBuffer.h"
#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Initialize a SharedAudioBuffer with default values.
/// Call once after mmap before any reads/writes.
void RingBuffer_Init(SharedAudioBuffer *buf, uint32_t bufferFrames, uint32_t channelCount, double sampleRate);

/// Write `frameCount` interleaved float samples into the ring buffer.
/// Returns the number of frames actually written (may be less if buffer is full).
/// RT-safe: no allocation, no locks.
uint32_t RingBuffer_Write(SharedAudioBuffer *buf, const float *data, uint32_t frameCount);

/// Read `frameCount` interleaved float samples from the ring buffer.
/// Returns the number of frames actually read (may be less if buffer doesn't have enough data).
/// On underrun, remaining frames in `outData` are zero-filled.
/// RT-safe: no allocation, no locks.
uint32_t RingBuffer_Read(SharedAudioBuffer *buf, float *outData, uint32_t frameCount);

/// Returns the number of frames available for reading.
uint32_t RingBuffer_AvailableForRead(const SharedAudioBuffer *buf);

/// Returns the number of frames available for writing.
uint32_t RingBuffer_AvailableForWrite(const SharedAudioBuffer *buf);

#ifdef __cplusplus
}
#endif

#endif /* RingBuffer_h */
