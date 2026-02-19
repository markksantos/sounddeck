// DriverEntry.cpp — SoundDeck Virtual Microphone AudioServerPlugin
//
// Implements the raw AudioServerPlugIn API to present a virtual audio input
// device (microphone) to macOS. Audio data comes from a POSIX shared memory
// ring buffer written by the SoundDeck application.
//
// Object hierarchy:
//   Plugin (kAudioObjectPlugInObject / 1)
//     └─ Device (2)  "SoundDeck Virtual Mic"
//          ├─ Stream Input (3)  48 kHz mono Float32
//          ├─ Volume Control (4)
//          └─ Mute Control (5)
//
// Runs inside coreaudiod — must be absolutely stable, no exceptions,
// no dynamic allocation on the IO thread.

#include <CoreAudio/AudioServerPlugIn.h>
#include <CoreFoundation/CoreFoundation.h>
#include <mach/mach_time.h>
#include <pthread.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <os/log.h>
#include <dispatch/dispatch.h>
#include <atomic>

extern "C" {
#include <SoundDeckCommon/SharedAudioConstants.h>
#include <SoundDeckCommon/SharedAudioBuffer.h>
#include <SoundDeckCommon/RingBuffer.h>
}

// =============================================================================
#pragma mark -  Constants
// =============================================================================

static const AudioObjectID kObjectID_Device         = 2;
static const AudioObjectID kObjectID_Stream_Input   = 3;
static const AudioObjectID kObjectID_Volume_Control = 4;
static const AudioObjectID kObjectID_Mute_Control   = 5;

static const UInt32 kNumObjects = 4; // device, stream, volume, mute

// The plugin type UUID from Info.plist / SharedAudioConstants.h
// 443ABAB8-E7B3-491A-B985-BEB9187030DB
static const REFIID kSoundDeckDriver_PluginTypeUUID =
    CFUUIDGetUUIDBytes(CFUUIDGetConstantUUIDWithBytes(NULL,
        0x44, 0x3A, 0xBA, 0xB8,
        0xE7, 0xB3,
        0x49, 0x1A,
        0xB9, 0x85,
        0xBE, 0xB9, 0x18, 0x70, 0x30, 0xDB));

// =============================================================================
#pragma mark -  Logging
// =============================================================================

static os_log_t sDriverLog = OS_LOG_DEFAULT;

#define DriverLog(fmt, ...) os_log(sDriverLog, "SoundDeckDriver: " fmt, ##__VA_ARGS__)
#define DriverLogError(fmt, ...) os_log_error(sDriverLog, "SoundDeckDriver: " fmt, ##__VA_ARGS__)

// =============================================================================
#pragma mark -  Driver State
// =============================================================================

struct SoundDeckDriverState {
    // Reference counting
    std::atomic<UInt32> refCount{1};

    // Plugin host interface (set during Initialize)
    AudioServerPlugInHostRef host = nullptr;

    // IO state
    std::atomic<bool> ioRunning{false};
    UInt32 ioClientCount = 0;
    pthread_mutex_t ioMutex = PTHREAD_MUTEX_INITIALIZER;

    // Shared memory
    SharedAudioBuffer* sharedBuffer = nullptr;
    int shmFD = -1;

    // Clock state — anchored when IO starts
    UInt64 anchorHostTime = 0;
    UInt64 ticksPerFrame = 0;  // in mach_absolute_time units
    std::atomic<UInt64> ioFrameCount{0};

    // Cached volume/mute (driver-side shadow for property queries)
    std::atomic<Float32> volumeLevel{1.0f};
    std::atomic<bool> muteState{false};

    // Configuration change tracking
    UInt64 configChangeAction = 0;
};

static SoundDeckDriverState* sDriverState = nullptr;

// =============================================================================
#pragma mark -  Forward Declarations — AudioServerPlugIn Interface
// =============================================================================

static HRESULT SoundDeck_QueryInterface(void* inDriver, REFIID inUUID, LPVOID* outInterface);
static ULONG   SoundDeck_AddRef(void* inDriver);
static ULONG   SoundDeck_Release(void* inDriver);

static OSStatus SoundDeck_Initialize(AudioServerPlugInDriverRef inDriver, AudioServerPlugInHostRef inHost);
static OSStatus SoundDeck_CreateDevice(AudioServerPlugInDriverRef inDriver,
    CFDictionaryRef inDescription, const AudioServerPlugInClientInfo* inClientInfo,
    AudioObjectID* outDeviceObjectID);
static OSStatus SoundDeck_DestroyDevice(AudioServerPlugInDriverRef inDriver, AudioObjectID inDeviceObjectID);
static OSStatus SoundDeck_AddDeviceClient(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, const AudioServerPlugInClientInfo* inClientInfo);
static OSStatus SoundDeck_RemoveDeviceClient(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, const AudioServerPlugInClientInfo* inClientInfo);
static OSStatus SoundDeck_PerformDeviceConfigurationChange(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt64 inChangeAction, void* inChangeInfo);
static OSStatus SoundDeck_AbortDeviceConfigurationChange(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt64 inChangeAction, void* inChangeInfo);

static Boolean  SoundDeck_HasProperty(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress);
static OSStatus SoundDeck_IsPropertySettable(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress, Boolean* outIsSettable);
static OSStatus SoundDeck_GetPropertyDataSize(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32* outDataSize);
static OSStatus SoundDeck_GetPropertyData(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, UInt32* outDataSize, void* outData);
static OSStatus SoundDeck_SetPropertyData(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, const void* inData);

static OSStatus SoundDeck_StartIO(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID);
static OSStatus SoundDeck_StopIO(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID);
static OSStatus SoundDeck_GetZeroTimeStamp(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID,
    Float64* outSampleTime, UInt64* outHostTime, UInt64* outSeed);
static OSStatus SoundDeck_WillDoIOOperation(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID,
    UInt32 inOperationID, Boolean* outWillDo, Boolean* outIsInput);
static OSStatus SoundDeck_BeginIOOperation(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID,
    UInt32 inOperationID, UInt32 inIOBufferFrameSize,
    const AudioServerPlugInIOCycleInfo* inIOCycleInfo);
static OSStatus SoundDeck_DoIOOperation(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, AudioObjectID inStreamObjectID,
    UInt32 inClientID, UInt32 inOperationID,
    UInt32 inIOBufferFrameSize,
    const AudioServerPlugInIOCycleInfo* inIOCycleInfo,
    void* ioMainBuffer, void* ioSecondaryBuffer);
static OSStatus SoundDeck_EndIOOperation(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID,
    UInt32 inOperationID, UInt32 inIOBufferFrameSize,
    const AudioServerPlugInIOCycleInfo* inIOCycleInfo);

// =============================================================================
#pragma mark -  Static VTable
// =============================================================================

static AudioServerPlugInDriverInterface gDriverInterface = {
    // IUnknown
    NULL, // _reserved (must be NULL)
    SoundDeck_QueryInterface,
    SoundDeck_AddRef,
    SoundDeck_Release,

    // AudioServerPlugIn
    SoundDeck_Initialize,
    SoundDeck_CreateDevice,
    SoundDeck_DestroyDevice,
    SoundDeck_AddDeviceClient,
    SoundDeck_RemoveDeviceClient,
    SoundDeck_PerformDeviceConfigurationChange,
    SoundDeck_AbortDeviceConfigurationChange,
    SoundDeck_HasProperty,
    SoundDeck_IsPropertySettable,
    SoundDeck_GetPropertyDataSize,
    SoundDeck_GetPropertyData,
    SoundDeck_SetPropertyData,
    SoundDeck_StartIO,
    SoundDeck_StopIO,
    SoundDeck_GetZeroTimeStamp,
    SoundDeck_WillDoIOOperation,
    SoundDeck_BeginIOOperation,
    SoundDeck_DoIOOperation,
    SoundDeck_EndIOOperation
};

static AudioServerPlugInDriverInterface* gDriverInterfacePtr = &gDriverInterface;

// =============================================================================
#pragma mark -  Shared Memory Helpers
// =============================================================================

static bool OpenSharedMemory(SoundDeckDriverState* state) {
    if (state->sharedBuffer != nullptr) {
        return true; // Already open
    }

    int fd = shm_open(kSoundDeckSHMName, O_RDWR, 0666);
    if (fd < 0) {
        DriverLogError("shm_open failed for '%s': errno=%d", kSoundDeckSHMName, errno);
        return false;
    }

    size_t shmSize = SharedAudioBufferSize(kSoundDeckRingBufferFrames, kSoundDeckChannelCount);
    void* ptr = mmap(NULL, shmSize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        DriverLogError("mmap failed: errno=%d", errno);
        close(fd);
        return false;
    }

    state->shmFD = fd;
    state->sharedBuffer = static_cast<SharedAudioBuffer*>(ptr);
    DriverLog("Shared memory opened successfully, bufferFrames=%u", state->sharedBuffer->bufferFrames);
    return true;
}

static void CloseSharedMemory(SoundDeckDriverState* state) {
    if (state->sharedBuffer != nullptr) {
        size_t shmSize = SharedAudioBufferSize(kSoundDeckRingBufferFrames, kSoundDeckChannelCount);
        munmap(state->sharedBuffer, shmSize);
        state->sharedBuffer = nullptr;
    }
    if (state->shmFD >= 0) {
        close(state->shmFD);
        state->shmFD = -1;
    }
}

// =============================================================================
#pragma mark -  Mach Time Helpers
// =============================================================================

static UInt64 HostTicksPerFrame() {
    mach_timebase_info_data_t timebase;
    mach_timebase_info(&timebase);
    // nanoseconds per frame = 1e9 / sampleRate
    // ticks per frame = (nsPerFrame * timebase.denom) / timebase.numer
    Float64 nsPerFrame = 1000000000.0 / kSoundDeckSampleRate;
    return (UInt64)((nsPerFrame * (Float64)timebase.denom) / (Float64)timebase.numer);
}

// =============================================================================
#pragma mark -  IUnknown
// =============================================================================

static HRESULT SoundDeck_QueryInterface(void* inDriver, REFIID inUUID, LPVOID* outInterface) {
    // We respond to IUnknown and the AudioServerPlugIn type UUID
    CFUUIDRef requestedUUID = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault, inUUID);
    CFUUIDRef iunknownUUID = CFUUIDGetConstantUUIDWithBytes(NULL,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0xC0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46);
    CFUUIDRef pluginTypeUUID = CFUUIDGetConstantUUIDWithBytes(NULL,
        0x44, 0x3A, 0xBA, 0xB8,
        0xE7, 0xB3,
        0x49, 0x1A,
        0xB9, 0x85,
        0xBE, 0xB9, 0x18, 0x70, 0x30, 0xDB);
    // Also accept the AudioServerPlugInDriverInterface UUID
    CFUUIDRef driverInterfaceUUID = CFUUIDGetConstantUUIDWithBytes(NULL,
        0xEE, 0xA5, 0x77, 0x3D,
        0xCC, 0x43,
        0x49, 0xF1,
        0x8E, 0x00,
        0x8F, 0x96, 0x11, 0x3E, 0x05, 0x01);

    bool match = CFEqual(requestedUUID, iunknownUUID)
              || CFEqual(requestedUUID, pluginTypeUUID)
              || CFEqual(requestedUUID, driverInterfaceUUID);

    CFRelease(requestedUUID);

    if (match) {
        SoundDeck_AddRef(inDriver);
        *outInterface = inDriver;
        return kAudioHardwareNoError;
    }

    *outInterface = NULL;
    return E_NOINTERFACE;
}

static ULONG SoundDeck_AddRef(void* inDriver) {
    if (sDriverState == nullptr) return 0;
    UInt32 newCount = sDriverState->refCount.fetch_add(1) + 1;
    return newCount;
}

static ULONG SoundDeck_Release(void* inDriver) {
    if (sDriverState == nullptr) return 0;
    UInt32 newCount = sDriverState->refCount.fetch_sub(1) - 1;
    if (newCount == 0) {
        CloseSharedMemory(sDriverState);
        pthread_mutex_destroy(&sDriverState->ioMutex);
        delete sDriverState;
        sDriverState = nullptr;
    }
    return newCount;
}

// =============================================================================
#pragma mark -  Initialize / Device lifecycle
// =============================================================================

static OSStatus SoundDeck_Initialize(AudioServerPlugInDriverRef inDriver, AudioServerPlugInHostRef inHost) {
    sDriverState->host = inHost;
    sDriverState->ticksPerFrame = HostTicksPerFrame();
    sDriverLog = os_log_create("com.sounddeck.driver", "AudioServerPlugin");
    DriverLog("Initialize called, ticksPerFrame=%llu", sDriverState->ticksPerFrame);
    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_CreateDevice(AudioServerPlugInDriverRef inDriver,
    CFDictionaryRef inDescription, const AudioServerPlugInClientInfo* inClientInfo,
    AudioObjectID* outDeviceObjectID)
{
    // We don't support dynamic device creation
    return kAudioHardwareUnsupportedOperationError;
}

static OSStatus SoundDeck_DestroyDevice(AudioServerPlugInDriverRef inDriver, AudioObjectID inDeviceObjectID) {
    return kAudioHardwareUnsupportedOperationError;
}

static OSStatus SoundDeck_AddDeviceClient(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, const AudioServerPlugInClientInfo* inClientInfo)
{
    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_RemoveDeviceClient(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, const AudioServerPlugInClientInfo* inClientInfo)
{
    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_PerformDeviceConfigurationChange(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt64 inChangeAction, void* inChangeInfo)
{
    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_AbortDeviceConfigurationChange(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt64 inChangeAction, void* inChangeInfo)
{
    return kAudioHardwareNoError;
}

// =============================================================================
#pragma mark -  Property Dispatch Helpers
// =============================================================================

// Convenience macro for writing property data with bounds checking
#define WRITE_PROP(type, value) do { \
    if (inDataSize < sizeof(type)) return kAudioHardwareBadPropertySizeError; \
    *static_cast<type*>(outData) = (value); \
    *outDataSize = sizeof(type); \
} while(0)

#define WRITE_PROP_CF(cfval) do { \
    if (inDataSize < sizeof(CFStringRef)) return kAudioHardwareBadPropertySizeError; \
    *static_cast<CFStringRef*>(outData) = (cfval); \
    *outDataSize = sizeof(CFStringRef); \
} while(0)

// =============================================================================
#pragma mark -  Plugin Properties
// =============================================================================

static Boolean Plugin_HasProperty(pid_t inClientPID, const AudioObjectPropertyAddress* inAddress) {
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioObjectPropertyManufacturer:
        case kAudioPlugInPropertyDeviceList:
        case kAudioPlugInPropertyTranslateUIDToDevice:
        case kAudioPlugInPropertyResourceBundle:
            return true;
        default:
            return false;
    }
}

static OSStatus Plugin_IsPropertySettable(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress, Boolean* outIsSettable)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioObjectPropertyManufacturer:
        case kAudioPlugInPropertyDeviceList:
        case kAudioPlugInPropertyTranslateUIDToDevice:
        case kAudioPlugInPropertyResourceBundle:
            *outIsSettable = false;
            return kAudioHardwareNoError;
        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus Plugin_GetPropertyDataSize(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32* outDataSize)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
            *outDataSize = sizeof(AudioClassID);
            return kAudioHardwareNoError;
        case kAudioObjectPropertyClass:
            *outDataSize = sizeof(AudioClassID);
            return kAudioHardwareNoError;
        case kAudioObjectPropertyOwner:
            *outDataSize = sizeof(AudioObjectID);
            return kAudioHardwareNoError;
        case kAudioObjectPropertyManufacturer:
            *outDataSize = sizeof(CFStringRef);
            return kAudioHardwareNoError;
        case kAudioPlugInPropertyDeviceList:
            *outDataSize = sizeof(AudioObjectID); // 1 device
            return kAudioHardwareNoError;
        case kAudioPlugInPropertyTranslateUIDToDevice:
            *outDataSize = sizeof(AudioObjectID);
            return kAudioHardwareNoError;
        case kAudioPlugInPropertyResourceBundle:
            *outDataSize = sizeof(CFStringRef);
            return kAudioHardwareNoError;
        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus Plugin_GetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, UInt32* outDataSize, void* outData)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
            WRITE_PROP(AudioClassID, kAudioObjectClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyClass:
            WRITE_PROP(AudioClassID, kAudioPlugInClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            WRITE_PROP(AudioObjectID, kAudioObjectUnknown);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyManufacturer:
            WRITE_PROP_CF(CFSTR(kSoundDeckManufacturer));
            return kAudioHardwareNoError;

        case kAudioPlugInPropertyDeviceList:
            WRITE_PROP(AudioObjectID, kObjectID_Device);
            return kAudioHardwareNoError;

        case kAudioPlugInPropertyTranslateUIDToDevice: {
            if (inQualifierDataSize < sizeof(CFStringRef) || inQualifierData == nullptr) {
                return kAudioHardwareBadPropertySizeError;
            }
            CFStringRef uid = *static_cast<const CFStringRef*>(inQualifierData);
            CFStringRef deviceUID = CFSTR(kSoundDeckDeviceUID);
            AudioObjectID result = kAudioObjectUnknown;
            if (CFStringCompare(uid, deviceUID, 0) == kCFCompareEqualTo) {
                result = kObjectID_Device;
            }
            WRITE_PROP(AudioObjectID, result);
            return kAudioHardwareNoError;
        }

        case kAudioPlugInPropertyResourceBundle:
            WRITE_PROP_CF(CFSTR(""));
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

// =============================================================================
#pragma mark -  Device Properties
// =============================================================================

static Boolean Device_HasProperty(pid_t inClientPID, const AudioObjectPropertyAddress* inAddress) {
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioObjectPropertyName:
        case kAudioObjectPropertyManufacturer:
        case kAudioDevicePropertyDeviceUID:
        case kAudioDevicePropertyModelUID:
        case kAudioDevicePropertyTransportType:
        case kAudioDevicePropertyRelatedDevices:
        case kAudioDevicePropertyClockDomain:
        case kAudioDevicePropertyDeviceIsAlive:
        case kAudioDevicePropertyDeviceIsRunning:
        case kAudioDevicePropertyDeviceCanBeDefaultDevice:
        case kAudioDevicePropertyDeviceCanBeDefaultSystemDevice:
        case kAudioDevicePropertyLatency:
        case kAudioDevicePropertyStreams:
        case kAudioObjectPropertyControlList:
        case kAudioDevicePropertySafetyOffset:
        case kAudioDevicePropertyNominalSampleRate:
        case kAudioDevicePropertyAvailableNominalSampleRates:
        case kAudioDevicePropertyIsHidden:
        case kAudioDevicePropertyZeroTimeStampPeriod:
        case kAudioDevicePropertyIcon:
        case kAudioDevicePropertyPreferredChannelsForStereo:
        case kAudioDevicePropertyPreferredChannelLayout:
            return true;
        default:
            return false;
    }
}

static OSStatus Device_IsPropertySettable(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress, Boolean* outIsSettable)
{
    switch (inAddress->mSelector) {
        case kAudioDevicePropertyNominalSampleRate:
            // We allow SetPropertyData to be called but we'll just ignore changes
            *outIsSettable = false;
            return kAudioHardwareNoError;

        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioObjectPropertyName:
        case kAudioObjectPropertyManufacturer:
        case kAudioDevicePropertyDeviceUID:
        case kAudioDevicePropertyModelUID:
        case kAudioDevicePropertyTransportType:
        case kAudioDevicePropertyRelatedDevices:
        case kAudioDevicePropertyClockDomain:
        case kAudioDevicePropertyDeviceIsAlive:
        case kAudioDevicePropertyDeviceIsRunning:
        case kAudioDevicePropertyDeviceCanBeDefaultDevice:
        case kAudioDevicePropertyDeviceCanBeDefaultSystemDevice:
        case kAudioDevicePropertyLatency:
        case kAudioDevicePropertyStreams:
        case kAudioObjectPropertyControlList:
        case kAudioDevicePropertySafetyOffset:
        case kAudioDevicePropertyAvailableNominalSampleRates:
        case kAudioDevicePropertyIsHidden:
        case kAudioDevicePropertyZeroTimeStampPeriod:
        case kAudioDevicePropertyIcon:
        case kAudioDevicePropertyPreferredChannelsForStereo:
        case kAudioDevicePropertyPreferredChannelLayout:
            *outIsSettable = false;
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus Device_GetPropertyDataSize(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32* outDataSize)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
            *outDataSize = sizeof(AudioClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            *outDataSize = sizeof(AudioObjectID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyName:
        case kAudioObjectPropertyManufacturer:
        case kAudioDevicePropertyDeviceUID:
        case kAudioDevicePropertyModelUID:
            *outDataSize = sizeof(CFStringRef);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyTransportType:
        case kAudioDevicePropertyClockDomain:
            *outDataSize = sizeof(UInt32);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyRelatedDevices:
            *outDataSize = sizeof(AudioObjectID); // just self
            return kAudioHardwareNoError;

        case kAudioDevicePropertyDeviceIsAlive:
        case kAudioDevicePropertyDeviceIsRunning:
        case kAudioDevicePropertyDeviceCanBeDefaultDevice:
        case kAudioDevicePropertyDeviceCanBeDefaultSystemDevice:
        case kAudioDevicePropertyIsHidden:
            *outDataSize = sizeof(UInt32);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyLatency:
        case kAudioDevicePropertySafetyOffset:
        case kAudioDevicePropertyZeroTimeStampPeriod:
            *outDataSize = sizeof(UInt32);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyStreams:
            // 1 input stream only — only return it for input scope
            if (inAddress->mScope == kAudioObjectPropertyScopeInput ||
                inAddress->mScope == kAudioObjectPropertyScopeGlobal) {
                *outDataSize = sizeof(AudioObjectID);
            } else {
                *outDataSize = 0;
            }
            return kAudioHardwareNoError;

        case kAudioObjectPropertyControlList:
            *outDataSize = sizeof(AudioObjectID) * 2; // volume + mute
            return kAudioHardwareNoError;

        case kAudioDevicePropertyNominalSampleRate:
            *outDataSize = sizeof(Float64);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyAvailableNominalSampleRates:
            *outDataSize = sizeof(AudioValueRange); // single rate
            return kAudioHardwareNoError;

        case kAudioDevicePropertyIcon:
            *outDataSize = sizeof(CFURLRef);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyPreferredChannelsForStereo:
            *outDataSize = sizeof(UInt32) * 2;
            return kAudioHardwareNoError;

        case kAudioDevicePropertyPreferredChannelLayout: {
            *outDataSize = (UInt32)(offsetof(AudioChannelLayout, mChannelDescriptions) +
                           sizeof(AudioChannelDescription) * kSoundDeckChannelCount);
            return kAudioHardwareNoError;
        }

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus Device_GetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, UInt32* outDataSize, void* outData)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
            WRITE_PROP(AudioClassID, kAudioObjectClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyClass:
            WRITE_PROP(AudioClassID, kAudioDeviceClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            WRITE_PROP(AudioObjectID, kAudioObjectPlugInObject);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyName:
            WRITE_PROP_CF(CFSTR(kSoundDeckDeviceName));
            return kAudioHardwareNoError;

        case kAudioObjectPropertyManufacturer:
            WRITE_PROP_CF(CFSTR(kSoundDeckManufacturer));
            return kAudioHardwareNoError;

        case kAudioDevicePropertyDeviceUID:
            WRITE_PROP_CF(CFSTR(kSoundDeckDeviceUID));
            return kAudioHardwareNoError;

        case kAudioDevicePropertyModelUID:
            WRITE_PROP_CF(CFSTR(kSoundDeckDeviceUID));
            return kAudioHardwareNoError;

        case kAudioDevicePropertyTransportType:
            WRITE_PROP(UInt32, kAudioDeviceTransportTypeVirtual);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyRelatedDevices:
            WRITE_PROP(AudioObjectID, kObjectID_Device);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyClockDomain:
            WRITE_PROP(UInt32, 0);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyDeviceIsAlive:
            WRITE_PROP(UInt32, 1);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyDeviceIsRunning:
            WRITE_PROP(UInt32, sDriverState->ioRunning.load() ? 1 : 0);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyDeviceCanBeDefaultDevice:
            // Allow this device to be selected as default input
            WRITE_PROP(UInt32, (inAddress->mScope == kAudioObjectPropertyScopeInput) ? 1 : 0);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyDeviceCanBeDefaultSystemDevice:
            // System device is for output sounds — we are input only
            WRITE_PROP(UInt32, 0);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyLatency:
            // Latency in frames; our ring buffer introduces ~1 IO buffer of latency
            WRITE_PROP(UInt32, 0);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyStreams:
            if (inAddress->mScope == kAudioObjectPropertyScopeInput ||
                inAddress->mScope == kAudioObjectPropertyScopeGlobal) {
                WRITE_PROP(AudioObjectID, kObjectID_Stream_Input);
            } else {
                *outDataSize = 0;
            }
            return kAudioHardwareNoError;

        case kAudioObjectPropertyControlList: {
            if (inDataSize < sizeof(AudioObjectID) * 2) {
                return kAudioHardwareBadPropertySizeError;
            }
            AudioObjectID* ids = static_cast<AudioObjectID*>(outData);
            ids[0] = kObjectID_Volume_Control;
            ids[1] = kObjectID_Mute_Control;
            *outDataSize = sizeof(AudioObjectID) * 2;
            return kAudioHardwareNoError;
        }

        case kAudioDevicePropertySafetyOffset:
            WRITE_PROP(UInt32, 0);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyNominalSampleRate:
            WRITE_PROP(Float64, kSoundDeckSampleRate);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyAvailableNominalSampleRates: {
            if (inDataSize < sizeof(AudioValueRange)) {
                return kAudioHardwareBadPropertySizeError;
            }
            AudioValueRange* range = static_cast<AudioValueRange*>(outData);
            range->mMinimum = kSoundDeckSampleRate;
            range->mMaximum = kSoundDeckSampleRate;
            *outDataSize = sizeof(AudioValueRange);
            return kAudioHardwareNoError;
        }

        case kAudioDevicePropertyIsHidden:
            WRITE_PROP(UInt32, 0);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyZeroTimeStampPeriod:
            WRITE_PROP(UInt32, kSoundDeckRingBufferFrames);
            return kAudioHardwareNoError;

        case kAudioDevicePropertyIcon: {
            // No icon URL — return null
            if (inDataSize < sizeof(CFURLRef)) return kAudioHardwareBadPropertySizeError;
            *static_cast<CFURLRef*>(outData) = (CFURLRef)NULL;
            *outDataSize = sizeof(CFURLRef);
            return kAudioHardwareNoError;
        }

        case kAudioDevicePropertyPreferredChannelsForStereo: {
            if (inDataSize < sizeof(UInt32) * 2) {
                return kAudioHardwareBadPropertySizeError;
            }
            UInt32* channels = static_cast<UInt32*>(outData);
            channels[0] = 1;
            channels[1] = 1; // Mono — both stereo channels map to ch 1
            *outDataSize = sizeof(UInt32) * 2;
            return kAudioHardwareNoError;
        }

        case kAudioDevicePropertyPreferredChannelLayout: {
            UInt32 layoutSize = (UInt32)(offsetof(AudioChannelLayout, mChannelDescriptions) +
                                sizeof(AudioChannelDescription) * kSoundDeckChannelCount);
            if (inDataSize < layoutSize) {
                return kAudioHardwareBadPropertySizeError;
            }
            AudioChannelLayout* layout = static_cast<AudioChannelLayout*>(outData);
            layout->mChannelLayoutTag = kAudioChannelLayoutTag_UseChannelDescriptions;
            layout->mChannelBitmap = 0;
            layout->mNumberChannelDescriptions = kSoundDeckChannelCount;
            layout->mChannelDescriptions[0].mChannelLabel = kAudioChannelLabel_Mono;
            layout->mChannelDescriptions[0].mChannelFlags = 0;
            layout->mChannelDescriptions[0].mCoordinates[0] = 0;
            layout->mChannelDescriptions[0].mCoordinates[1] = 0;
            layout->mChannelDescriptions[0].mCoordinates[2] = 0;
            *outDataSize = layoutSize;
            return kAudioHardwareNoError;
        }

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus Device_SetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, const void* inData)
{
    // We don't support setting any device properties from the host side.
    // Volume and mute are controlled via their own control objects.
    switch (inAddress->mSelector) {
        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

// =============================================================================
#pragma mark -  Stream Properties
// =============================================================================

static Boolean Stream_HasProperty(pid_t inClientPID, const AudioObjectPropertyAddress* inAddress) {
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioStreamPropertyIsActive:
        case kAudioStreamPropertyDirection:
        case kAudioStreamPropertyTerminalType:
        case kAudioStreamPropertyStartingChannel:
        case kAudioStreamPropertyLatency:
        case kAudioStreamPropertyVirtualFormat:
        case kAudioStreamPropertyPhysicalFormat:
        case kAudioStreamPropertyAvailableVirtualFormats:
        case kAudioStreamPropertyAvailablePhysicalFormats:
            return true;
        default:
            return false;
    }
}

static OSStatus Stream_IsPropertySettable(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress, Boolean* outIsSettable)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioStreamPropertyIsActive:
        case kAudioStreamPropertyDirection:
        case kAudioStreamPropertyTerminalType:
        case kAudioStreamPropertyStartingChannel:
        case kAudioStreamPropertyLatency:
        case kAudioStreamPropertyAvailableVirtualFormats:
        case kAudioStreamPropertyAvailablePhysicalFormats:
            *outIsSettable = false;
            return kAudioHardwareNoError;

        case kAudioStreamPropertyVirtualFormat:
        case kAudioStreamPropertyPhysicalFormat:
            // Report settable but we only accept our one format
            *outIsSettable = true;
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static void FillStreamDescription(AudioStreamBasicDescription* outDesc) {
    memset(outDesc, 0, sizeof(AudioStreamBasicDescription));
    outDesc->mSampleRate       = kSoundDeckSampleRate;
    outDesc->mFormatID         = kAudioFormatLinearPCM;
    outDesc->mFormatFlags      = kAudioFormatFlagIsFloat
                                | kAudioFormatFlagsNativeEndian
                                | kAudioFormatFlagIsPacked;
    outDesc->mBytesPerPacket   = kSoundDeckBytesPerFrame;
    outDesc->mFramesPerPacket  = 1;
    outDesc->mBytesPerFrame    = kSoundDeckBytesPerFrame;
    outDesc->mChannelsPerFrame = kSoundDeckChannelCount;
    outDesc->mBitsPerChannel   = kSoundDeckBitsPerChannel;
}

static OSStatus Stream_GetPropertyDataSize(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32* outDataSize)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
            *outDataSize = sizeof(AudioClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            *outDataSize = sizeof(AudioObjectID);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyIsActive:
        case kAudioStreamPropertyDirection:
        case kAudioStreamPropertyTerminalType:
        case kAudioStreamPropertyStartingChannel:
        case kAudioStreamPropertyLatency:
            *outDataSize = sizeof(UInt32);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyVirtualFormat:
        case kAudioStreamPropertyPhysicalFormat:
            *outDataSize = sizeof(AudioStreamBasicDescription);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyAvailableVirtualFormats:
        case kAudioStreamPropertyAvailablePhysicalFormats:
            *outDataSize = sizeof(AudioStreamRangedDescription);
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus Stream_GetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, UInt32* outDataSize, void* outData)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
            WRITE_PROP(AudioClassID, kAudioObjectClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyClass:
            WRITE_PROP(AudioClassID, kAudioStreamClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            WRITE_PROP(AudioObjectID, kObjectID_Device);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyIsActive:
            // Stream is always active on a virtual device
            WRITE_PROP(UInt32, 1);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyDirection:
            // 1 = input (recording)
            WRITE_PROP(UInt32, 1);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyTerminalType:
            WRITE_PROP(UInt32, kAudioStreamTerminalTypeMicrophone);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyStartingChannel:
            WRITE_PROP(UInt32, 1);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyLatency:
            WRITE_PROP(UInt32, 0);
            return kAudioHardwareNoError;

        case kAudioStreamPropertyVirtualFormat:
        case kAudioStreamPropertyPhysicalFormat: {
            if (inDataSize < sizeof(AudioStreamBasicDescription)) {
                return kAudioHardwareBadPropertySizeError;
            }
            FillStreamDescription(static_cast<AudioStreamBasicDescription*>(outData));
            *outDataSize = sizeof(AudioStreamBasicDescription);
            return kAudioHardwareNoError;
        }

        case kAudioStreamPropertyAvailableVirtualFormats:
        case kAudioStreamPropertyAvailablePhysicalFormats: {
            if (inDataSize < sizeof(AudioStreamRangedDescription)) {
                return kAudioHardwareBadPropertySizeError;
            }
            AudioStreamRangedDescription* desc = static_cast<AudioStreamRangedDescription*>(outData);
            FillStreamDescription(&desc->mFormat);
            desc->mSampleRateRange.mMinimum = kSoundDeckSampleRate;
            desc->mSampleRateRange.mMaximum = kSoundDeckSampleRate;
            *outDataSize = sizeof(AudioStreamRangedDescription);
            return kAudioHardwareNoError;
        }

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus Stream_SetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, const void* inData)
{
    switch (inAddress->mSelector) {
        case kAudioStreamPropertyVirtualFormat:
        case kAudioStreamPropertyPhysicalFormat: {
            // Validate that caller is requesting our one supported format
            if (inDataSize < sizeof(AudioStreamBasicDescription)) {
                return kAudioHardwareBadPropertySizeError;
            }
            const AudioStreamBasicDescription* requested =
                static_cast<const AudioStreamBasicDescription*>(inData);
            // Accept silently — we only ever provide our one format
            if (requested->mSampleRate != kSoundDeckSampleRate &&
                requested->mSampleRate != 0) {
                return kAudioDeviceUnsupportedFormatError;
            }
            return kAudioHardwareNoError;
        }
        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

// =============================================================================
#pragma mark -  Volume Control Properties
// =============================================================================

static Boolean VolumeControl_HasProperty(pid_t inClientPID, const AudioObjectPropertyAddress* inAddress) {
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioObjectPropertyOwnedObjects:
        case kAudioControlPropertyScope:
        case kAudioControlPropertyElement:
        case kAudioLevelControlPropertyScalarValue:
        case kAudioLevelControlPropertyDecibelValue:
        case kAudioLevelControlPropertyDecibelRange:
        case kAudioLevelControlPropertyConvertScalarToDecibels:
        case kAudioLevelControlPropertyConvertDecibelsToScalar:
            return true;
        default:
            return false;
    }
}

static OSStatus VolumeControl_IsPropertySettable(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress, Boolean* outIsSettable)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioObjectPropertyOwnedObjects:
        case kAudioControlPropertyScope:
        case kAudioControlPropertyElement:
        case kAudioLevelControlPropertyDecibelRange:
        case kAudioLevelControlPropertyConvertScalarToDecibels:
        case kAudioLevelControlPropertyConvertDecibelsToScalar:
            *outIsSettable = false;
            return kAudioHardwareNoError;

        case kAudioLevelControlPropertyScalarValue:
        case kAudioLevelControlPropertyDecibelValue:
            *outIsSettable = true;
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

// Volume dB range: -96 dB to 0 dB
static const Float32 kVolumeMinDB = -96.0f;
static const Float32 kVolumeMaxDB = 0.0f;

static Float32 ScalarToDB(Float32 scalar) {
    if (scalar <= 0.0f) return kVolumeMinDB;
    if (scalar >= 1.0f) return kVolumeMaxDB;
    // Simple log scale: dB = 20 * log10(scalar)
    Float32 db = 20.0f * log10f(scalar);
    if (db < kVolumeMinDB) db = kVolumeMinDB;
    return db;
}

static Float32 DBToScalar(Float32 db) {
    if (db <= kVolumeMinDB) return 0.0f;
    if (db >= kVolumeMaxDB) return 1.0f;
    return powf(10.0f, db / 20.0f);
}

static OSStatus VolumeControl_GetPropertyDataSize(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32* outDataSize)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
            *outDataSize = sizeof(AudioClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            *outDataSize = sizeof(AudioObjectID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwnedObjects:
            *outDataSize = 0;
            return kAudioHardwareNoError;

        case kAudioControlPropertyScope:
        case kAudioControlPropertyElement:
            *outDataSize = sizeof(UInt32);
            return kAudioHardwareNoError;

        case kAudioLevelControlPropertyScalarValue:
            *outDataSize = sizeof(Float32);
            return kAudioHardwareNoError;

        case kAudioLevelControlPropertyDecibelValue:
            *outDataSize = sizeof(Float32);
            return kAudioHardwareNoError;

        case kAudioLevelControlPropertyDecibelRange:
            *outDataSize = sizeof(AudioValueRange);
            return kAudioHardwareNoError;

        case kAudioLevelControlPropertyConvertScalarToDecibels:
        case kAudioLevelControlPropertyConvertDecibelsToScalar:
            *outDataSize = sizeof(Float32);
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus VolumeControl_GetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, UInt32* outDataSize, void* outData)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
            WRITE_PROP(AudioClassID, kAudioControlClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyClass:
            WRITE_PROP(AudioClassID, kAudioVolumeControlClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            WRITE_PROP(AudioObjectID, kObjectID_Device);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwnedObjects:
            *outDataSize = 0;
            return kAudioHardwareNoError;

        case kAudioControlPropertyScope:
            WRITE_PROP(UInt32, kAudioObjectPropertyScopeInput);
            return kAudioHardwareNoError;

        case kAudioControlPropertyElement:
            WRITE_PROP(UInt32, kAudioObjectPropertyElementMain);
            return kAudioHardwareNoError;

        case kAudioLevelControlPropertyScalarValue: {
            Float32 vol = sDriverState->volumeLevel.load();
            WRITE_PROP(Float32, vol);
            return kAudioHardwareNoError;
        }

        case kAudioLevelControlPropertyDecibelValue: {
            Float32 vol = sDriverState->volumeLevel.load();
            Float32 db = ScalarToDB(vol);
            WRITE_PROP(Float32, db);
            return kAudioHardwareNoError;
        }

        case kAudioLevelControlPropertyDecibelRange: {
            if (inDataSize < sizeof(AudioValueRange)) {
                return kAudioHardwareBadPropertySizeError;
            }
            AudioValueRange* range = static_cast<AudioValueRange*>(outData);
            range->mMinimum = kVolumeMinDB;
            range->mMaximum = kVolumeMaxDB;
            *outDataSize = sizeof(AudioValueRange);
            return kAudioHardwareNoError;
        }

        case kAudioLevelControlPropertyConvertScalarToDecibels: {
            if (inDataSize < sizeof(Float32)) return kAudioHardwareBadPropertySizeError;
            Float32* ioValue = static_cast<Float32*>(outData);
            *ioValue = ScalarToDB(*ioValue);
            *outDataSize = sizeof(Float32);
            return kAudioHardwareNoError;
        }

        case kAudioLevelControlPropertyConvertDecibelsToScalar: {
            if (inDataSize < sizeof(Float32)) return kAudioHardwareBadPropertySizeError;
            Float32* ioValue = static_cast<Float32*>(outData);
            *ioValue = DBToScalar(*ioValue);
            *outDataSize = sizeof(Float32);
            return kAudioHardwareNoError;
        }

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus VolumeControl_SetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, const void* inData)
{
    switch (inAddress->mSelector) {
        case kAudioLevelControlPropertyScalarValue: {
            if (inDataSize < sizeof(Float32)) return kAudioHardwareBadPropertySizeError;
            Float32 newVol = *static_cast<const Float32*>(inData);
            if (newVol < 0.0f) newVol = 0.0f;
            if (newVol > 1.0f) newVol = 1.0f;
            sDriverState->volumeLevel.store(newVol);
            // Also push to shared memory if connected
            if (sDriverState->sharedBuffer != nullptr) {
                atomic_store_explicit(&sDriverState->sharedBuffer->volume, newVol, memory_order_relaxed);
            }
            // Notify the host that volume changed
            if (sDriverState->host != nullptr) {
                AudioObjectPropertyAddress changedAddr = {
                    kAudioLevelControlPropertyScalarValue,
                    kAudioObjectPropertyScopeGlobal,
                    kAudioObjectPropertyElementMain
                };
                sDriverState->host->PropertiesChanged(sDriverState->host,
                    kObjectID_Volume_Control, 1, &changedAddr);
            }
            return kAudioHardwareNoError;
        }

        case kAudioLevelControlPropertyDecibelValue: {
            if (inDataSize < sizeof(Float32)) return kAudioHardwareBadPropertySizeError;
            Float32 db = *static_cast<const Float32*>(inData);
            Float32 newVol = DBToScalar(db);
            sDriverState->volumeLevel.store(newVol);
            if (sDriverState->sharedBuffer != nullptr) {
                atomic_store_explicit(&sDriverState->sharedBuffer->volume, newVol, memory_order_relaxed);
            }
            if (sDriverState->host != nullptr) {
                AudioObjectPropertyAddress changedAddr = {
                    kAudioLevelControlPropertyDecibelValue,
                    kAudioObjectPropertyScopeGlobal,
                    kAudioObjectPropertyElementMain
                };
                sDriverState->host->PropertiesChanged(sDriverState->host,
                    kObjectID_Volume_Control, 1, &changedAddr);
            }
            return kAudioHardwareNoError;
        }

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

// =============================================================================
#pragma mark -  Mute Control Properties
// =============================================================================

static Boolean MuteControl_HasProperty(pid_t inClientPID, const AudioObjectPropertyAddress* inAddress) {
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioObjectPropertyOwnedObjects:
        case kAudioControlPropertyScope:
        case kAudioControlPropertyElement:
        case kAudioBooleanControlPropertyValue:
            return true;
        default:
            return false;
    }
}

static OSStatus MuteControl_IsPropertySettable(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress, Boolean* outIsSettable)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
        case kAudioObjectPropertyOwner:
        case kAudioObjectPropertyOwnedObjects:
        case kAudioControlPropertyScope:
        case kAudioControlPropertyElement:
            *outIsSettable = false;
            return kAudioHardwareNoError;

        case kAudioBooleanControlPropertyValue:
            *outIsSettable = true;
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus MuteControl_GetPropertyDataSize(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32* outDataSize)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
        case kAudioObjectPropertyClass:
            *outDataSize = sizeof(AudioClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            *outDataSize = sizeof(AudioObjectID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwnedObjects:
            *outDataSize = 0;
            return kAudioHardwareNoError;

        case kAudioControlPropertyScope:
        case kAudioControlPropertyElement:
            *outDataSize = sizeof(UInt32);
            return kAudioHardwareNoError;

        case kAudioBooleanControlPropertyValue:
            *outDataSize = sizeof(UInt32);
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus MuteControl_GetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, UInt32* outDataSize, void* outData)
{
    switch (inAddress->mSelector) {
        case kAudioObjectPropertyBaseClass:
            WRITE_PROP(AudioClassID, kAudioControlClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyClass:
            WRITE_PROP(AudioClassID, kAudioMuteControlClassID);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwner:
            WRITE_PROP(AudioObjectID, kObjectID_Device);
            return kAudioHardwareNoError;

        case kAudioObjectPropertyOwnedObjects:
            *outDataSize = 0;
            return kAudioHardwareNoError;

        case kAudioControlPropertyScope:
            WRITE_PROP(UInt32, kAudioObjectPropertyScopeInput);
            return kAudioHardwareNoError;

        case kAudioControlPropertyElement:
            WRITE_PROP(UInt32, kAudioObjectPropertyElementMain);
            return kAudioHardwareNoError;

        case kAudioBooleanControlPropertyValue:
            WRITE_PROP(UInt32, sDriverState->muteState.load() ? 1 : 0);
            return kAudioHardwareNoError;

        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

static OSStatus MuteControl_SetPropertyData(pid_t inClientPID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, const void* inData)
{
    switch (inAddress->mSelector) {
        case kAudioBooleanControlPropertyValue: {
            if (inDataSize < sizeof(UInt32)) return kAudioHardwareBadPropertySizeError;
            UInt32 newMute = *static_cast<const UInt32*>(inData);
            sDriverState->muteState.store(newMute != 0);
            if (sDriverState->sharedBuffer != nullptr) {
                atomic_store_explicit(&sDriverState->sharedBuffer->muted,
                    newMute ? 1u : 0u, memory_order_relaxed);
            }
            if (sDriverState->host != nullptr) {
                AudioObjectPropertyAddress changedAddr = {
                    kAudioBooleanControlPropertyValue,
                    kAudioObjectPropertyScopeGlobal,
                    kAudioObjectPropertyElementMain
                };
                sDriverState->host->PropertiesChanged(sDriverState->host,
                    kObjectID_Mute_Control, 1, &changedAddr);
            }
            return kAudioHardwareNoError;
        }
        default:
            return kAudioHardwareUnknownPropertyError;
    }
}

// =============================================================================
#pragma mark -  Property Dispatch (routes to per-object handlers)
// =============================================================================

static Boolean SoundDeck_HasProperty(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress)
{
    switch (inObjectID) {
        case kAudioObjectPlugInObject:
            return Plugin_HasProperty(inClientProcessID, inAddress);
        case kObjectID_Device:
            return Device_HasProperty(inClientProcessID, inAddress);
        case kObjectID_Stream_Input:
            return Stream_HasProperty(inClientProcessID, inAddress);
        case kObjectID_Volume_Control:
            return VolumeControl_HasProperty(inClientProcessID, inAddress);
        case kObjectID_Mute_Control:
            return MuteControl_HasProperty(inClientProcessID, inAddress);
        default:
            return false;
    }
}

static OSStatus SoundDeck_IsPropertySettable(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress, Boolean* outIsSettable)
{
    if (outIsSettable == nullptr) return kAudioHardwareIllegalOperationError;

    switch (inObjectID) {
        case kAudioObjectPlugInObject:
            return Plugin_IsPropertySettable(inClientProcessID, inAddress, outIsSettable);
        case kObjectID_Device:
            return Device_IsPropertySettable(inClientProcessID, inAddress, outIsSettable);
        case kObjectID_Stream_Input:
            return Stream_IsPropertySettable(inClientProcessID, inAddress, outIsSettable);
        case kObjectID_Volume_Control:
            return VolumeControl_IsPropertySettable(inClientProcessID, inAddress, outIsSettable);
        case kObjectID_Mute_Control:
            return MuteControl_IsPropertySettable(inClientProcessID, inAddress, outIsSettable);
        default:
            return kAudioHardwareBadObjectError;
    }
}

static OSStatus SoundDeck_GetPropertyDataSize(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32* outDataSize)
{
    if (outDataSize == nullptr) return kAudioHardwareIllegalOperationError;

    switch (inObjectID) {
        case kAudioObjectPlugInObject:
            return Plugin_GetPropertyDataSize(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, outDataSize);
        case kObjectID_Device:
            return Device_GetPropertyDataSize(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, outDataSize);
        case kObjectID_Stream_Input:
            return Stream_GetPropertyDataSize(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, outDataSize);
        case kObjectID_Volume_Control:
            return VolumeControl_GetPropertyDataSize(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, outDataSize);
        case kObjectID_Mute_Control:
            return MuteControl_GetPropertyDataSize(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, outDataSize);
        default:
            return kAudioHardwareBadObjectError;
    }
}

static OSStatus SoundDeck_GetPropertyData(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, UInt32* outDataSize, void* outData)
{
    if (outDataSize == nullptr || outData == nullptr) return kAudioHardwareIllegalOperationError;

    switch (inObjectID) {
        case kAudioObjectPlugInObject:
            return Plugin_GetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, outDataSize, outData);
        case kObjectID_Device:
            return Device_GetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, outDataSize, outData);
        case kObjectID_Stream_Input:
            return Stream_GetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, outDataSize, outData);
        case kObjectID_Volume_Control:
            return VolumeControl_GetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, outDataSize, outData);
        case kObjectID_Mute_Control:
            return MuteControl_GetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, outDataSize, outData);
        default:
            return kAudioHardwareBadObjectError;
    }
}

static OSStatus SoundDeck_SetPropertyData(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inObjectID, pid_t inClientProcessID,
    const AudioObjectPropertyAddress* inAddress,
    UInt32 inQualifierDataSize, const void* inQualifierData,
    UInt32 inDataSize, const void* inData)
{
    switch (inObjectID) {
        case kAudioObjectPlugInObject:
            return kAudioHardwareUnknownPropertyError;
        case kObjectID_Device:
            return Device_SetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, inData);
        case kObjectID_Stream_Input:
            return Stream_SetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, inData);
        case kObjectID_Volume_Control:
            return VolumeControl_SetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, inData);
        case kObjectID_Mute_Control:
            return MuteControl_SetPropertyData(inClientProcessID, inAddress,
                inQualifierDataSize, inQualifierData, inDataSize, inData);
        default:
            return kAudioHardwareBadObjectError;
    }
}

// =============================================================================
#pragma mark -  IO Operations
// =============================================================================

static OSStatus SoundDeck_StartIO(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID)
{
    if (inDeviceObjectID != kObjectID_Device) return kAudioHardwareBadObjectError;

    pthread_mutex_lock(&sDriverState->ioMutex);

    if (sDriverState->ioClientCount == 0) {
        // First client — open shared memory and anchor the clock
        if (!OpenSharedMemory(sDriverState)) {
            DriverLogError("StartIO: failed to open shared memory, will output silence");
            // Don't fail — still allow IO so apps don't break, just output silence
        }

        sDriverState->anchorHostTime = mach_absolute_time();
        sDriverState->ioFrameCount.store(0);
        sDriverState->ioRunning.store(true);

        // Sync volume/mute from shared memory if available
        if (sDriverState->sharedBuffer != nullptr) {
            sDriverState->volumeLevel.store(
                atomic_load_explicit(&sDriverState->sharedBuffer->volume, memory_order_relaxed));
            sDriverState->muteState.store(
                atomic_load_explicit(&sDriverState->sharedBuffer->muted, memory_order_relaxed) != 0);
        }

        DriverLog("StartIO: IO started, anchorHostTime=%llu", sDriverState->anchorHostTime);
    }

    sDriverState->ioClientCount++;
    pthread_mutex_unlock(&sDriverState->ioMutex);
    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_StopIO(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID)
{
    if (inDeviceObjectID != kObjectID_Device) return kAudioHardwareBadObjectError;

    pthread_mutex_lock(&sDriverState->ioMutex);

    if (sDriverState->ioClientCount > 0) {
        sDriverState->ioClientCount--;
    }

    if (sDriverState->ioClientCount == 0) {
        sDriverState->ioRunning.store(false);
        CloseSharedMemory(sDriverState);
        DriverLog("StopIO: IO stopped, all clients disconnected");
    }

    pthread_mutex_unlock(&sDriverState->ioMutex);
    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_GetZeroTimeStamp(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID,
    Float64* outSampleTime, UInt64* outHostTime, UInt64* outSeed)
{
    if (inDeviceObjectID != kObjectID_Device) return kAudioHardwareBadObjectError;

    // Compute the most recent zero timestamp that is at or before "now"
    // The zero timestamp period is kSoundDeckRingBufferFrames frames
    UInt64 now = mach_absolute_time();
    UInt64 anchorTime = sDriverState->anchorHostTime;
    UInt64 ticksPerPeriod = sDriverState->ticksPerFrame * kSoundDeckRingBufferFrames;

    if (ticksPerPeriod == 0) {
        // Safety: avoid divide by zero
        *outSampleTime = 0.0;
        *outHostTime = now;
        *outSeed = 0;
        return kAudioHardwareNoError;
    }

    UInt64 elapsed = now - anchorTime;
    UInt64 periodCount = elapsed / ticksPerPeriod;

    *outSampleTime = (Float64)(periodCount * kSoundDeckRingBufferFrames);
    *outHostTime = anchorTime + (periodCount * ticksPerPeriod);
    *outSeed = 1; // Seed changes only on clock discontinuities

    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_WillDoIOOperation(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID,
    UInt32 inOperationID, Boolean* outWillDo, Boolean* outIsInput)
{
    switch (inOperationID) {
        case kAudioServerPlugInIOOperationReadInput:
            *outWillDo = true;
            *outIsInput = true;
            return kAudioHardwareNoError;

        default:
            *outWillDo = false;
            *outIsInput = false;
            return kAudioHardwareNoError;
    }
}

static OSStatus SoundDeck_BeginIOOperation(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID,
    UInt32 inOperationID, UInt32 inIOBufferFrameSize,
    const AudioServerPlugInIOCycleInfo* inIOCycleInfo)
{
    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_DoIOOperation(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, AudioObjectID inStreamObjectID,
    UInt32 inClientID, UInt32 inOperationID,
    UInt32 inIOBufferFrameSize,
    const AudioServerPlugInIOCycleInfo* inIOCycleInfo,
    void* ioMainBuffer, void* ioSecondaryBuffer)
{
    if (inOperationID != kAudioServerPlugInIOOperationReadInput) {
        return kAudioHardwareNoError;
    }

    float* outBuffer = static_cast<float*>(ioMainBuffer);
    UInt32 framesToRead = inIOBufferFrameSize;

    // Read from the shared ring buffer
    SharedAudioBuffer* shm = sDriverState->sharedBuffer;
    if (shm != nullptr) {
        UInt32 framesRead = RingBuffer_Read(shm, outBuffer, framesToRead);
        // RingBuffer_Read already zero-fills on underrun

        // Apply volume and mute
        bool muted = sDriverState->muteState.load(std::memory_order_relaxed);
        float volume = sDriverState->volumeLevel.load(std::memory_order_relaxed);

        if (muted || volume <= 0.0f) {
            // Zero everything
            memset(outBuffer, 0, framesToRead * kSoundDeckChannelCount * sizeof(float));
        } else if (volume < 1.0f) {
            // Scale by volume
            UInt32 totalSamples = framesToRead * kSoundDeckChannelCount;
            for (UInt32 i = 0; i < totalSamples; i++) {
                outBuffer[i] *= volume;
            }
        }
        // If volume == 1.0 and not muted, data passes through unmodified
    } else {
        // No shared memory — output silence
        memset(outBuffer, 0, framesToRead * kSoundDeckChannelCount * sizeof(float));
    }

    // Track total frames delivered
    sDriverState->ioFrameCount.fetch_add(framesToRead, std::memory_order_relaxed);

    return kAudioHardwareNoError;
}

static OSStatus SoundDeck_EndIOOperation(AudioServerPlugInDriverRef inDriver,
    AudioObjectID inDeviceObjectID, UInt32 inClientID,
    UInt32 inOperationID, UInt32 inIOBufferFrameSize,
    const AudioServerPlugInIOCycleInfo* inIOCycleInfo)
{
    return kAudioHardwareNoError;
}

// =============================================================================
#pragma mark -  Factory Function (entry point)
// =============================================================================

extern "C" void* SoundDeckDriverFactory(CFAllocatorRef allocator, CFUUIDRef requestedTypeUUID) {
    // Verify the requested type matches our plugin type
    CFUUIDRef pluginTypeUUID = CFUUIDGetConstantUUIDWithBytes(NULL,
        0x44, 0x3A, 0xBA, 0xB8,
        0xE7, 0xB3,
        0x49, 0x1A,
        0xB9, 0x85,
        0xBE, 0xB9, 0x18, 0x70, 0x30, 0xDB);

    if (!CFEqual(requestedTypeUUID, pluginTypeUUID)) {
        return NULL;
    }

    // Create driver state (one-time initialization)
    if (sDriverState == nullptr) {
        sDriverState = new SoundDeckDriverState();
        sDriverLog = os_log_create("com.sounddeck.driver", "AudioServerPlugin");
        DriverLog("Factory: driver instance created");
    } else {
        sDriverState->refCount.fetch_add(1);
    }

    return &gDriverInterfacePtr;
}
