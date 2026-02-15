#include "SoundDeckCommon/SharedAudioBuffer.h"
#include "SoundDeckCommon/RingBuffer.h"
#include <string.h>
#include <stdatomic.h>

void RingBuffer_Init(SharedAudioBuffer *buf, uint32_t bufferFrames, uint32_t channelCount, double sampleRate) {
    atomic_store_explicit(&buf->writeHead, 0, memory_order_relaxed);
    atomic_store_explicit(&buf->readHead, 0, memory_order_relaxed);
    buf->bufferFrames = bufferFrames;
    buf->channelCount = channelCount;
    buf->sampleRate = sampleRate;
    atomic_store_explicit(&buf->volume, 1.0f, memory_order_relaxed);
    atomic_store_explicit(&buf->muted, 0, memory_order_relaxed);
    memset(buf->_reserved, 0, sizeof(buf->_reserved));
    memset(buf->audioData, 0, bufferFrames * channelCount * sizeof(float));
}

uint32_t RingBuffer_Write(SharedAudioBuffer *buf, const float *data, uint32_t frameCount) {
    uint64_t wh = atomic_load_explicit(&buf->writeHead, memory_order_relaxed);
    uint64_t rh = atomic_load_explicit(&buf->readHead, memory_order_acquire);

    uint32_t capacity = buf->bufferFrames;
    uint32_t channels = buf->channelCount;
    uint32_t available = capacity - (uint32_t)(wh - rh);

    if (frameCount > available) {
        frameCount = available;
    }

    if (frameCount == 0) {
        return 0;
    }

    uint32_t writePos = (uint32_t)(wh % capacity);
    uint32_t firstChunk = capacity - writePos;

    if (firstChunk >= frameCount) {
        // Single contiguous copy
        memcpy(&buf->audioData[writePos * channels], data, frameCount * channels * sizeof(float));
    } else {
        // Wrap around: two copies
        memcpy(&buf->audioData[writePos * channels], data, firstChunk * channels * sizeof(float));
        memcpy(&buf->audioData[0], &data[firstChunk * channels], (frameCount - firstChunk) * channels * sizeof(float));
    }

    atomic_store_explicit(&buf->writeHead, wh + frameCount, memory_order_release);
    return frameCount;
}

uint32_t RingBuffer_Read(SharedAudioBuffer *buf, float *outData, uint32_t frameCount) {
    uint64_t rh = atomic_load_explicit(&buf->readHead, memory_order_relaxed);
    uint64_t wh = atomic_load_explicit(&buf->writeHead, memory_order_acquire);

    uint32_t capacity = buf->bufferFrames;
    uint32_t channels = buf->channelCount;
    uint32_t available = (uint32_t)(wh - rh);

    uint32_t framesRead = frameCount;
    if (framesRead > available) {
        framesRead = available;
    }

    if (framesRead > 0) {
        uint32_t readPos = (uint32_t)(rh % capacity);
        uint32_t firstChunk = capacity - readPos;

        if (firstChunk >= framesRead) {
            memcpy(outData, &buf->audioData[readPos * channels], framesRead * channels * sizeof(float));
        } else {
            memcpy(outData, &buf->audioData[readPos * channels], firstChunk * channels * sizeof(float));
            memcpy(&outData[firstChunk * channels], &buf->audioData[0], (framesRead - firstChunk) * channels * sizeof(float));
        }

        atomic_store_explicit(&buf->readHead, rh + framesRead, memory_order_release);
    }

    // Zero-fill remainder on underrun
    if (framesRead < frameCount) {
        memset(&outData[framesRead * channels], 0, (frameCount - framesRead) * channels * sizeof(float));
    }

    return framesRead;
}

uint32_t RingBuffer_AvailableForRead(const SharedAudioBuffer *buf) {
    uint64_t wh = atomic_load_explicit(&buf->writeHead, memory_order_acquire);
    uint64_t rh = atomic_load_explicit(&buf->readHead, memory_order_relaxed);
    return (uint32_t)(wh - rh);
}

uint32_t RingBuffer_AvailableForWrite(const SharedAudioBuffer *buf) {
    uint64_t wh = atomic_load_explicit(&buf->writeHead, memory_order_relaxed);
    uint64_t rh = atomic_load_explicit(&buf->readHead, memory_order_acquire);
    return buf->bufferFrames - (uint32_t)(wh - rh);
}
