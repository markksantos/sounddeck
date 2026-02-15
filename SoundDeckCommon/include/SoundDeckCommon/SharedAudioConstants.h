#ifndef SharedAudioConstants_h
#define SharedAudioConstants_h

// Device identity
#define kSoundDeckDeviceName        "SoundDeck Virtual Mic"
#define kSoundDeckDeviceUID         "com.sounddeck.virtualmic"
#define kSoundDeckManufacturer      "SoundDeck"
#define kSoundDeckBundleID          "com.sounddeck.driver"

// Shared memory
#define kSoundDeckSHMName           "/sounddeck_audio"
#define kSoundDeckSHMPath           kSoundDeckSHMName

// Audio format
#define kSoundDeckSampleRate        48000.0
#define kSoundDeckChannelCount      1
#define kSoundDeckBitsPerChannel    32
#define kSoundDeckBytesPerFrame     (sizeof(float) * kSoundDeckChannelCount)

// Ring buffer sizing
#define kSoundDeckRingBufferFrames  4096
#define kSoundDeckIOBufferFrames    256

// AudioServerPlugin UUIDs (must match Info.plist)
#define kSoundDeckPluginTypeUUID    "443ABAB8-E7B3-491A-B985-BEB9187030DB"

// Driver install path
#define kSoundDeckDriverInstallPath "/Library/Audio/Plug-Ins/HAL/SoundDeckDriver.driver"

#endif /* SharedAudioConstants_h */
