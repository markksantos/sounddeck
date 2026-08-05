#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="SoundDeck.app"

fail() {
  printf '[release] %s\n' "$1" >&2
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
ARCHIVE_PATH="$(absolute_path "${ARCHIVE_PATH:-$DIST_DIR/SoundDeck.xcarchive}")"
EXPORT_DIR="$(absolute_path "${EXPORT_DIR:-$DIST_DIR/export}")"

assert_safe_release_path() {
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

validate_release_metadata() {
  local version="$1"
  local build="$2"

  [[ "$version" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]] \
    || fail "CFBundleShortVersionString must use numeric major.minor.patch format"
  [[ "$build" =~ ^[0-9]+([.][0-9]+){0,2}$ ]] \
    || fail "CFBundleVersion must use numeric build format"
}

[[ "$DIST_DIR" != "/" ]] || fail "DIST_DIR must not be the filesystem root"
[[ "$DIST_DIR" != "$HOME" ]] || fail "DIST_DIR must not be the user home directory"
[[ "$DIST_DIR" != "$ROOT_DIR" ]] || fail "DIST_DIR must not be the repository root"
[[ "$DIST_DIR" != *"/../"* && "$DIST_DIR" != *"/.." ]] || fail "DIST_DIR must not contain parent-directory references"
assert_safe_release_path "ARCHIVE_PATH" "$ARCHIVE_PATH"
assert_safe_release_path "EXPORT_DIR" "$EXPORT_DIR"

"$ROOT_DIR/scripts/verify_release_prereqs.sh"

mkdir -p "$DIST_DIR"
rm -rf -- "$ARCHIVE_PATH" "$EXPORT_DIR"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/SoundDeckApp/Info.plist")"
BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$ROOT_DIR/SoundDeckApp/Info.plist")"
validate_release_metadata "$VERSION" "$BUILD"
ZIP_PATH="$DIST_DIR/SoundDeck-${VERSION}-${BUILD}.zip"

printf '[release] Archiving SoundDeck %s (%s)\n' "$VERSION" "$BUILD"
xcodebuild \
  -project "$ROOT_DIR/SoundDeck.xcodeproj" \
  -scheme SoundDeck \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -clonedSourcePackagesDirPath "$DIST_DIR/SourcePackages" \
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$DEVELOPER_ID_APPLICATION" \
  SPARKLE_PUBLIC_ED_KEY="$SPARKLE_PUBLIC_ED_KEY" \
  archive

APP_PATH="$ARCHIVE_PATH/Products/Applications/$APP_NAME"
if [[ ! -d "$APP_PATH" ]]; then
  fail "Expected app not found at $APP_PATH"
fi

ACTUAL_SPARKLE_KEY="$(/usr/libexec/PlistBuddy -c 'Print :SUPublicEDKey' "$APP_PATH/Contents/Info.plist")"
if [[ "$ACTUAL_SPARKLE_KEY" != "$SPARKLE_PUBLIC_ED_KEY" ]]; then
  fail "Built app SUPublicEDKey does not match SPARKLE_PUBLIC_ED_KEY"
fi

printf '[release] Verifying code signature\n'
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

printf '[release] Creating notarization archive %s\n' "$ZIP_PATH"
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

printf '[release] Submitting notarization\n'
if [[ -n "${NOTARY_PROFILE:-}" ]]; then
  xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
else
  xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID" \
    --password "$APPLE_APP_SPECIFIC_PASSWORD" \
    --wait
fi

printf '[release] Stapling notarization ticket\n'
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"
spctl --assess --type execute --verbose "$APP_PATH"

printf '[release] Repacking stapled app\n'
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

printf '[release] Release artifact ready: %s\n' "$ZIP_PATH"
printf '[release] Set NEXT_PUBLIC_DOWNLOAD_URL to the public URL for this artifact before deploying the landing site.\n'
