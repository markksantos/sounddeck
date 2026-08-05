#!/usr/bin/env bash
# Generate release-safe bundled WAV files for SoundDeck's starter library.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT_DIR/Resources/DefaultSounds"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$DIR"

if ! command -v sox >/dev/null 2>&1; then
  cat >&2 <<'MSG'
sox is required to generate the bundled default sounds.
Install it with: brew install sox
MSG
  exit 1
fi

tone() {
  local out="$1"
  local duration="$2"
  local frequency="$3"
  local volume="${4:-0.32}"
  sox -n -r 48000 -c 1 -b 16 "$out" synth "$duration" sine "$frequency" vol "$volume" fade t 0.01 "$duration" 0.08
}

noise() {
  local out="$1"
  local duration="$2"
  local color="$3"
  local volume="${4:-0.08}"
  sox -n -r 48000 -c 1 -b 16 "$out" synth "$duration" "$color" vol "$volume" fade t 0.02 "$duration" 0.08
}

silence() {
  local out="$1"
  local duration="$2"
  sox -n -r 48000 -c 1 -b 16 "$out" synth "$duration" sine 0 vol 0
}

concat() {
  local out="$1"
  shift
  sox "$@" "$out"
}

doorbell() {
  tone "$TMP_DIR/doorbell-a.wav" 0.34 880 0.34
  tone "$TMP_DIR/doorbell-b.wav" 0.48 1320 0.28
  concat "$DIR/doorbell.wav" "$TMP_DIR/doorbell-a.wav" "$TMP_DIR/doorbell-b.wav"
}

phone_ring() {
  tone "$TMP_DIR/phone-a.wav" 0.24 440 0.28
  tone "$TMP_DIR/phone-b.wav" 0.24 480 0.28
  silence "$TMP_DIR/phone-gap.wav" 0.12
  concat "$DIR/phone_ring.wav" "$TMP_DIR/phone-a.wav" "$TMP_DIR/phone-b.wav" "$TMP_DIR/phone-gap.wav" "$TMP_DIR/phone-a.wav" "$TMP_DIR/phone-b.wav"
}

dog_bark() {
  noise "$TMP_DIR/bark-noise.wav" 0.18 whitenoise 0.11
  tone "$TMP_DIR/bark-low.wav" 0.18 180 0.24
  concat "$DIR/dog_bark.wav" "$TMP_DIR/bark-low.wav" "$TMP_DIR/bark-noise.wav" "$TMP_DIR/bark-low.wav"
}

baby_cry() {
  tone "$TMP_DIR/cry-a.wav" 0.22 520 0.20
  tone "$TMP_DIR/cry-b.wav" 0.28 690 0.22
  tone "$TMP_DIR/cry-c.wav" 0.20 470 0.18
  concat "$DIR/baby_cry.wav" "$TMP_DIR/cry-a.wav" "$TMP_DIR/cry-b.wav" "$TMP_DIR/cry-c.wav"
}

hold_music() {
  tone "$TMP_DIR/hold-a.wav" 0.38 392 0.18
  tone "$TMP_DIR/hold-b.wav" 0.38 494 0.18
  tone "$TMP_DIR/hold-c.wav" 0.38 587 0.18
  tone "$TMP_DIR/hold-d.wav" 0.55 523 0.16
  concat "$DIR/hold_music.wav" "$TMP_DIR/hold-a.wav" "$TMP_DIR/hold-b.wav" "$TMP_DIR/hold-c.wav" "$TMP_DIR/hold-d.wav"
}

applause() {
  noise "$DIR/applause.wav" 1.6 pinknoise 0.10
}

laugh_track() {
  tone "$TMP_DIR/laugh-a.wav" 0.18 330 0.22
  tone "$TMP_DIR/laugh-gap.wav" 0.06 0 0
  tone "$TMP_DIR/laugh-b.wav" 0.16 390 0.22
  tone "$TMP_DIR/laugh-c.wav" 0.22 300 0.20
  concat "$DIR/laugh_track.wav" "$TMP_DIR/laugh-a.wav" "$TMP_DIR/laugh-gap.wav" "$TMP_DIR/laugh-b.wav" "$TMP_DIR/laugh-gap.wav" "$TMP_DIR/laugh-c.wav"
}

alarm() {
  tone "$TMP_DIR/alarm-a.wav" 0.22 980 0.30
  tone "$TMP_DIR/alarm-b.wav" 0.22 1460 0.28
  concat "$DIR/alarm.wav" "$TMP_DIR/alarm-a.wav" "$TMP_DIR/alarm-b.wav" "$TMP_DIR/alarm-a.wav" "$TMP_DIR/alarm-b.wav"
}

traffic() {
  noise "$DIR/traffic.wav" 1.4 brownnoise 0.09
}

static_noise() {
  noise "$DIR/static.wav" 0.75 whitenoise 0.09
}

affirmation() {
  local name="$1"
  local first="$2"
  local second="$3"
  tone "$TMP_DIR/${name}-a.wav" 0.16 "$first" 0.22
  tone "$TMP_DIR/${name}-b.wav" 0.22 "$second" 0.18
  concat "$DIR/${name}.wav" "$TMP_DIR/${name}-a.wav" "$TMP_DIR/${name}-b.wav"
}

doorbell
phone_ring
dog_bark
baby_cry
hold_music
applause
laugh_track
alarm
traffic
static_noise
silence "$DIR/silence.wav" 1.0
affirmation "uh_huh_1" 240 300
affirmation "uh_huh_2" 260 330
affirmation "uh_huh_3" 230 290

printf 'Generated 14 bundled default sounds in %s\n' "$DIR"
