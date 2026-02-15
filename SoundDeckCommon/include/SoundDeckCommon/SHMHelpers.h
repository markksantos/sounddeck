#ifndef SHMHelpers_h
#define SHMHelpers_h

#include "SharedAudioBuffer.h"
#include <sys/mman.h>
#include <fcntl.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Open or create a POSIX shared memory object.
/// Wraps shm_open (which is variadic and unavailable in Swift).
int SHM_Open(const char *name, int oflag, int mode);

/// Unlink a POSIX shared memory object.
int SHM_Unlink(const char *name);

/// Set the volume field atomically on a SharedAudioBuffer.
void SharedAudioBuffer_SetVolume(SharedAudioBuffer *buf, float volume);

/// Get the volume field atomically from a SharedAudioBuffer.
float SharedAudioBuffer_GetVolume(const SharedAudioBuffer *buf);

/// Set the muted field atomically on a SharedAudioBuffer.
void SharedAudioBuffer_SetMuted(SharedAudioBuffer *buf, uint32_t muted);

/// Get the muted field atomically from a SharedAudioBuffer.
uint32_t SharedAudioBuffer_GetMuted(const SharedAudioBuffer *buf);

#ifdef __cplusplus
}
#endif

#endif /* SHMHelpers_h */
