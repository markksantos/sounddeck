#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_ZIP="${ARCHIVE_ZIP:-}"
DOWNLOAD_URL="${DOWNLOAD_URL:-${NEXT_PUBLIC_DOWNLOAD_URL:-}}"
RELEASE_NOTES_URL="${RELEASE_NOTES_URL:-https://sounddeck.app/changelog}"
PUB_DATE="${PUB_DATE:-$(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S %z')}"

fail() {
  printf '[appcast] %s\n' "$1" >&2
  exit 1
}

absolute_path() {
  local path="$1"
  if [[ "$path" == /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

DIST_DIR="$(absolute_path "${DIST_DIR:-$ROOT_DIR/dist}")"
APPCAST_PATH="$(absolute_path "${APPCAST_PATH:-$DIST_DIR/appcast.xml}")"

assert_safe_appcast_path() {
  local label="$1"
  local path="$2"

  [[ -n "$path" ]] || fail "$label must not be empty"
  [[ "$path" == /* ]] || fail "$label must be absolute"
  [[ "$path" != *"/../"* && "$path" != *"/.." ]] || fail "$label must not contain parent-directory references"
  [[ "$path" != "/" ]] || fail "$label must not be the filesystem root"
  [[ "$path" != "$HOME" ]] || fail "$label must not be the user home directory"
  [[ "$path" != "$ROOT_DIR" ]] || fail "$label must not be the repository root"
  [[ "$path" != "$DIST_DIR" ]] || fail "$label must not be the dist directory itself"

  case "$path" in
    "$DIST_DIR"/*) ;;
    *) fail "$label must stay inside DIST_DIR ($DIST_DIR)" ;;
  esac
}

is_https_url_with_host() {
  local value="$1"
  [[ "$value" =~ ^https://[^/?#[:space:]]+($|[/?#]) ]]
}

require_production_https_url() {
  local label="$1"
  local value="$2"

  is_https_url_with_host "$value" || fail "Set $label to a public https URL with a non-empty host"
  if [[ "$value" == *CHANGE_ME* ||
        "$value" == *example* ||
        "$value" == *localhost* ||
        "$value" == *127.0.0.1* ||
        "$value" == *0.0.0.0* ]]; then
    fail "$label must be a real production URL"
  fi
}

require_zip_artifact_url() {
  local label="$1"
  local value="$2"
  local path

  require_production_https_url "$label" "$value"

  path="$(url_path "$value")"
  case "$path" in
    *.zip) ;;
    *) fail "$label must point to a .zip release artifact" ;;
  esac
}

url_path() {
  local value="$1"
  value="${value%%#*}"
  value="${value%%\?*}"
  printf '%s\n' "$value"
}

url_basename() {
  local value="$1"
  value="$(url_path "$value")"
  printf '%s\n' "${value##*/}"
}

validate_release_metadata() {
  local version="$1"
  local build="$2"

  [[ "$version" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]] \
    || fail "VERSION must use numeric major.minor.patch format"
  [[ "$build" =~ ^[0-9]+([.][0-9]+){0,2}$ ]] \
    || fail "BUILD must use numeric build format"
}

xml_escape() {
  local value="$1"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  value="${value//\"/&quot;}"
  value="${value//\'/&apos;}"
  printf '%s' "$value"
}

[[ "$DIST_DIR" != "/" ]] || fail "DIST_DIR must not be the filesystem root"
[[ "$DIST_DIR" != "$HOME" ]] || fail "DIST_DIR must not be the user home directory"
[[ "$DIST_DIR" != "$ROOT_DIR" ]] || fail "DIST_DIR must not be the repository root"
[[ "$DIST_DIR" != *"/../"* && "$DIST_DIR" != *"/.." ]] || fail "DIST_DIR must not contain parent-directory references"
assert_safe_appcast_path "APPCAST_PATH" "$APPCAST_PATH"

if [[ -z "$ARCHIVE_ZIP" || ! -f "$ARCHIVE_ZIP" ]]; then
  fail "Set ARCHIVE_ZIP to the signed, notarized SoundDeck zip"
fi

require_zip_artifact_url "DOWNLOAD_URL or NEXT_PUBLIC_DOWNLOAD_URL" "$DOWNLOAD_URL"
require_production_https_url "RELEASE_NOTES_URL" "$RELEASE_NOTES_URL"

if [[ -z "${SPARKLE_SIGN_UPDATE:-}" || ! -x "$SPARKLE_SIGN_UPDATE" ]]; then
  fail "Set SPARKLE_SIGN_UPDATE to Sparkle's executable sign_update tool"
fi

VERSION="${VERSION:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/SoundDeckApp/Info.plist")}"
BUILD="${BUILD:-$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$ROOT_DIR/SoundDeckApp/Info.plist")}"
validate_release_metadata "$VERSION" "$BUILD"
EXPECTED_ARCHIVE_NAME="SoundDeck-${VERSION}-${BUILD}.zip"
ARCHIVE_BASENAME="$(basename "$ARCHIVE_ZIP")"

if [[ "$ARCHIVE_BASENAME" != "$EXPECTED_ARCHIVE_NAME" ]]; then
  fail "ARCHIVE_ZIP filename must be $EXPECTED_ARCHIVE_NAME"
fi

DOWNLOAD_BASENAME="$(url_basename "$DOWNLOAD_URL")"
if [[ "$DOWNLOAD_BASENAME" != "$EXPECTED_ARCHIVE_NAME" ]]; then
  fail "DOWNLOAD_URL filename must be $EXPECTED_ARCHIVE_NAME"
fi

LENGTH="$(stat -f%z "$ARCHIVE_ZIP")"
SIGNATURE_OUTPUT="$("$SPARKLE_SIGN_UPDATE" "$ARCHIVE_ZIP")"
ED_SIGNATURE="$(printf '%s\n' "$SIGNATURE_OUTPUT" | sed -n 's/.*sparkle:edSignature="\([^"]*\)".*/\1/p')"

if [[ -z "$ED_SIGNATURE" ]]; then
  fail "Could not parse sparkle:edSignature from sign_update output: $SIGNATURE_OUTPUT"
fi

XML_VERSION="$(xml_escape "$VERSION")"
XML_BUILD="$(xml_escape "$BUILD")"
XML_DOWNLOAD_URL="$(xml_escape "$DOWNLOAD_URL")"
XML_RELEASE_NOTES_URL="$(xml_escape "$RELEASE_NOTES_URL")"
XML_PUB_DATE="$(xml_escape "$PUB_DATE")"
XML_ED_SIGNATURE="$(xml_escape "$ED_SIGNATURE")"

mkdir -p "$(dirname "$APPCAST_PATH")"
cat > "$APPCAST_PATH" <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0"
  xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"
  xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>SoundDeck Updates</title>
    <link>https://updates.sounddeck.app/appcast.xml</link>
    <description>Release updates for SoundDeck.</description>
    <language>en</language>
    <item>
      <title>SoundDeck ${XML_VERSION}</title>
      <sparkle:releaseNotesLink>${XML_RELEASE_NOTES_URL}</sparkle:releaseNotesLink>
      <pubDate>${XML_PUB_DATE}</pubDate>
      <enclosure
        url="${XML_DOWNLOAD_URL}"
        sparkle:version="${XML_BUILD}"
        sparkle:shortVersionString="${XML_VERSION}"
        length="${LENGTH}"
        type="application/octet-stream"
        sparkle:edSignature="${XML_ED_SIGNATURE}" />
    </item>
  </channel>
</rss>
XML

xmllint --noout "$APPCAST_PATH"
printf '[appcast] Wrote %s\n' "$APPCAST_PATH"
