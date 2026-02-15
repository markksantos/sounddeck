#include "SoundDeckCommon/SHMHelpers.h"
#include <sys/mman.h>
#include <fcntl.h>
#include <stdatomic.h>

int SHM_Open(const char *name, int oflag, int mode) {
    return shm_open(name, oflag, (mode_t)mode);
}

int SHM_Unlink(const char *name) {
    return shm_unlink(name);
}

void SharedAudioBuffer_SetVolume(SharedAudioBuffer *buf, float volume) {
    atomic_store_explicit(&buf->volume, volume, memory_order_release);
}

float SharedAudioBuffer_GetVolume(const SharedAudioBuffer *buf) {
    return atomic_load_explicit(&buf->volume, memory_order_acquire);
}

void SharedAudioBuffer_SetMuted(SharedAudioBuffer *buf, uint32_t muted) {
    atomic_store_explicit(&buf->muted, muted, memory_order_release);
}

uint32_t SharedAudioBuffer_GetMuted(const SharedAudioBuffer *buf) {
    return atomic_load_explicit(&buf->muted, memory_order_acquire);
}
