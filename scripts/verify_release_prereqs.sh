#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PLIST="${APP_PLIST:-$ROOT_DIR/SoundDeckApp/Info.plist}"
LANDING_DIR="$ROOT_DIR/landing"
EXPECTED_FEED_URL="https://updates.sounddeck.app/appcast.xml"
EXPECTED_PUBLIC_KEY_SETTING='$(SPARKLE_PUBLIC_ED_KEY)'

failures=0

info() {
  printf '[release-check] %s\n' "$1"
}

pass() {
  printf '[ok] %s\n' "$1"
}

fail() {
  printf '[missing] %s\n' "$1" >&2
  failures=$((failures + 1))
}

require_command() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "command available: $1"
  else
    fail "command not found: $1"
  fi
}

require_env() {
  local name="$1"
  local value="${!name:-}"
  if [[ -n "$value" ]]; then
    pass "env set: $name"
  else
    fail "env required: $name"
  fi
}

plist_value() {
  local key="$1"
  /usr/libexec/PlistBuddy -c "Print :${key}" "$APP_PLIST" 2>/dev/null || true
}

require_plist_value() {
  local key="$1"
  local expected="$2"
  local actual
  actual="$(plist_value "$key")"

  if [[ "$actual" == "$expected" ]]; then
    pass "$key matches release metadata"
  elif [[ -z "$actual" ]]; then
    fail "$key is missing"
  else
    fail "$key must be $expected"
  fi
}

is_https_url_with_host() {
  local value="$1"
  [[ "$value" =~ ^https://[^/?#[:space:]]+($|[/?#]) ]]
}

require_https_env() {
  local name="$1"
  local value="${!name:-}"
  if is_https_url_with_host "$value"; then
    pass "$name uses https with a host"
  else
    fail "$name must be an https URL with a non-empty host"
  fi
}

require_not_placeholder() {
  local name="$1"
  local value="${!name:-}"
  if [[ -z "$value" ||
        "$value" == *CHANGE_ME* ||
        "$value" == *example* ||
        "$value" == *localhost* ||
        "$value" == *127.0.0.1* ||
        "$value" == *0.0.0.0* ||
        "$value" == "/download" ]]; then
    fail "$name must be a real production value"
  else
    pass "$name is not a placeholder"
  fi
}

url_path() {
  local value="$1"
  value="${value%%#*}"
  value="${value%%\?*}"
  printf '%s\n' "$value"
}

require_zip_url_env() {
  local name="$1"
  local value="${!name:-}"
  local path
  [[ -n "$value" ]] || return 0

  path="$(url_path "$value")"
  case "$path" in
    *.zip) pass "$name points to a zip artifact" ;;
    *) fail "$name must point to a .zip release artifact" ;;
  esac
}

url_basename() {
  local value="$1"
  value="$(url_path "$value")"
  printf '%s\n' "${value##*/}"
}

require_download_filename_env() {
  local name="$1"
  local expected="$2"
  local value="${!name:-}"
  local filename

  [[ -n "$value" ]] || return 0
  [[ -n "$expected" ]] || return 0

  filename="$(url_basename "$value")"
  if [[ "$filename" == "$expected" ]]; then
    pass "$name filename matches $expected"
  else
    fail "$name filename must be $expected"
  fi
}

validate_version_metadata() {
  local version="$1"
  local build="$2"

  if [[ "$version" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]]; then
    pass "CFBundleShortVersionString uses numeric major.minor.patch format"
  else
    fail "CFBundleShortVersionString must use numeric major.minor.patch format"
  fi

  if [[ "$build" =~ ^[0-9]+([.][0-9]+){0,2}$ ]]; then
    pass "CFBundleVersion uses numeric build format"
  else
    fail "CFBundleVersion must use numeric build format"
  fi
}

require_sparkle_public_key() {
  local value="${SPARKLE_PUBLIC_ED_KEY:-}"
  if [[ -z "$value" ]]; then
    fail "SPARKLE_PUBLIC_ED_KEY must be set to the production Sparkle EdDSA public key"
  elif [[ "$value" == "TEST_RELEASE_PUBLIC_KEY" ||
          "$value" == *CHANGE_ME* ||
          "$value" == *example* ||
          ! "$value" =~ ^[A-Za-z0-9+/=_-]{40,120}$ ]]; then
    fail "SPARKLE_PUBLIC_ED_KEY must look like a real Sparkle EdDSA public key"
  else
    pass "SPARKLE_PUBLIC_ED_KEY looks like a real Sparkle public key"
  fi
}

info "Checking local release commands"
for tool in xcodebuild xcrun codesign ditto plutil security spctl swift npm xmllint; do
  require_command "$tool"
done

info "Checking app metadata"
if plutil -lint "$APP_PLIST" >/dev/null; then
  pass "SoundDeckApp/Info.plist is valid"
else
  fail "SoundDeckApp/Info.plist is invalid"
fi

require_plist_value SUFeedURL "$EXPECTED_FEED_URL"
require_plist_value SUPublicEDKey "$EXPECTED_PUBLIC_KEY_SETTING"
APP_VERSION="$(plist_value CFBundleShortVersionString)"
APP_BUILD="$(plist_value CFBundleVersion)"
validate_version_metadata "$APP_VERSION" "$APP_BUILD"
EXPECTED_ARCHIVE_NAME=""
if [[ "$APP_VERSION" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ && "$APP_BUILD" =~ ^[0-9]+([.][0-9]+){0,2}$ ]]; then
  EXPECTED_ARCHIVE_NAME="SoundDeck-${APP_VERSION}-${APP_BUILD}.zip"
  pass "release archive filename is $EXPECTED_ARCHIVE_NAME"
else
  fail "release archive filename cannot be derived from invalid version metadata"
fi

info "Checking required production environment"
require_https_env NEXT_PUBLIC_SITE_URL
require_https_env NEXT_PUBLIC_DOWNLOAD_URL
require_https_env NEXT_PUBLIC_CHECKOUT_URL
require_not_placeholder NEXT_PUBLIC_SITE_URL
require_not_placeholder NEXT_PUBLIC_DOWNLOAD_URL
require_not_placeholder NEXT_PUBLIC_CHECKOUT_URL
require_zip_url_env NEXT_PUBLIC_DOWNLOAD_URL
require_download_filename_env NEXT_PUBLIC_DOWNLOAD_URL "$EXPECTED_ARCHIVE_NAME"
require_env DEVELOPER_ID_APPLICATION
require_env DEVELOPMENT_TEAM
require_sparkle_public_key

if [[ -n "${DEVELOPER_ID_APPLICATION:-}" ]]; then
  if security find-identity -v -p codesigning | grep -F "$DEVELOPER_ID_APPLICATION" >/dev/null; then
    pass "Developer ID signing identity is installed"
  else
    fail "Developer ID signing identity is not installed in a keychain"
  fi
fi

if [[ -n "${NOTARY_PROFILE:-}" || ( -n "${APPLE_ID:-}" && -n "${APPLE_TEAM_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" ) ]]; then
  pass "notarization credentials are configured"
else
  fail "set NOTARY_PROFILE or APPLE_ID + APPLE_TEAM_ID + APPLE_APP_SPECIFIC_PASSWORD"
fi

if [[ -n "${SPARKLE_SIGN_UPDATE:-}" && -x "${SPARKLE_SIGN_UPDATE:-}" ]]; then
  pass "Sparkle sign_update tool is executable"
else
  fail "set SPARKLE_SIGN_UPDATE to Sparkle's executable sign_update tool"
fi

info "Checking landing package"
if [[ -f "$LANDING_DIR/package.json" && -f "$LANDING_DIR/package-lock.json" ]]; then
  pass "landing package files exist"
else
  fail "landing package files are missing"
fi

if [[ "$failures" -gt 0 ]]; then
  printf '\nRelease prerequisites failed with %d missing item(s).\n' "$failures" >&2
  exit 1
fi

printf '\nRelease prerequisites passed.\n'
