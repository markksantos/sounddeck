#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DERIVED_DATA="${APP_DERIVED_DATA:-/tmp/sounddeck-xcodebuild}"
KEY_DERIVED_DATA="${KEY_DERIVED_DATA:-/tmp/sounddeck-xcodebuild-sparkle-key}"
INSTALLER_DERIVED_DATA="${INSTALLER_DERIVED_DATA:-/tmp/sounddeck-installer-build}"
SPM_SCRATCH="${SPM_SCRATCH:-/tmp/sounddeck-swiftpm-build}"
TEST_SPARKLE_KEY="${TEST_SPARKLE_KEY:-TEST_RELEASE_PUBLIC_KEY}"

info() {
  printf '[app-verify] %s\n' "$1"
}

fail() {
  printf '[app-verify] %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing command: $1"
}

assert_file() {
  [[ -f "$1" ]] || fail "Missing file: $1"
}

assert_dir() {
  [[ -d "$1" ]] || fail "Missing directory: $1"
}

assert_plist_value() {
  local plist="$1"
  local key="$2"
  local expected="$3"
  local actual
  actual="$(/usr/libexec/PlistBuddy -c "Print :${key}" "$plist" 2>/dev/null || true)"
  [[ "$actual" == "$expected" ]] || fail "Expected ${key}=${expected}, got ${actual:-<missing>}"
}

for tool in swift xcodebuild plutil find wc rg; do
  require_command "$tool"
done

cd "$ROOT_DIR"

info "Checking app plist"
plutil -lint SoundDeckApp/Info.plist >/dev/null

info "Checking release scripts"
bash -n \
  scripts/verify_release_prereqs.sh \
  scripts/build_release.sh \
  scripts/generate_appcast.sh \
  scripts/generate_default_sounds.sh \
  scripts/smoke_test_driver.sh \
  scripts/verify_landing.sh \
  scripts/verify_repo_hygiene.sh
rg -q "require_not_placeholder NEXT_PUBLIC_SITE_URL" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must reject placeholder site URLs"
rg -q "is_https_url_with_host" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must require production URLs to include a host"
rg -q "non-empty host" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite URL diagnostics must explain missing hosts"
rg -q "spctl" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must require spctl for Gatekeeper assessment"
rg -q "require_command" scripts/smoke_test_driver.sh \
  || fail "Driver smoke test must preflight required commands"
rg -q "verify_install_path_present" scripts/smoke_test_driver.sh \
  || fail "Driver smoke test must use explicit install-path diagnostics"
rg -q "Driver bundle is not installed at" scripts/smoke_test_driver.sh \
  || fail "Driver smoke test must explain missing install-path failures"
rg -q "EXPECTED_FEED_URL=\"https://updates.sounddeck.app/appcast.xml\"" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must validate the production Sparkle feed URL"
rg -q "EXPECTED_PUBLIC_KEY_SETTING='\\$\\(SPARKLE_PUBLIC_ED_KEY\\)'" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must validate the Sparkle public key build setting"
rg -q "require_plist_value SUFeedURL" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must validate source SUFeedURL"
rg -q "require_plist_value SUPublicEDKey" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must validate source SUPublicEDKey"
rg -q "require_sparkle_public_key" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must validate the Sparkle public key"
rg -q "TEST_RELEASE_PUBLIC_KEY" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must reject test Sparkle public keys"
rg -q "require_zip_url_env NEXT_PUBLIC_DOWNLOAD_URL" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must require download URLs to point to zip artifacts"
rg -q "require_download_filename_env NEXT_PUBLIC_DOWNLOAD_URL" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must require download URLs to match the release archive filename"
rg -q "url_basename" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must parse signed download URL filenames safely"
rg -q "url_path" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must strip query strings and fragments before zip URL validation"
rg -q 'path="\$\(url_path "\$value"\)"' scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite zip URL validation must use normalized URL paths"
rg -q "validate_version_metadata" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must validate source version/build metadata"
rg -q "numeric major\\.minor\\.patch format" scripts/verify_release_prereqs.sh \
  || fail "Release prerequisite checks must require numeric app short versions"
rg -q "assert_safe_release_path" scripts/build_release.sh \
  || fail "Release build script must validate cleanup paths before deleting output"
rg -q "validate_release_metadata" scripts/build_release.sh \
  || fail "Release build script must validate version/build metadata before deriving artifact paths"
rg -q "must not contain parent-directory references" scripts/build_release.sh \
  || fail "Release build script must reject parent-directory cleanup paths"
if rg -n 'rm -rf "\$ARCHIVE_PATH" "\$EXPORT_DIR"' scripts/build_release.sh; then
  fail "Release build script must use guarded cleanup with option terminator"
fi
rg -q "assert_safe_appcast_path" scripts/generate_appcast.sh \
  || fail "Appcast script must validate output paths before writing XML"
rg -q "require_production_https_url" scripts/generate_appcast.sh \
  || fail "Appcast script must reject local or placeholder download URLs"
rg -q "is_https_url_with_host" scripts/generate_appcast.sh \
  || fail "Appcast script must require production URLs to include a host"
rg -q "non-empty host" scripts/generate_appcast.sh \
  || fail "Appcast URL diagnostics must explain missing hosts"
rg -q "require_zip_artifact_url" scripts/generate_appcast.sh \
  || fail "Appcast script must validate download URLs as zip artifacts separately from general production URLs"
rg -q "validate_release_metadata" scripts/generate_appcast.sh \
  || fail "Appcast script must validate version/build metadata before deriving appcast artifact names"
rg -q "require_production_https_url \"RELEASE_NOTES_URL\"" scripts/generate_appcast.sh \
  || fail "Appcast script must reject local or placeholder release notes URLs"
rg -q "must point to a \\.zip release artifact" scripts/generate_appcast.sh \
  || fail "Appcast script must require download URLs to point to zip artifacts"
rg -q "EXPECTED_ARCHIVE_NAME=\"SoundDeck-\\$\\{VERSION\\}-\\$\\{BUILD\\}\\.zip\"" scripts/generate_appcast.sh \
  || fail "Appcast script must derive the expected archive filename from version and build"
rg -q "ARCHIVE_ZIP filename must be" scripts/generate_appcast.sh \
  || fail "Appcast script must reject archive filenames that do not match version/build metadata"
rg -q "DOWNLOAD_URL filename must be" scripts/generate_appcast.sh \
  || fail "Appcast script must reject public download URLs that do not match version/build metadata"
rg -q "url_path" scripts/generate_appcast.sh \
  || fail "Appcast script must strip query strings and fragments before zip URL validation"
rg -q 'path="\$\(url_path "\$value"\)"' scripts/generate_appcast.sh \
  || fail "Appcast zip URL validation must use normalized URL paths"
rg -q "must stay inside DIST_DIR" scripts/generate_appcast.sh \
  || fail "Appcast script must keep output inside DIST_DIR"
rg -q "RELEASE_NOTES_URL" RELEASE.md \
  || fail "Release docs must document RELEASE_NOTES_URL"
rg -q "production HTTPS URL" RELEASE.md \
  || fail "Release docs must document RELEASE_NOTES_URL production URL requirements"
rg -q "SoundDeck-\\{CFBundleShortVersionString\\}-\\{CFBundleVersion\\}\\.zip" RELEASE.md \
  || fail "Release docs must document the appcast archive filename contract"
DOC_APP_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' SoundDeckApp/Info.plist)"
DOC_APP_BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' SoundDeckApp/Info.plist)"
EXPECTED_DOC_ARCHIVE_NAME="SoundDeck-${DOC_APP_VERSION}-${DOC_APP_BUILD}.zip"
for doc in README.md landing/README.md landing/.env.example RELEASE.md; do
  rg -Fq "$EXPECTED_DOC_ARCHIVE_NAME" "$doc" \
    || fail "$doc must document the current release archive filename $EXPECTED_DOC_ARCHIVE_NAME"
done
if rg -n "SoundDeck\\.zip" README.md landing/README.md landing/.env.example RELEASE.md; then
  fail "Release environment examples must use version/build-specific archive filenames"
fi
rg -Fq 'assert_plist_value "$APP_PLIST" "CFBundleShortVersionString" "$DOC_APP_VERSION"' scripts/verify_app.sh \
  || fail "App verifier must compare built app version against the source plist version"
rg -Fq 'assert_plist_value "$APP_PLIST" "CFBundleVersion" "$DOC_APP_BUILD"' scripts/verify_app.sh \
  || fail "App verifier must compare built app build against the source plist build"
if rg -n 'assert_plist_value "\$APP_PLIST" "CFBundleShortVersionString" "1\.0\.0"' scripts/verify_app.sh; then
  fail "App verifier must not hardcode the app short version"
fi

info "Checking CI workflow paths"
assert_file ".github/workflows/ci.yml"
if rg -n "defaults:" .github/workflows/ci.yml; then
  fail "CI workflow must not set a job-level landing working directory that breaks root script paths"
fi
rg -q "run: scripts/verify_repo_hygiene\\.sh" .github/workflows/ci.yml \
  || fail "CI workflow must run repo hygiene from the repository root"
rg -q "working-directory: landing" .github/workflows/ci.yml \
  || fail "CI workflow must scope npm commands to the landing directory"
rg -q "run: npm run verify" .github/workflows/ci.yml \
  || fail "CI workflow must run the landing verification script"
rg -q "apt-get install -y ripgrep" .github/workflows/ci.yml \
  || fail "CI workflow must install ripgrep before Linux verifier scripts run"
rg -q "brew install ripgrep" .github/workflows/ci.yml \
  || fail "CI workflow must install ripgrep before macOS verifier scripts run"

info "Checking repo hygiene"
scripts/verify_repo_hygiene.sh

info "Checking per-sound hotkey runtime registration"
if rg -n "guard sound\\.hotkeyName != nil|if sound\\.hotkeyName != nil|Text\\(sound\\.hotkeyName" \
  SoundDeckApp/Hotkeys/HotkeyManager.swift \
  SoundDeckApp/Views/SoundPadView.swift; then
  fail "Per-sound hotkeys must use KeyboardShortcuts storage as the source of truth"
fi
rg -q "registeredSoundHotkeyNames" SoundDeckApp/Hotkeys/HotkeyManager.swift \
  || fail "HotkeyManager must track registered per-sound handlers for de-duplication"
rg -q "KeyboardShortcuts\\.getShortcut\\(for: \\.forSound" SoundDeckApp/Views/SoundPadView.swift \
  || fail "SoundPadView must display the actual assigned KeyboardShortcuts shortcut"
rg -q "KeyboardShortcuts\\.setShortcut\\(nil, for: hotkeyName\\)" SoundDeckApp/Models/SoundStore.swift \
  || fail "Deleting a sound must clear its persisted KeyboardShortcuts assignment"
rg -q "title: \"Mute microphone\"" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must expose the global mute hotkey recorder"
rg -q "name: \\.globalMute" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings global mute recorder must use the registered globalMute name"
rg -q "title: \"Stop all sounds\"" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must expose the Stop All hotkey recorder"
rg -q "name: \\.stopAll" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings Stop All recorder must use the registered stopAll name"
rg -q "title: \"Toggle voice changer\"" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must expose the voice changer hotkey row"
rg -q "name: \\.toggleVoiceChanger" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings voice changer recorder must use the registered toggleVoiceChanger name"
rg -q "if appState\\.canUseVoiceChanger" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings voice changer recorder must respect the Pro gate"
rg -q "lockedHotkeyRow\\(title: \"Toggle voice changer\"" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must show a locked Pro row for the voice changer hotkey"
rg -q "Text\\(\"Sound Pads\"\\)" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must separate per-sound hotkeys from global hotkeys"
rg -q "Add sounds to configure per-sound hotkeys" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings empty-state copy must describe per-sound hotkeys"

info "Checking import limit and folder assignment flow"
rg -q "func importSound\\(url: URL, preferredName: String\\? = nil, folderID: UUID\\? = nil\\)" SoundDeckApp/Models/SoundStore.swift \
  || fail "SoundStore.importSound must accept folderID for atomic folder assignment"
rg -q "Thread\\.isMainThread" SoundDeckApp/Models/SoundStore.swift \
  || fail "SoundStore.importSound must append synchronously when already on the main thread"
if rg -n "appState\\.sounds\\[index\\]\\.folderID|DispatchQueue\\.main\\.async \\{[[:space:]]*if let index = self\\?\\.appState\\.sounds\\.firstIndex" SoundDeckApp/App/AppDelegate.swift; then
  fail "AppDelegate import callers must not mutate folderID after import"
fi
rg -q "audioActions\\.importSound\\(url, appState\\.selectedFolderID\\)" SoundDeckApp/Views/SoundGridView.swift \
  || fail "Drag-and-drop import must use selectedFolderID"
rg -q "audioActions\\.pickAndImportSounds\\(appState\\.selectedFolderID\\)" SoundDeckApp/Views/SoundGridView.swift \
  || fail "Add Sound must import into the selected folder"
rg -q "Move to Folder" SoundDeckApp/Views/SoundPadView.swift \
  || fail "Sound pad context menu must let users move existing sounds between folders"
rg -q "moveToFolder\\(nil\\)" SoundDeckApp/Views/SoundPadView.swift \
  || fail "Sound pad folder move menu must support moving sounds back to All Sounds"
rg -q "appState\\.sounds\\[index\\]\\.folderID = folderID" SoundDeckApp/Views/SoundPadView.swift \
  || fail "Sound pad folder move must update folderID through app state"

info "Checking duplicate sound variants"
rg -q "var duplicateSound: \\(SoundItem\\) -> Void" SoundDeckApp/App/AudioActions.swift \
  || fail "AudioActions must expose a duplicate sound action"
rg -q "func duplicateSound\\(_ sound: SoundItem\\) -> SoundItem\\?" SoundDeckApp/Models/SoundStore.swift \
  || fail "SoundStore must implement duplicateSound"
rg -q "fileManager\\.copyItem\\(at: sourceURL, to: destURL\\)" SoundDeckApp/Models/SoundStore.swift \
  || fail "Duplicate sound must copy the stored audio file"
rg -q "name: duplicateName" SoundDeckApp/Models/SoundStore.swift \
  || fail "Duplicate sound must assign a unique duplicate display name"
rg -q "hotkeyName: nil" SoundDeckApp/Models/SoundStore.swift \
  || fail "Duplicate sound must not copy hotkey assignment metadata"
rg -q "folderID: sound\\.folderID" SoundDeckApp/Models/SoundStore.swift \
  || fail "Duplicate sound must stay in the source sound folder"
rg -q "trimStart: sound\\.trimStart" SoundDeckApp/Models/SoundStore.swift \
  || fail "Duplicate sound must preserve trim start"
rg -q "trimEnd: sound\\.trimEnd" SoundDeckApp/Models/SoundStore.swift \
  || fail "Duplicate sound must preserve trim end"
rg -q "volume: sound\\.volume" SoundDeckApp/Models/SoundStore.swift \
  || fail "Duplicate sound must preserve volume"
rg -q "uniqueDuplicateName" SoundDeckApp/Models/SoundStore.swift \
  || fail "Duplicate sound must avoid name collisions"
rg -q "guard let self = self, self\\.appState\\.canAddMoreSounds else \\{ return \\}" SoundDeckApp/App/AppDelegate.swift \
  || fail "Duplicate sound action must respect Free plan custom sound limits"
rg -q "self\\.soundStore\\.duplicateSound\\(sound\\)" SoundDeckApp/App/AppDelegate.swift \
  || fail "AppDelegate duplicate action must call SoundStore.duplicateSound"
rg -q "Duplicate Sound" SoundDeckApp/Views/SoundPadView.swift \
  || fail "Sound pad context menu must expose Duplicate Sound"
rg -q "audioActions\\.duplicateSound\\(sound\\)" SoundDeckApp/Views/SoundPadView.swift \
  || fail "SoundPadView must call duplicate sound action"
rg -q "Duplicating creates another custom sound" SoundDeckApp/Views/SoundPadView.swift \
  || fail "Duplicate limit alert must explain that duplicates count as custom sounds"
rg -q "showUpgradeLimitAlert = true" SoundDeckApp/Views/SoundPadView.swift \
  || fail "Duplicate sound must show the upgrade limit alert when Free custom slots are full"

info "Checking free-plan custom slot accounting"
rg -q "bundledDefaultSoundFileNames" SoundDeckApp/App/AppState.swift \
  || fail "AppState must identify bundled default sounds for free-plan slot accounting"
rg -q "customSoundCount < maxFreeSounds" SoundDeckApp/App/AppState.swift \
  || fail "Free-plan import capacity must be based on custom sound count"
if rg -n "sounds\\.count < maxFreeSounds" SoundDeckApp/App/AppState.swift; then
  fail "Free-plan import capacity must not count bundled default sounds"
fi
rg -q "limited to .*custom sounds" SoundDeckApp/Views/SoundGridView.swift \
  || fail "Sound limit copy must describe custom sound slots"

info "Checking Free and Pro plan gates"
rg -Fq "var canUseVoiceChanger: Bool { isPro }" SoundDeckApp/App/AppState.swift \
  || fail "Voice changer must be gated by Pro"
rg -Fq "var canUsePerSoundHotkeys: Bool { isPro }" SoundDeckApp/App/AppState.swift \
  || fail "Per-sound hotkeys must be gated by Pro"
rg -Fq "var canUseTrimEditor: Bool { isPro }" SoundDeckApp/App/AppState.swift \
  || fail "Trim editor must be gated by Pro"
rg -Fq "var canAccessProLibrary: Bool { isPro }" SoundDeckApp/App/AppState.swift \
  || fail "Pro Library must be gated by Pro"
rg -Fq "var showWatermark: Bool { !isPro }" SoundDeckApp/App/AppState.swift \
  || fail "Free plan watermark must stop when Pro is active"
rg -q 'appState\.\$isPro' SoundDeckApp/Licensing/WatermarkPlayer.swift \
  || fail "WatermarkPlayer must observe Pro state changes"
rg -q "handleStateChange\\(isPro: appState\\.isPro\\)" SoundDeckApp/Licensing/WatermarkPlayer.swift \
  || fail "WatermarkPlayer must evaluate the initial Pro state"
rg -q "Watermark beep" SoundDeckApp/Views/UpgradeView.swift \
  || fail "Upgrade comparison must explain the Free plan watermark"
rg -q "FeatureRow\\(name: \"Custom imports\", freeValue: \\.text\\(\"8 max\"\\), proValue: \\.text\\(\"Unlimited\"\\)\\)" SoundDeckApp/Views/UpgradeView.swift \
  || fail "Upgrade comparison must explain Free custom import limits"
rg -q "Restore Purchases" SoundDeckApp/Views/UpgradeView.swift \
  || fail "UpgradeView must expose restore purchases"
rg -q "Restore Purchases" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must expose restore purchases"
rg -q "Free Plan" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must show Free Plan state"
rg -q "SoundDeck Pro Active" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must show Pro active state"
rg -q "Manage Subscription" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must expose subscription management"
rg -q "https://apps\\.apple\\.com/account/subscriptions" SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings must link to Apple subscription management"
rg -q "AppStore\\.sync\\(\\)" SoundDeckApp/Subscription/SubscriptionManager.swift \
  || fail "Restore purchases must sync StoreKit"
rg -q "Purchases restored\\. SoundDeck Pro is active\\." SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings restore status must confirm active Pro access"
rg -q "No active SoundDeck Pro subscription was found\\." SoundDeckApp/Views/SettingsView.swift \
  || fail "Settings restore status must explain missing Pro access"

info "Checking Pro library runtime entitlement guards"
rg -q "if !appState\\.canAccessProLibrary" SoundDeckApp/Views/ProLibraryView.swift \
  || fail "ProLibraryView must show a locked state when Pro access is unavailable"
rg -q "guard appState\\.canAccessProLibrary else" SoundDeckApp/Views/ProLibraryView.swift \
  || fail "ProLibraryView must guard runtime actions with Pro access"
rg -q "cancelActiveWork\\(\\)" SoundDeckApp/Views/ProLibraryView.swift \
  || fail "ProLibraryView must cancel preview/search work when Pro access is lost"

info "Checking support diagnostics copy flow"
rg -q "Copy Diagnostics" SoundDeckApp/Views/SupportView.swift \
  || fail "SupportView must expose a copy diagnostics action"
rg -q "NSPasteboard\\.general" SoundDeckApp/Views/SupportView.swift \
  || fail "SupportView must copy diagnostics to the macOS pasteboard"
rg -q "private var supportDiagnostics" SoundDeckApp/Views/SupportView.swift \
  || fail "SupportView must build a support diagnostics payload"
rg -q "Microphone Permission" SoundDeckApp/Views/SupportView.swift \
  || fail "Support diagnostics must include microphone permission state"
rg -q "appState\\.customSoundCount" SoundDeckApp/Views/SupportView.swift \
  || fail "Support diagnostics must include custom sound count"
rg -q "appState\\.selectedInputDeviceID" SoundDeckApp/Views/SupportView.swift \
  || fail "Support diagnostics must include selected input device ID"
rg -q "diagnosticsStatusMessage" SoundDeckApp/Views/SupportView.swift \
  || fail "SupportView must show copy diagnostics feedback"
rg -q "private var supportEmailURL: URL\\?" SoundDeckApp/Views/SupportView.swift \
  || fail "SupportView must build a support email URL"
rg -q "URLComponents\\(\\)" SoundDeckApp/Views/SupportView.swift \
  || fail "SupportView support email must use URLComponents"
rg -q "URLQueryItem\\(name: \"subject\", value: \"SoundDeck Support - v\\\\\\(appVersion\\)\"\\)" SoundDeckApp/Views/SupportView.swift \
  || fail "Support email must include an app-version subject"
rg -q "name: \"body\"" SoundDeckApp/Views/SupportView.swift \
  || fail "Support email must include a body query item"
rg -q "\\\\\\(supportDiagnostics\\)" SoundDeckApp/Views/SupportView.swift \
  || fail "Support email body must include support diagnostics"
if rg -n 'URL\\(string: "mailto:support@sounddeck.app"\\)' SoundDeckApp/Views/SupportView.swift; then
  fail "Support email action must not use a bare mailto URL"
fi

info "Checking bundled default sound source assets"
source_wav_count="$(find Resources/DefaultSounds -maxdepth 1 -type f -name '*.wav' | wc -l | tr -d ' ')"
[[ "$source_wav_count" == "14" ]] || fail "Expected 14 source default sounds, found ${source_wav_count}"

info "Running SwiftPM tests"
swift test --scratch-path "$SPM_SCRATCH"

info "Building unsigned SoundDeck app"
xcodebuild \
  -quiet \
  -project SoundDeck.xcodeproj \
  -scheme SoundDeck \
  -configuration Debug \
  -derivedDataPath "$APP_DERIVED_DATA" \
  -clonedSourcePackagesDirPath /tmp/sounddeck-xcodebuild-packages \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="$APP_DERIVED_DATA/Build/Products/Debug/SoundDeck.app"
APP_PLIST="$APP_PATH/Contents/Info.plist"
assert_dir "$APP_PATH"
assert_file "$APP_PLIST"
assert_file "$APP_PATH/Contents/Resources/AppIcon.icns"
assert_plist_value "$APP_PLIST" "CFBundleIconFile" "AppIcon"
assert_plist_value "$APP_PLIST" "CFBundleShortVersionString" "$DOC_APP_VERSION"
assert_plist_value "$APP_PLIST" "CFBundleVersion" "$DOC_APP_BUILD"
assert_plist_value "$APP_PLIST" "SUFeedURL" "https://updates.sounddeck.app/appcast.xml"
assert_plist_value "$APP_PLIST" "SUPublicEDKey" ""

DRIVER_BUNDLE="$APP_PATH/Contents/Resources/SoundDeckDriver.driver"
DRIVER_PLIST="$DRIVER_BUNDLE/Contents/Info.plist"
DRIVER_EXECUTABLE="$DRIVER_BUNDLE/Contents/MacOS/SoundDeckDriver"
assert_dir "$DRIVER_BUNDLE"
assert_file "$DRIVER_PLIST"
assert_file "$DRIVER_EXECUTABLE"
[[ -x "$DRIVER_EXECUTABLE" ]] || fail "Embedded driver executable is not executable: $DRIVER_EXECUTABLE"
plutil -lint "$DRIVER_PLIST" >/dev/null
assert_plist_value "$DRIVER_PLIST" "CFBundleIdentifier" "com.sounddeck.driver"
assert_plist_value "$DRIVER_PLIST" "CFBundlePackageType" "BNDL"

bundle_wav_count="$(find "$APP_PATH/Contents/Resources" -maxdepth 2 -type f -name '*.wav' | wc -l | tr -d ' ')"
[[ "$bundle_wav_count" == "14" ]] || fail "Expected 14 bundled WAV files, found ${bundle_wav_count}"

info "Building unsigned SoundDeck app with Sparkle public key override"
xcodebuild \
  -quiet \
  -project SoundDeck.xcodeproj \
  -scheme SoundDeck \
  -configuration Debug \
  -derivedDataPath "$KEY_DERIVED_DATA" \
  -clonedSourcePackagesDirPath /tmp/sounddeck-xcodebuild-packages \
  CODE_SIGNING_ALLOWED=NO \
  SPARKLE_PUBLIC_ED_KEY="$TEST_SPARKLE_KEY" \
  build

KEY_APP_PLIST="$KEY_DERIVED_DATA/Build/Products/Debug/SoundDeck.app/Contents/Info.plist"
assert_file "$KEY_APP_PLIST"
assert_plist_value "$KEY_APP_PLIST" "SUPublicEDKey" "$TEST_SPARKLE_KEY"

info "Building unsigned SoundDeckInstaller"
xcodebuild \
  -quiet \
  -project SoundDeck.xcodeproj \
  -scheme SoundDeckInstaller \
  -configuration Debug \
  -derivedDataPath "$INSTALLER_DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build

INSTALLER_BIN="$INSTALLER_DERIVED_DATA/Build/Products/Debug/SoundDeckInstaller"
assert_file "$INSTALLER_BIN"
[[ -x "$INSTALLER_BIN" ]] || fail "Installer exists but is not executable: $INSTALLER_BIN"
"$INSTALLER_BIN" --help | grep -F "status" >/dev/null || fail "Installer help output does not mention status"
"$INSTALLER_BIN" status | grep -F "Installed:" >/dev/null || fail "Installer status output missing installation state"

printf '\nmacOS app verification passed.\n'
