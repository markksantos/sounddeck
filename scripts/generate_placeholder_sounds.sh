#!/bin/bash
# Generate placeholder WAV files for default sounds.
# These are short sine wave tones at different frequencies to distinguish them.
# Replace with real sound effects before shipping.

set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)/Resources/DefaultSounds"
mkdir -p "$DIR"

# Check for sox or afplay availability
if ! command -v sox &>/dev/null; then
    echo "sox not found. Install with: brew install sox"
    echo "Generating empty WAV files as placeholders instead..."

    # Create minimal valid WAV files (44-byte header + silence)
    for name in doorbell phone_ring dog_bark baby_cry hold_music applause laugh_track \
                alarm traffic static silence uh_huh_1 uh_huh_2 uh_huh_3; do
        python3 -c "
import struct, sys
sr=48000; ch=1; dur=1; samples=sr*dur
header = struct.pack('<4sI4s4sIHHIIHH4sI',
    b'RIFF', 36+samples*2, b'WAVE', b'fmt ', 16, 1, ch, sr, sr*2, 2, 16,
    b'data', samples*2)
sys.stdout.buffer.write(header + b'\x00\x00'*samples)
" > "$DIR/${name}.wav"
        echo "Created $DIR/${name}.wav (silent placeholder)"
    done
    exit 0
fi

# With sox: generate distinguishable tones
generate_tone() {
    local name=$1 freq=$2 duration=$3
    sox -n -r 48000 -c 1 -b 16 "$DIR/${name}.wav" synth "$duration" sine "$freq" fade 0.01 "$duration" 0.05
    echo "Created $DIR/${name}.wav (${freq}Hz, ${duration}s)"
}

generate_tone "doorbell"    880  0.8
generate_tone "phone_ring"  1200 1.5
generate_tone "dog_bark"    300  0.5
generate_tone "baby_cry"    500  1.0
generate_tone "hold_music"  440  3.0
generate_tone "applause"    200  2.0
generate_tone "laugh_track" 350  1.5
generate_tone "alarm"       1000 1.0
generate_tone "traffic"     150  2.0
generate_tone "static"      100  1.0
generate_tone "silence"     0    1.0
generate_tone "uh_huh_1"    250  0.3
generate_tone "uh_huh_2"    280  0.4
generate_tone "uh_huh_3"    260  0.35

echo "Done! Generated 14 placeholder sounds in $DIR"
