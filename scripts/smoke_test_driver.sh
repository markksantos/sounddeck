#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER_BIN="${INSTALLER_BIN:-}"
DRIVER_BUNDLE="${DRIVER_BUNDLE:-}"
INSTALL_PATH="/Library/Audio/Plug-Ins/HAL/SoundDeckDriver.driver"
DEVICE_NAME="SoundDeck Virtual Mic"

usage() {
  cat <<'USAGE'
Usage:
  INSTALLER_BIN=/path/to/SoundDeckInstaller DRIVER_BUNDLE=/path/to/SoundDeckDriver.driver scripts/smoke_test_driver.sh --install
  scripts/smoke_test_driver.sh --verify
  INSTALLER_BIN=/path/to/SoundDeckInstaller scripts/smoke_test_driver.sh --uninstall

This script is intended for a clean Mac release smoke test. `--install` and
`--uninstall` require sudo because the CoreAudio HAL directory is protected.
USAGE
}

fail() {
  printf '[driver-smoke] %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing command: $1"
}

verify_install_path_present() {
  [[ -d "$INSTALL_PATH" ]] || fail "Driver bundle is not installed at $INSTALL_PATH"
}

verify_device_present() {
  if system_profiler SPAudioDataType 2>/dev/null | grep -Fq "$DEVICE_NAME"; then
    printf '[driver-smoke] Found audio input: %s\n' "$DEVICE_NAME"
  else
    fail "Missing audio input: $DEVICE_NAME"
  fi
}

case "${1:-}" in
  --install)
    for tool in mktemp cp sudo sleep system_profiler grep; do
      require_command "$tool"
    done
    if [[ -z "$INSTALLER_BIN" || ! -x "$INSTALLER_BIN" ]]; then
      fail "INSTALLER_BIN must point to executable SoundDeckInstaller."
    fi
    if [[ -z "$DRIVER_BUNDLE" || ! -d "$DRIVER_BUNDLE" ]]; then
      fail "DRIVER_BUNDLE must point to SoundDeckDriver.driver."
    fi
    work_dir="$(mktemp -d)"
    trap 'rm -rf "$work_dir"' EXIT
    cp "$INSTALLER_BIN" "$work_dir/SoundDeckInstaller"
    cp -R "$DRIVER_BUNDLE" "$work_dir/SoundDeckDriver.driver"
    sudo "$work_dir/SoundDeckInstaller" install
    sleep 3
    verify_install_path_present
    verify_device_present
    ;;
  --verify)
    for tool in system_profiler grep; do
      require_command "$tool"
    done
    verify_install_path_present
    verify_device_present
    ;;
  --uninstall)
    for tool in sudo sleep system_profiler grep; do
      require_command "$tool"
    done
    if [[ -z "$INSTALLER_BIN" || ! -x "$INSTALLER_BIN" ]]; then
      fail "INSTALLER_BIN must point to executable SoundDeckInstaller."
    fi
    sudo "$INSTALLER_BIN" uninstall
    sleep 3
    if system_profiler SPAudioDataType 2>/dev/null | grep -Fq "$DEVICE_NAME"; then
      fail "Audio input still appears after uninstall: $DEVICE_NAME"
    fi
    printf '[driver-smoke] Driver uninstall verified.\n'
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
