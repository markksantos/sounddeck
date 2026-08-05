# SoundDeck Implementation Progress

## Phase 0: Shared Foundation
- [x] Xcode project structure (project.yml, Package.swift, targets)
- [x] SharedAudioConstants.h — device name, UID, SHM path, buffer sizes
- [x] SharedAudioBuffer.h — shared memory struct with atomic heads
- [x] RingBuffer.h/.c — lock-free SPSC ring buffer
- [x] SHMHelpers.h/.c — Swift-safe wrappers for shm_open and atomic fields
- [x] module.modulemap for Swift interop
- [x] Release-safe bundled default sounds (14 WAV files)
- [x] RingBuffer unit tests

## Workstream 1: Virtual Audio Driver
- [x] DriverEntry.cpp — AudioServerPlugin with full property handling (1741 lines)
- [x] SoundDeckInstaller/main.swift — driver install/uninstall CLI

## Workstream 2: Menu Bar UI
- [x] PopoverContentView — root layout
- [x] SoundGridView — LazyVGrid 4 columns
- [x] SoundPadView — tap/hold/context menu
- [x] VUMeterView — 20-segment level meter
- [x] VoiceChangerView — pitch slider + presets
- [x] FolderSidebarView — folder list + selection
- [x] TrimEditorView — waveform + drag handles
- [x] SettingsView — device picker, hotkeys, license
- [x] OnboardingView — first-run flow

## Workstream 3: Audio Engine + Data
- [x] SoundItem.swift + SoundFolder.swift models
- [x] SoundStore.swift — JSON persistence
- [x] SharedMemoryWriter.swift — shm_open + mmap + write
- [x] AudioEngineManager.swift — main engine graph
- [x] SoundPlayer.swift — 8-node player pool
- [x] PreviewEngine.swift — headphone-only preview
- [x] VoiceChanger.swift — AVAudioUnitTimePitch wrapper
- [x] HotkeyNames.swift + HotkeyManager.swift
- [x] TrialManager.swift — 7-day Keychain trial
- [x] LicenseManager.swift — LemonSqueezy integration
- [x] WatermarkPlayer.swift — anti-piracy beep

## Audio Monitoring & Waveform Visualization
- [x] Add isSFXMonitorEnabled, isVoiceMonitorEnabled, waveformLevels to AppState
- [x] Expose SoundPlayer.getBuffer(for:) for shared buffer access
- [x] Extend PreviewEngine with SFX player pool (4 nodes) + voice monitor node
- [x] Add voice monitor tap on pitchUnit output in AudioEngineManager
- [x] Extend metering tap to push RMS into waveformLevels (scrolling history)
- [x] Wire dual-play in AppDelegate AudioActions (play/stop/stopAll)
- [x] Wire dual-play in HotkeyManager (triggerSound/stopAll)
- [x] Create WaveformView (mirrored bars, green-cyan gradient)
- [x] Update PopoverContentView top bar: Waveform + SFX Monitor + Voice Monitor + Mute + Voice Changer
- [x] Build verification — BUILD SUCCEEDED

## Integration
- [x] Wire AppState to all managers
- [x] Cross-file import fixes (CoreAudio, SoundDeckCommon, Foundation)
- [x] C interop fixes (shm_open wrapper, atomic field accessors)
- [x] Build verification — ALL 4 targets compile successfully:
  - SoundDeck (app) — BUILD SUCCEEDED
  - SoundDeckCommon (static lib) — BUILD SUCCEEDED
  - SoundDeckDriver (bundle) — BUILD SUCCEEDED
  - SoundDeckInstaller (CLI) — BUILD SUCCEEDED

## 2026 Public Release Readiness Spec

Objective: turn SoundDeck into a public-launch-ready macOS app plus marketing site by covering product functionality, user trust, SEO/GEO discoverability, conversion, accessibility, release engineering, and verification.

Success criteria:
- The landing site has launch-grade metadata, crawl assets, structured data, public pages, clear CTAs, realistic product visuals, accessible interactions, and no placeholder content.
- The macOS app has low-risk release bugs fixed, visible polish improvements, reliable import/onboarding/update flows, and no obvious compile regressions.
- The repo documents the completed release work and has lint/build/test evidence.
- A final completion audit maps every explicit request and checklist item to actual files or command output.

## 100+ Improvement Inventory

### Landing SEO, GEO, And Crawlability
- [x] 001 Add metadataBase and canonical URLs.
- [x] 002 Add title template for secondary pages.
- [x] 003 Add launch-grade meta description.
- [x] 004 Add keyword coverage for macOS soundboard, virtual microphone, Discord, Zoom, Google Meet, OBS, voice changer, stream deck alternative, and audio routing.
- [x] 005 Add Open Graph title, description, URL, site name, product type, and image references.
- [x] 006 Add Twitter card metadata.
- [x] 007 Add app category metadata.
- [x] 008 Add alternates metadata.
- [x] 009 Add robots metadata for AI/search crawlers.
- [x] 010 Add Next sitemap route.
- [x] 011 Add Next robots route.
- [x] 012 Add llms.txt for AI answer engines.
- [x] 013 Add JSON-LD Organization schema.
- [x] 014 Add JSON-LD SoftwareApplication schema.
- [x] 015 Add JSON-LD WebSite schema.
- [x] 016 Add JSON-LD FAQPage schema.
- [x] 017 Add JSON-LD BreadcrumbList schema where useful.
- [x] 018 Add GEO-friendly answer blocks for what SoundDeck is.
- [x] 019 Add GEO-friendly compatibility answer blocks.
- [x] 020 Add GEO-friendly pricing answer blocks.
- [x] 021 Add GEO-friendly privacy/local audio answer blocks.
- [x] 022 Add high-intent internal links in footer and navigation.
- [x] 023 Add public support content crawlable by search engines.
- [x] 024 Add public legal pages crawlable by search engines.
- [x] 025 Add launch-grade 404 page.

### Landing Pages And Conversion
- [x] 026 Add a persistent primary navigation.
- [x] 027 Add responsive mobile navigation.
- [x] 028 Add a public download page.
- [x] 029 Add a public support page.
- [x] 030 Add a public privacy page.
- [x] 031 Add a public terms page.
- [x] 032 Add a public changelog page.
- [x] 033 Add a public security page.
- [x] 034 Add a public press page.
- [x] 035 Add a public docs/getting-started page.
- [x] 036 Add use-case coverage for remote meetings.
- [x] 037 Add use-case coverage for streamers.
- [x] 038 Add use-case coverage for podcasters.
- [x] 039 Add use-case coverage for classrooms/workshops.
- [x] 040 Add compatibility matrix for Zoom, Discord, Google Meet, Teams, FaceTime, Slack, OBS, Riverside, and browser apps.
- [x] 041 Add comparison positioning against generic web soundboards.
- [x] 042 Add comparison positioning against Stream Deck-only workflows.
- [x] 043 Add pricing confidence copy that matches the in-app Pro subscription model.
- [x] 044 Add refund/guarantee copy.
- [x] 045 Add checkout URL indirection through environment variables.
- [x] 046 Add download URL indirection through environment variables.
- [x] 047 Add repeated CTAs after major content sections.
- [x] 048 Add support email CTA.
- [x] 049 Add public release notes content.
- [x] 050 Add a clear Free vs Pro subscription message across relevant sections.

### Landing UI, UX, Accessibility, And Performance
- [x] 051 Replace placeholder hero screenshot with an in-page product mockup.
- [x] 052 Replace placeholder screenshots section with real UI-style product panels.
- [x] 053 Add an interactive browser sound pad demo.
- [x] 054 Add realistic macOS menu bar context.
- [x] 055 Add visible virtual microphone routing flow.
- [x] 056 Add accessible FAQ accordion state attributes.
- [x] 057 Add keyboard-focus-visible styles.
- [x] 058 Add skip-to-content link.
- [x] 059 Respect reduced-motion preferences.
- [x] 060 Avoid layout shift in fixed-format product panels.
- [x] 061 Make buttons and CTAs fit on mobile.
- [x] 062 Add hover/focus micro-interactions.
- [x] 063 Add section anchors for direct links.
- [x] 064 Add semantic landmarks.
- [x] 065 Add descriptive aria labels where icon-only controls exist.
- [x] 066 Add high-contrast text treatment for secondary copy.
- [x] 067 Add feature cards with stable dimensions.
- [x] 068 Add trust/security visual treatment.
- [x] 069 Add no-placeholder public visual assets.
- [x] 070 Keep the first viewport product-focused with the next section visible.

### macOS App Functionality And Polish
- [x] 071 Bundle a real app icon.
- [x] 072 Wire the app icon in Info.plist.
- [x] 073 Add drag-and-drop audio import to the sound grid.
- [x] 074 Add drag-and-drop import support to empty folders.
- [x] 075 Ensure imported files respect free-plan limits.
- [x] 076 Support MP3 import.
- [x] 077 Support WAV import.
- [x] 078 Support M4A import.
- [x] 079 Support AAC import.
- [x] 080 Support AIFF import.
- [x] 081 Support CAF import.
- [x] 082 Sanitize imported filenames before copying.
- [x] 083 Prevent empty imported filenames.
- [x] 084 Preserve imported file extensions in lowercase.
- [x] 085 Add per-sound volume editing UI.
- [x] 086 Add sound search.
- [x] 087 Add sound sort controls.
- [x] 088 Persist sound search/sort preferences where useful.
- [x] 089 Fix onboarding navigation wording for required steps.
- [x] 090 Add onboarding status refresh for driver installation.
- [x] 091 Add onboarding status refresh for microphone permission.
- [x] 092 Start audio engine after microphone permission is granted mid-session.
- [x] 093 Clean up shared memory if audio engine startup fails.
- [x] 094 Wire Sparkle update checking to the Settings button.
- [x] 095 Expand file picker audio type support.
- [x] 096 Add visible drop affordance.
- [x] 097 Add safer folder rename validation.
- [x] 098 Add safer sound rename validation.
- [x] 099 Add delete confirmation for sounds.
- [x] 100 Keep local SFX monitor in sync when stopping all sounds.

### Product Trust, Docs, And Release Engineering
- [x] 101 Update root README with current release features.
- [x] 102 Update landing README with launch/deploy notes.
- [x] 103 Document required landing environment variables.
- [x] 104 Document macOS permissions and driver setup.
- [x] 105 Document uninstall steps.
- [x] 106 Document privacy posture.
- [x] 107 Document SEO/GEO assets.
- [x] 108 Add .env ignore coverage for landing secrets.
- [x] 109 Remove or avoid committing generated junk files.
- [x] 110 Run landing lint.
- [x] 111 Run landing production build.
- [x] 112 Run Swift tests.
- [x] 113 Run app target build.
- [x] 114 Run common library target build.
- [x] 115 Run driver target build.
- [x] 116 Run installer target build.
- [x] 117 Verify no placeholder UI remains on the landing page.
- [x] 118 Verify crawl artifacts are generated or present.
- [x] 119 Verify app changes are reflected in project files.
- [x] 120 Complete a prompt-to-artifact audit before declaring done.

## 2026 Release Audit

Completed on May 6, 2026:
- Landing site lint passed with Node 22.22.2.
- Landing site dependency audit passed with 0 vulnerabilities after upgrading to Next 16.2.4 and overriding transitive PostCSS to 8.5.14.
- Landing site production build passed and prerendered `/`, `/_not-found`, `/download`, `/docs/getting-started`, `/support`, `/privacy`, `/terms`, `/changelog`, `/security`, `/press`, `/robots.txt`, `/sitemap.xml`, `/opengraph-image`.
- Production server route check returned HTTP 200 for `/`, `/download`, `/docs/getting-started`, `/support`, `/privacy`, `/terms`, `/changelog`, `/security`, `/press`, `/opengraph-image`, `/robots.txt`, `/sitemap.xml`, and `/llms.txt`.
- Source and rendered homepage checks found no `placeholder`, `App Screenshot`, fake social-proof, LemonSqueezy landing copy, or SSR-hidden `opacity:0` content.
- `swift test --scratch-path /tmp/sounddeck-swiftpm-build` passed 8 RingBuffer tests.
- `xcodebuild -quiet -project SoundDeck.xcodeproj -scheme SoundDeck -configuration Debug -derivedDataPath /tmp/sounddeck-xcodebuild -clonedSourcePackagesDirPath /tmp/sounddeck-xcodebuild-packages CODE_SIGNING_ALLOWED=NO build` passed.
- `xcodebuild -quiet -project SoundDeck.xcodeproj -scheme SoundDeckInstaller -configuration Debug -derivedDataPath /tmp/sounddeck-installer-build CODE_SIGNING_ALLOWED=NO build` passed.
- Built app bundle contains `AppIcon.icns`, 14 bundled WAV sounds, `CFBundleIconFile = AppIcon`, `CFBundleShortVersionString = 1.0.0`, and `SUFeedURL`.

Remaining public-launch blockers outside this code pass:
- Produce a signed and notarized release artifact.
- Set `NEXT_PUBLIC_DOWNLOAD_URL` to the signed artifact before launch.
- Set `NEXT_PUBLIC_CHECKOUT_URL` to the real purchase or subscription destination before launch.
- Configure and verify Sparkle public key/appcast for production updates.
- Verify driver install, virtual microphone discovery, and uninstall on a clean Mac.

## Release Blocker Hardening Pass

Plan:
- [x] Add a release prerequisite verifier for signing, notarization, Sparkle, and landing launch URLs.
- [x] Add a repeatable signed/notarized app build script.
- [x] Add an appcast generation script that requires Sparkle update signing.
- [x] Add a clean-Mac driver smoke-test script.
- [x] Wire `SUPublicEDKey` through build settings so Sparkle can be verified at build time.
- [x] Document the public release workflow and remaining credential/artifact inputs.
- [x] Add CI coverage for landing and macOS release gates.
- [x] Run build/test/site verification after release tooling changes.

Release hardening evidence:
- Added `scripts/verify_release_prereqs.sh`, `scripts/build_release.sh`, `scripts/generate_appcast.sh`, and `scripts/smoke_test_driver.sh`.
- Added `RELEASE.md` with signing, notarization, appcast, production URL, and clean-Mac driver smoke-test workflow.
- Added `.github/workflows/ci.yml` for landing audit/lint/build, Swift tests, unsigned app build, installer build, and bundled resource checks.
- Added `SUPublicEDKey` to `SoundDeckApp/Info.plist` and `SPARKLE_PUBLIC_ED_KEY` to app build settings in `project.yml` and `SoundDeck.xcodeproj/project.pbxproj`.
- Verified shell syntax with `bash -n scripts/verify_release_prereqs.sh scripts/build_release.sh scripts/generate_appcast.sh scripts/smoke_test_driver.sh`.
- Verified appcast XML generation with a temporary fake `sign_update` tool and `xmllint`.
- Verified `SPARKLE_PUBLIC_ED_KEY=TEST_RELEASE_PUBLIC_KEY` substitutes into the built app `SUPublicEDKey`.
- Verified `scripts/verify_release_prereqs.sh` fails on this machine because the real production URLs, Developer ID identity, notarization credentials, Sparkle key, and Sparkle signer are not configured.
- Re-ran `npm run build`, `npm audit --audit-level=moderate`, `swift test --scratch-path /tmp/sounddeck-swiftpm-build`, `xcodebuild -quiet -project SoundDeck.xcodeproj -scheme SoundDeck ... CODE_SIGNING_ALLOWED=NO build`, and `xcodebuild -quiet -project SoundDeck.xcodeproj -scheme SoundDeckInstaller ... CODE_SIGNING_ALLOWED=NO build`.

## Sparkle Runtime Hardening

Plan:
- [x] Start Sparkle automatic update checks only when `SUFeedURL` and `SUPublicEDKey` are configured.
- [x] Route manual update checks through `AppDelegate` so missing release metadata fails gracefully.
- [x] Disable the Settings update button in unsigned/local builds without a Sparkle public key.

Evidence:
- `xcodebuild -quiet -project SoundDeck.xcodeproj -scheme SoundDeck -configuration Debug -derivedDataPath /tmp/sounddeck-xcodebuild -clonedSourcePackagesDirPath /tmp/sounddeck-xcodebuild-packages CODE_SIGNING_ALLOWED=NO build` passed.
- `xcodebuild -quiet -project SoundDeck.xcodeproj -scheme SoundDeck -configuration Debug -derivedDataPath /tmp/sounddeck-xcodebuild-sparkle-key -clonedSourcePackagesDirPath /tmp/sounddeck-xcodebuild-packages CODE_SIGNING_ALLOWED=NO SPARKLE_PUBLIC_ED_KEY=TEST_RELEASE_PUBLIC_KEY build` passed.
- Built local app plist has `SUPublicEDKey = ""`; built release-style test plist has `SUPublicEDKey = TEST_RELEASE_PUBLIC_KEY`.
- `swift test --scratch-path /tmp/sounddeck-swiftpm-build` passed.

## Bundled Default Sound Hardening

Plan:
- [x] Replace placeholder default-sound generator with release-safe synthesized default sound generation.
- [x] Regenerate the 14 bundled WAV files with varied durations and sound-specific treatments.
- [x] Remove placeholder terminology from trim-editor fallback waveform code.
- [x] Verify the app bundle still includes exactly 14 WAV resources.

Evidence:
- Replaced `scripts/generate_placeholder_sounds.sh` with `scripts/generate_default_sounds.sh`.
- `scripts/generate_default_sounds.sh` generated 14 bundled defaults in `Resources/DefaultSounds`.
- `afinfo` verified the regenerated WAV files range from 0.38s to 1.69s, plus 1.0s silence.
- `xcodebuild -quiet -project SoundDeck.xcodeproj -scheme SoundDeck -configuration Debug -derivedDataPath /tmp/sounddeck-xcodebuild -clonedSourcePackagesDirPath /tmp/sounddeck-xcodebuild-packages CODE_SIGNING_ALLOWED=NO build` passed.
- `/tmp/sounddeck-xcodebuild/Build/Products/Debug/SoundDeck.app/Contents/Resources` contains exactly 14 bundled `.wav` files.
- `swift test --scratch-path /tmp/sounddeck-swiftpm-build` passed.

## Landing Verification Hardening

Plan:
- [x] Add an executable landing verifier for lint, audit, build, public routes, crawl artifacts, metadata, structured data, and placeholder regressions.
- [x] Add a `landing` npm script for the verifier.
- [x] Add CI coverage for the verifier.
- [x] Document the verifier in landing release notes.
- [x] Run the verifier locally and record evidence.

Evidence:
- Added `scripts/verify_landing.sh`.
- Added `npm run verify` in `landing/package.json`.
- Updated `.github/workflows/ci.yml` so the landing job runs `npm run verify`.
- Updated `landing/README.md` verification docs.
- `npm run verify` passed: dependency audit 0 vulnerabilities, lint passed, production build passed, all public routes returned 200, homepage metadata/JSON-LD checks passed, crawl asset checks passed, and source placeholder scan passed.
- The verifier now defaults to a random high port and fails if that port is already serving HTTP, preventing stale local server false positives.

## macOS App Verification Hardening

Plan:
- [x] Add an executable app verifier for Swift tests, unsigned app build, Sparkle key substitution, installer build, Info.plist checks, and bundled resource checks.
- [x] Add CI coverage for the app verifier.
- [x] Document the verifier in root verification docs.
- [x] Run the verifier locally and record evidence.

Evidence:
- Added `scripts/verify_app.sh`.
- Updated `.github/workflows/ci.yml` so the macOS job runs `scripts/verify_app.sh`.
- Updated `README.md` verification docs.
- Removed unused SwiftPM dependencies from `Package.swift` so `swift test` no longer reports unused package dependency warnings.
- `scripts/verify_app.sh` passed: app plist lint, release script syntax checks, 14 source WAV check, SwiftPM tests, unsigned app build, app Info.plist checks, app icon check, 14 bundled WAV check, Sparkle key override build, and unsigned installer build.

## Installer CLI Hardening

Plan:
- [x] Allow `SoundDeckInstaller --help` without root privileges.
- [x] Add a non-root `status` command for clean-Mac smoke-test diagnostics.
- [x] Extend `scripts/verify_app.sh` to exercise installer help/status behavior.
- [x] Run app verification and record evidence.

Evidence:
- `SoundDeckInstaller --help` now documents `install`, `uninstall`, and `status` without requiring root.
- `SoundDeckInstaller status` now prints installation state, expected install path, and bundled driver discovery without requiring root.
- `scripts/verify_app.sh` now runs built installer `--help` and `status`.
- `scripts/verify_app.sh` passed after the installer CLI change.
- `swiftc -parse SoundDeckInstaller/main.swift` passed.

## Repo Hygiene Hardening

Plan:
- [x] Remove generated `.DS_Store` files from source directories.
- [x] Add an executable repo hygiene verifier for tracked junk and source-tree metadata.
- [x] Wire the hygiene verifier into CI and app verification.
- [x] Run verification and record evidence.

Evidence:
- Removed `.DS_Store` files from root, source, landing, build, and `.git` directories.
- Added `scripts/verify_repo_hygiene.sh`.
- `scripts/verify_repo_hygiene.sh` checks tracked generated files, source-tree `.DS_Store`/`Thumbs.db`, and local env files.
- `.github/workflows/ci.yml` runs `scripts/verify_repo_hygiene.sh`.
- `scripts/verify_app.sh` runs `scripts/verify_repo_hygiene.sh`.
- `scripts/verify_repo_hygiene.sh` passed.
- `scripts/verify_app.sh` passed with the hygiene gate included.

## Stop-All Consistency Hardening

Plan:
- [x] Make the menu-bar `Stop All Sounds` action stop virtual mic playback, local SFX monitor playback, and any active preview.
- [x] Make the in-app `stopAll` action stop virtual mic playback, local SFX monitor playback, and any active preview.
- [x] Make the global stop-all hotkey stop virtual mic playback, local SFX monitor playback, and any active preview.
- [x] Run app verification and diff checks after the stop-all change.

Evidence:
- `SoundDeckApp/App/AppDelegate.swift` now stops `soundPlayer`, `stopAllSFXMonitor()`, and `stopPreview()` from both the menu-bar action and in-app `AudioActions.stopAll` closure.
- `SoundDeckApp/Hotkeys/HotkeyManager.swift` now stops `soundPlayer`, `stopAllSFXMonitor()`, and `stopPreview()` from the global stop-all hotkey.
- `scripts/verify_app.sh` passed after the change.
- `git diff --check` passed after the change.

## Playback Removal Cleanup Hardening

Plan:
- [x] Stop local SFX monitor playback and active preview before deleting a sound.
- [x] Stop active preview when a per-sound hotkey toggles a playing sound off.
- [x] Run app verification and diff checks after the cleanup change.

Evidence:
- `SoundDeckApp/App/AppDelegate.swift` now stops the virtual mic player, local SFX monitor, and active preview before deleting a sound.
- `SoundDeckApp/Hotkeys/HotkeyManager.swift` now stops active preview when a per-sound hotkey toggles a playing sound off.
- `scripts/verify_app.sh` passed after the cleanup change.
- `git diff --check` passed after the cleanup change.

## Folder Delete Confirmation Hardening

Plan:
- [x] Add a confirmation dialog before deleting a folder from the sidebar context menu.
- [x] Preserve the existing behavior that keeps sounds and moves them back to All Sounds.
- [x] Run app verification and diff checks after the folder delete change.

Evidence:
- `SoundDeckApp/Views/FolderSidebarView.swift` now stores a pending folder deletion, presents a destructive confirmation alert, and only deletes after confirmation.
- The deletion helper still moves sounds in the deleted folder back to All Sounds and clears the selected folder if needed.
- `scripts/verify_app.sh` passed after the folder delete confirmation change.
- `git diff --check` passed after the folder delete confirmation change.

## Current Completion Audit

Objective mapping:
- 100+ features, fixes, and improvements: covered by the 120-item improvement inventory plus the additional release hardening sections above.
- Website SEO/GEO, public pages, crawl assets, CTAs, UI polish, accessibility, and best practices: covered by the landing implementation and `npm run verify`.
- macOS app functionality, bug fixes, and polish: covered by the app implementation sections and `scripts/verify_app.sh`.
- Public-release readiness: partially covered by release tooling and docs, but not complete until production credentials, URLs, signed artifacts, update signing, and clean-Mac driver verification exist.

Current evidence on May 6, 2026:
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed in `landing`: dependency audit, ESLint, Next production build, public route checks, metadata/JSON-LD checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_app.sh` passed after the latest app behavior changes: plist checks, release script syntax checks, repo hygiene, bundled sound checks, Swift tests, unsigned app build, Sparkle key override build, installer build, and installer help/status checks.
- `git diff --check` passed after the latest app behavior changes.
- `scripts/verify_release_prereqs.sh` failed with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Not complete yet:
- Produce and verify a signed, notarized public release artifact.
- Set production landing download and checkout URLs.
- Configure Sparkle public/private update signing and generate/upload a production appcast.
- Run the driver install, virtual microphone discovery, and uninstall smoke test on a clean Mac.

## StoreKit Paywall Availability Hardening

Plan:
- [x] Load StoreKit products when the Pro upgrade sheet appears.
- [x] Keep loaded monthly/yearly products in view state so pricing and purchase availability refresh in the sheet.
- [x] Disable the subscribe button until the selected real StoreKit product is available.
- [x] Surface a clear retry message when products cannot be loaded.
- [x] Run app verification and diff checks after the paywall change.

Evidence:
- `SoundDeckApp/Views/UpgradeView.swift` now reloads StoreKit products on sheet appearance and stores monthly/yearly products in local state for reactive pricing.
- The subscribe button now shows loading/unavailable states and stays disabled until the selected StoreKit product is available.
- The paywall now shows a clear unavailable message plus a Retry button if no products load.
- `scripts/verify_app.sh` passed after the paywall availability change.
- `git diff --check` passed after the paywall availability change.

## Bundled Driver Verification Hardening

Plan:
- [x] Extend the app verifier to assert `SoundDeckDriver.driver` is embedded in the built app resources.
- [x] Verify the embedded driver bundle has a valid plist, bundle identifier, package type, and executable.
- [x] Run app verification and diff checks after the verifier change.

Evidence:
- `scripts/verify_app.sh` now checks the built app has `Contents/Resources/SoundDeckDriver.driver`.
- The verifier now lints the embedded driver plist, checks `CFBundleIdentifier = com.sounddeck.driver`, checks `CFBundlePackageType = BNDL`, and verifies `Contents/MacOS/SoundDeckDriver` is executable.
- `scripts/verify_app.sh` passed with the embedded driver assertions enabled.
- `git diff --check` passed after the verifier change.

## Settings Driver Action State Hardening

Plan:
- [x] Disable Settings driver install/uninstall actions while one is already running.
- [x] Show in-progress labels for install and uninstall actions.
- [x] Show a concise success or failure message after Settings driver actions complete.
- [x] Run app verification and diff checks after the Settings driver action change.

Evidence:
- `SoundDeckApp/Views/SettingsView.swift` now tracks driver install/uninstall in-progress state and disables both driver actions while either operation is running.
- Settings driver buttons now show `Installing...` and `Uninstalling...` labels with progress indicators.
- Settings now reports success or failure text after driver install/uninstall actions complete.
- `scripts/verify_app.sh` passed after the Settings driver action change.
- `git diff --check` passed after the Settings driver action change.

## Pro Library URL Safety Hardening

Plan:
- [x] Build MyInstants API URLs with `URLComponents` instead of manual query escaping.
- [x] Require downloaded sound URLs to use HTTPS.
- [x] Keep existing trending, popular, recent, search, preview, and add-to-library behavior intact.
- [x] Run app verification and diff checks after the Pro library URL safety change.

Evidence:
- `SoundDeckApp/Services/MyInstantsService.swift` now builds search, trending, best, and recent API URLs with `URLComponents`.
- Pro library download URLs now require `https` and a non-empty host before `URLSession.download` starts.
- Existing Pro library preview and add-to-library callers continue to use the same `downloadSound(from:to:)` API.
- `scripts/verify_app.sh` passed after the Pro library URL safety change.
- `git diff --check` passed after the Pro library URL safety change.

## Pro Library Preview Lifecycle Hardening

Plan:
- [x] Cancel any in-flight preview download before starting another preview.
- [x] Ignore stale preview downloads if the user has switched to another sound.
- [x] Reset the preview button after the staged audio file's playback duration.
- [x] Clean up both downloaded temporary preview files and staged app-support preview files.
- [x] Run app verification and diff checks after the Pro library preview lifecycle change.

Evidence:
- `SoundDeckApp/Views/ProLibraryView.swift` now tracks a cancellable preview task and cancels it before starting another preview or closing the sheet.
- Preview downloads now check cancellation and ignore stale completions if `previewingID` has changed.
- The preview button now resets after the staged audio file's measured playback duration.
- Preview cleanup now removes both the downloaded temporary file and the staged app-support preview file.
- `scripts/verify_app.sh` passed after the Pro library preview lifecycle change.
- `git diff --check` passed after the Pro library preview lifecycle change.

## Pro Library Import Naming Hardening

Plan:
- [x] Let `SoundStore.importSound` accept an optional preferred display name.
- [x] Use generated temporary filenames for Pro library downloads instead of API-provided titles or IDs.
- [x] Preserve the Pro library sound title as the sanitized imported display name.
- [x] Clean up Pro library temporary download files on both success and failure.
- [x] Run app verification and diff checks after the Pro library import naming change.

Evidence:
- `SoundDeckApp/Models/SoundStore.swift` now accepts `preferredName` while preserving existing import callers through a default parameter.
- `SoundDeckApp/Views/ProLibraryView.swift` now uses UUID-based temporary filenames for Pro library downloads.
- Pro library imports now pass the API title as the preferred display name, allowing SoundStore to sanitize the visible name separately from the temp file path.
- Pro library temporary download files are removed on both successful import and download failure.
- `scripts/verify_app.sh` passed after the Pro library import naming change.
- `git diff --check` passed after the Pro library import naming change.

## Completion Audit Refresh

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the latest Pro library import naming change, including Swift tests, unsigned app build, embedded driver bundle checks, Sparkle key override build, installer build, installer help/status checks, and repo hygiene.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed in `landing`, including dependency audit, ESLint, production build, public route checks, metadata/JSON-LD checks, crawl asset checks, and placeholder regression checks.
- `git diff --check` passed.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app/site implementation and verifier coverage are materially stronger.
- Public-release readiness is still blocked by production credentials, real production URLs, signed/notarized artifact generation, Sparkle appcast signing/upload, and clean-Mac driver smoke testing.

## Name Length Hardening

Plan:
- [x] Cap imported sound display/file stems to a release-safe length after sanitization.
- [x] Cap manual sound rename text to the same readable length.
- [x] Cap folder create/rename text to the same readable length.
- [x] Run app verification and diff checks after the name length change.

Evidence:
- `SoundDeckApp/Models/SoundStore.swift` now caps sanitized imported sound display/file stems at 80 characters.
- `SoundDeckApp/Views/SoundPadView.swift` now caps manual sound rename text at 80 characters.
- `SoundDeckApp/Views/FolderSidebarView.swift` now caps folder create and rename text at 80 characters.
- `scripts/verify_app.sh` passed after the name length hardening change.
- `git diff --check` passed after the name length hardening change.

## App Support Directory Crash Hardening

Plan:
- [x] Remove the force unwrap from `SoundStore.appSupportDirectory`.
- [x] Fall back to `~/Library/Application Support` if macOS does not return an Application Support directory URL.
- [x] Run app verification and diff checks after the app-support directory change.

Evidence:
- `SoundDeckApp/Models/SoundStore.swift` now uses the first user Application Support URL when available and falls back to `~/Library/Application Support`.
- The app-support directory path no longer force unwraps the FileManager result.
- `scripts/verify_app.sh` passed after the app-support directory change.
- `git diff --check` passed after the app-support directory change.

## Appcast XML Validation Hardening

Plan:
- [x] Escape generated appcast XML text and attribute values.
- [x] Validate generated appcast XML with `xmllint`.
- [x] Require `xmllint` in release prerequisite checks.
- [x] Run release script syntax checks, appcast generation smoke test, app verification, and diff checks.

Evidence:
- `scripts/generate_appcast.sh` now XML-escapes generated version, build, download URL, release-notes URL, publication date, and Sparkle signature values before writing the feed.
- `scripts/generate_appcast.sh` now runs `xmllint --noout` on the generated appcast before reporting success.
- `scripts/verify_release_prereqs.sh` now requires `xmllint`.
- `bash -n scripts/verify_release_prereqs.sh scripts/generate_appcast.sh scripts/build_release.sh scripts/verify_app.sh` passed.
- A fake `sign_update` smoke test generated an appcast with `&` query parameters in download and release-notes URLs, validated it with `xmllint`, and verified the URLs were escaped as `&amp;`.
- `scripts/verify_app.sh` passed after the appcast validation change.
- `git diff --check` passed after the appcast validation change.

## Settings Restore Purchases Feedback Hardening

Plan:
- [x] Show progress while Settings restore-purchases is running.
- [x] Disable duplicate restore taps while a restore is in progress.
- [x] Show a concise success, no-purchase, or failure message after restore completes.
- [x] Run app verification and diff checks after the restore feedback change.

Evidence:
- `SoundDeckApp/Views/SettingsView.swift` now tracks restore-purchases progress and disables the restore button while StoreKit sync is running.
- Settings now shows `Restoring...` with a progress indicator during restore.
- Settings now reports restored Pro access, no active subscription found, or the StoreKit restore error after completion.
- `scripts/verify_app.sh` passed after the restore feedback change.
- `git diff --check` passed after the restore feedback change.

## Completion Audit Refresh 2

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the latest Settings restore-purchases feedback change.
- Appcast generation was smoke-tested with a fake Sparkle signer, `&` query parameters in URLs, `xmllint` validation, and `&amp;` escaping checks.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` now confirms `xmllint` is available, but still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- The remaining public-release blockers are external production configuration and clean-machine validation, not local code edits.

## Subscription Restore Error-State Hardening

Plan:
- [x] Clear stale `purchaseError` inside `SubscriptionManager.restorePurchases()`.
- [x] Remove caller-specific restore error clearing now that the manager owns it.
- [x] Preserve existing purchase error handling and restore result UI.
- [x] Run app verification and diff checks after the restore error-state change.

Evidence:
- `SoundDeckApp/Subscription/SubscriptionManager.swift` now clears `purchaseError` at the start of every restore operation.
- `SoundDeckApp/Views/SettingsView.swift` no longer mutates `purchaseError` directly before restore.
- Upgrade and Settings restore flows now share the same stale-error clearing behavior through `SubscriptionManager`.
- `scripts/verify_app.sh` passed after the restore error-state change.
- `git diff --check` passed after the restore error-state change.

## Audio Graph Force-Unwrap Hardening

Plan:
- [x] Replace the implicitly unwrapped `voiceChanger` property with a normal initialized property.
- [x] Reuse the existing target output format for the SFX mixer path instead of force-unwrapping a duplicate format.
- [x] Attach/connect the sink node through a local non-optional value instead of force-unwrapping `sinkNode`.
- [x] Run app verification and diff checks after the audio graph hardening change.

Evidence:
- `SoundDeckApp/Audio/AudioEngineManager.swift` now declares `voiceChanger` as a normal initialized property instead of an implicitly unwrapped optional.
- The SFX mixer path now reuses `outputFormat` instead of force-unwrapping a duplicate `AVAudioFormat`.
- The sink node is now attached and connected through a local non-optional value before being stored.
- `scripts/verify_app.sh` passed after the audio graph force-unwrap hardening change.
- `git diff --check` passed after the audio graph force-unwrap hardening change.

## Playback Format Force-Unwrap Hardening

Plan:
- [x] Remove the force unwrap from `PreviewEngine` monitor format initialization.
- [x] Remove force unwraps from `SoundPlayer` pool and preload target format creation.
- [x] Log and skip setup/preload if AVFoundation cannot create the expected standard format.
- [x] Run app verification and diff checks after the playback format hardening change.

Evidence:
- `SoundDeckApp/Audio/PreviewEngine.swift` now treats monitor format creation as optional and logs setup failure instead of force-unwrapping.
- `SoundDeckApp/Audio/SoundPlayer.swift` now stores the target playback format as optional, logs setup/preload failures, and no longer force-unwraps the standard format.
- `scripts/verify_app.sh` passed after the playback format hardening change.
- `git diff --check` passed after the playback format hardening change.

## Audio Device Default Selection Hardening

Plan:
- [x] Treat Settings picker tag `0` as nil for selected input and output devices.
- [x] Avoid passing output device ID `0` into PreviewEngine.
- [x] Resolve nil PreviewEngine output device selection to the current system default output device.
- [x] Run app verification and diff checks after the audio device default-selection change.

Evidence:
- `SoundDeckApp/Views/SettingsView.swift` now maps the System Default picker tag `0` to nil for input and output device selections.
- `SoundDeckApp/App/AppDelegate.swift` no longer forwards output device ID `0` to `PreviewEngine`.
- `SoundDeckApp/Audio/PreviewEngine.swift` now resolves nil output-device selection to CoreAudio's current default output device.
- `scripts/verify_app.sh` passed after the audio device default-selection change.
- `git diff --check` passed after the audio device default-selection change.

## Shared Memory Mapping Force-Unwrap Hardening

Plan:
- [x] Validate `mmap` returned a non-nil pointer as well as not `MAP_FAILED`.
- [x] Bind the mapped pointer without force-unwrapping.
- [x] Run app verification and diff checks after the shared-memory mapping change.

Evidence:
- `SoundDeckApp/Audio/SharedMemoryWriter.swift` now guards `mmap` against both nil and `MAP_FAILED`.
- The mapped shared-memory pointer is now bound without force-unwrapping.
- `scripts/verify_app.sh` passed after the shared-memory mapping change.
- `git diff --check` passed after the shared-memory mapping change.

## Completion Audit Refresh 3

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the latest audio/shared-memory hardening changes.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local verification remains green, but public-release readiness still requires external signing, update, URL, and clean-Mac validation inputs.

## Voice Changer Entitlement Runtime Hardening

Plan:
- [x] Add a computed active voice changer state that requires both Pro entitlement and the user toggle.
- [x] Gate audio graph startup and runtime voice changer enablement on that active state.
- [x] Update popover visual state to reflect active entitlement-gated voice changer state.
- [x] Run app verification and diff checks after the entitlement runtime change.

Evidence:
- `SoundDeckApp/App/AppState.swift` now exposes `isVoiceChangerActive` as `canUseVoiceChanger && isVoiceChangerEnabled`.
- `SoundDeckApp/Audio/AudioEngineManager.swift` now gates both graph startup and runtime voice changer enablement on the entitlement-aware active state.
- `SoundDeckApp/Views/PopoverContentView.swift` now colors the voice changer control only when the entitlement-gated active state is true.
- `scripts/verify_app.sh` passed after the voice changer entitlement runtime hardening change.
- `git diff --check` passed after the voice changer entitlement runtime hardening change.

## Completion Audit Refresh 4

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the voice changer entitlement runtime hardening change.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Pro Library Runtime Entitlement Hardening

Plan:
- [x] Show a locked Pro-required state inside `ProLibraryView` when entitlement is not active.
- [x] Gate Pro library network loading, preview downloads, and add-to-library imports at runtime.
- [x] Stop/cancel Pro library preview and search work if Pro entitlement is lost while the sheet is open.
- [x] Add app verifier coverage for Pro library runtime entitlement guards.
- [x] Run app verification and diff checks after the Pro library entitlement change.

Evidence:
- `SoundDeckApp/Views/ProLibraryView.swift` now shows a locked Pro-required state if `appState.canAccessProLibrary` is false.
- Pro library loading, preview downloads, and add-to-library imports now guard `appState.canAccessProLibrary` at runtime.
- Pro library search and preview work is cancelled, preview audio is stopped, and transient download state is cleared if Pro entitlement is lost while the sheet is open.
- `scripts/verify_app.sh` now checks for Pro library runtime entitlement guards.
- `scripts/verify_app.sh` passed after the Pro library entitlement change.
- `git diff --check` passed after the Pro library entitlement change.

## Free Plan Custom Slot Hardening

Plan:
- [x] Count only custom imported sounds against the free-plan sound limit.
- [x] Keep bundled default sounds included on first launch without blocking a free user from importing custom sounds.
- [x] Update in-app copy so the limit is described as custom sound slots, not all sounds.
- [x] Add app verifier coverage for default-sound/free-slot consistency.
- [x] Run app verification and diff checks after the free-plan slot change.

Evidence:
- `SoundDeckApp/App/AppState.swift` now identifies the 14 bundled default sound filenames and exposes `customSoundCount`.
- `canAddMoreSounds` now uses `customSoundCount < maxFreeSounds`, so bundled defaults do not consume free custom import slots.
- `SoundDeckApp/Views/SoundGridView.swift`, `SoundDeckApp/Views/UpgradeView.swift`, and `SoundDeckApp/Views/TermsView.swift` now describe the limit as custom sound slots/imports.
- `scripts/verify_app.sh` now checks that free-plan capacity uses custom sound count and does not regress to `sounds.count < maxFreeSounds`.
- `scripts/verify_app.sh` passed after the free-plan custom slot change.
- `git diff --check` passed after the free-plan custom slot change.

## Release Prerequisite Production-Value Hardening

Plan:
- [x] Reject placeholder or local `NEXT_PUBLIC_SITE_URL` values in release prerequisite checks.
- [x] Reject obvious placeholder, test, or malformed `SPARKLE_PUBLIC_ED_KEY` values before release builds.
- [x] Add verifier coverage so release prerequisite checks keep the stronger production guards.
- [x] Run release script syntax checks, app verification, release prerequisite check, and diff checks after the release gate change.

Evidence:
- `scripts/verify_release_prereqs.sh` now rejects placeholder/local values such as `localhost`, `127.0.0.1`, `0.0.0.0`, `example`, and `CHANGE_ME`.
- `scripts/verify_release_prereqs.sh` now validates `SPARKLE_PUBLIC_ED_KEY` with a production-looking EdDSA public-key shape and explicitly rejects `TEST_RELEASE_PUBLIC_KEY`.
- `scripts/verify_app.sh` now checks that the release prerequisite script keeps the stronger site URL and Sparkle key guards.
- `bash -n scripts/verify_release_prereqs.sh scripts/verify_app.sh scripts/build_release.sh scripts/generate_appcast.sh` passed.
- A targeted release-prerequisite smoke run rejected `NEXT_PUBLIC_SITE_URL=https://localhost:3000` and `SPARKLE_PUBLIC_ED_KEY=TEST_RELEASE_PUBLIC_KEY`.
- `scripts/verify_app.sh` passed after the release prerequisite hardening change.
- `scripts/verify_release_prereqs.sh` still fails without production inputs, now explicitly including the missing real production site URL and production Sparkle EdDSA key checks.
- `git diff --check` passed after the release prerequisite hardening change.

## Completion Audit Refresh 9

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the deleted-sound hotkey cleanup, import limit/folder assignment, and per-sound hotkey runtime hardening changes, including the added regression checks.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Deleted Sound Hotkey Cleanup Hardening

Plan:
- [x] Clear the persisted KeyboardShortcuts shortcut when a sound is deleted.
- [x] Keep existing handler removal so deleted sounds cannot be triggered during the current session.
- [x] Add app verifier coverage for persisted shortcut cleanup on delete.
- [x] Run app verification and diff checks after the hotkey cleanup change.

Evidence:
- `SoundDeckApp/Models/SoundStore.swift` now clears the stored KeyboardShortcuts shortcut with `KeyboardShortcuts.setShortcut(nil, for: hotkeyName)` when deleting a sound.
- Existing runtime handler removal remains in place, so deleted sounds cannot be triggered in the current session.
- `scripts/verify_app.sh` now checks that sound deletion clears persisted KeyboardShortcuts assignments.
- `scripts/verify_app.sh` passed after the deleted-sound hotkey cleanup change.
- `git diff --check` passed after the deleted-sound hotkey cleanup change.

## Import Limit And Folder Assignment Hardening

Plan:
- [x] Make imported sounds append synchronously when import is already running on the main thread so batch imports update free-plan capacity immediately.
- [x] Move selected-folder assignment into `SoundStore.importSound` so imported sounds enter the correct folder atomically.
- [x] Remove post-import folder mutation from `AppDelegate` import callers.
- [x] Add app verifier coverage for the import limit/folder assignment regression.
- [x] Run app verification and diff checks after the import hardening change.

Evidence:
- `SoundDeckApp/Models/SoundStore.swift` now accepts `folderID` during import and creates the `SoundItem` with that folder assignment immediately.
- `SoundStore` now appends imported sounds synchronously when already on the main thread, so OpenPanel batch imports update `appState.sounds.count` before the next free-plan capacity check.
- `SoundDeckApp/App/AppDelegate.swift` import callers now pass `folderID` into `SoundStore.importSound` and no longer mutate `folderID` after import.
- `scripts/verify_app.sh` now includes an import limit/folder assignment regression check.
- `scripts/verify_app.sh` passed after the import hardening change.
- `git diff --check` passed after the import hardening change.

## Completion Audit Refresh 6

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the import limit/folder assignment hardening change, including the new import regression check.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Per-Sound Hotkey Runtime Hardening

Plan:
- [x] Register per-sound hotkey handlers from the current sound list instead of depending on `SoundItem.hotkeyName`.
- [x] Remove existing per-sound handlers before re-registering so repeated sound or entitlement changes cannot duplicate handlers.
- [x] Sync recorder changes into sound metadata while displaying the actual assigned KeyboardShortcuts shortcut on pads.
- [x] Add app verifier coverage for the hotkey source-of-truth regression.
- [x] Run app verification and diff checks after the hotkey runtime change.

Evidence:
- `SoundDeckApp/Hotkeys/HotkeyManager.swift` now registers Pro per-sound handlers from the current sound list rather than requiring `SoundItem.hotkeyName` to be pre-populated.
- `HotkeyManager` now tracks registered per-sound shortcut names and removes handlers before re-registering, preventing duplicate callbacks after sound-list or entitlement changes.
- `SoundDeckApp/Views/SettingsView.swift` now syncs recorder changes into sound metadata and backfills existing assigned shortcuts when the recorder row appears.
- `SoundDeckApp/Views/SoundPadView.swift` now displays the actual assigned KeyboardShortcuts shortcut instead of the raw per-sound shortcut name.
- `scripts/verify_app.sh` now includes a per-sound hotkey runtime regression check for the source-of-truth mismatch.
- `scripts/verify_app.sh` passed after the per-sound hotkey runtime change.
- `git diff --check` passed after the per-sound hotkey runtime change.

## Completion Audit Refresh 5

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the per-sound hotkey runtime hardening change, including the new hotkey source-of-truth regression check.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Completion Audit Refresh 8

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the latest import limit/folder assignment and per-sound hotkey hardening changes, including both new regression checks.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Completion Audit Refresh 10

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the deleted-sound hotkey cleanup, import limit/folder assignment, and per-sound hotkey runtime hardening changes, including the added regression checks.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Completion Audit Refresh 11

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after release prerequisite production-value hardening, including the added release-script regression guards.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Completion Audit Refresh 12

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the free-plan custom slot hardening change, including the new default-sound/free-slot consistency check.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Completion Audit Refresh 13

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed after the Pro library runtime entitlement hardening change, including the new entitlement guard checks.
- `git diff --check` passed after the latest changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Completion Audit Refresh 14

Current evidence on May 6, 2026:
- `scripts/verify_app.sh` passed on the current tree after the Pro library runtime entitlement hardening change, including repo hygiene, release-script static checks, hotkey/import/free-plan/Pro-library regression checks, SwiftPM tests, unsigned app build, Sparkle-key override app build, and unsigned installer build.
- `git diff --check` passed on the current tree.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app verification remains green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## CI Workflow Path Hardening

Plan:
- [x] Fix the landing CI job so root repo scripts execute from the repository root.
- [x] Keep landing dependency and verification commands scoped to `landing/`.
- [x] Add local verifier coverage so the CI workflow cannot reintroduce the root-script path bug.
- [x] Run workflow/script syntax checks, the app verifier, and `git diff --check`.

Evidence:
- `.github/workflows/ci.yml` no longer sets a job-level `working-directory: landing`, so `scripts/verify_repo_hygiene.sh` resolves from the repository root.
- The landing CI job now scopes `npm ci` and `npm run verify` to `landing/` at the step level.
- `scripts/verify_app.sh` now checks the CI workflow path layout, including the root repo hygiene command, landing-scoped npm commands, and absence of a job-level `defaults:` block.
- Workflow YAML parsed successfully with Ruby's YAML loader.
- `scripts/verify_app.sh` passed after the CI workflow path hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `git diff --check` passed after the CI workflow path hardening change.

## Completion Audit Refresh 15

Current evidence on May 6, 2026:
- `.github/workflows/ci.yml` now runs repo hygiene from the repository root and scopes only landing npm commands to `landing/`.
- `scripts/verify_app.sh` passed after adding CI workflow path regression coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, production server route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- Workflow YAML parsed successfully with Ruby's YAML loader.
- `git diff --check` passed on the current tree.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, and CI workflow-path verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## CI Command Dependency Hardening

Plan:
- [x] Install `ripgrep` explicitly in the landing and macOS CI jobs before verifier scripts run.
- [x] Add early `rg` command checks to repo hygiene and landing verification scripts.
- [x] Extend app verifier coverage so the CI workflow keeps provisioning `ripgrep`.
- [x] Run script syntax checks, app verification, landing verification, release prerequisite audit, and `git diff --check`.

Evidence:
- `.github/workflows/ci.yml` now installs `ripgrep` with `apt-get` before Linux repo/landing verifier scripts run.
- `.github/workflows/ci.yml` now installs `ripgrep` with Homebrew before the macOS app verifier runs.
- `scripts/verify_repo_hygiene.sh` now fails early with a clear missing-command error if `git`, `rg`, or `find` is unavailable.
- `scripts/verify_landing.sh` now fails early with a clear missing-command error if `rg` is unavailable.
- `scripts/verify_app.sh` now checks that the CI workflow provisions `ripgrep` in both Linux and macOS jobs.
- `bash -n scripts/verify_repo_hygiene.sh scripts/verify_landing.sh scripts/verify_app.sh` passed.
- Workflow YAML parsed successfully with Ruby's YAML loader.
- `scripts/verify_repo_hygiene.sh` passed after adding explicit command checks.
- `scripts/verify_app.sh` passed after the CI command dependency hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `git diff --check` passed after the CI command dependency hardening change.

## Completion Audit Refresh 16

Current evidence on May 6, 2026:
- The CI workflow now explicitly provisions `ripgrep` for Linux landing verification and macOS app verification.
- Repo hygiene and landing verification scripts now check for `rg` before using it.
- `scripts/verify_app.sh` passed after adding CI `ripgrep` provisioning checks.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_repo_hygiene.sh` passed on the current tree.
- Workflow YAML parsed successfully with Ruby's YAML loader.
- `git diff --check` passed on the current tree.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, repo hygiene, and CI dependency verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Release Build Path Safety Hardening

Plan:
- [x] Normalize `DIST_DIR`, `ARCHIVE_PATH`, and `EXPORT_DIR` before release cleanup.
- [x] Reject root, home, repo-root, or outside-dist cleanup targets before running prerequisite checks or deleting anything.
- [x] Add app verifier coverage so release cleanup safety cannot regress.
- [x] Run a bad-path smoke test, script syntax checks, app and landing verifiers, release prerequisite audit, and `git diff --check`.

Evidence:
- `scripts/build_release.sh` now normalizes release output paths, rejects empty/root/home/repo-root/dist-root cleanup targets, rejects parent-directory references, and requires cleanup targets to stay inside `DIST_DIR`.
- Release cleanup now uses `rm -rf -- "$ARCHIVE_PATH" "$EXPORT_DIR"` after the path safety checks.
- `scripts/verify_app.sh` now checks for the release cleanup path-safety guard and rejects the old unguarded cleanup pattern.
- `DIST_DIR=/ scripts/build_release.sh` failed before prerequisites with `DIST_DIR must not be the filesystem root`.
- `ARCHIVE_PATH='dist/../bad.xcarchive' scripts/build_release.sh` failed before prerequisites with `ARCHIVE_PATH must not contain parent-directory references`.
- `ARCHIVE_PATH=/tmp/SoundDeck.xcarchive scripts/build_release.sh` failed before prerequisites with `ARCHIVE_PATH must stay inside DIST_DIR`.
- `bash -n scripts/build_release.sh scripts/verify_app.sh` passed.
- `scripts/build_release.sh` with default paths reached the expected `scripts/verify_release_prereqs.sh` failure instead of a path-safety failure.
- `scripts/verify_app.sh` passed after the release build path-safety hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `git diff --check` passed after the release build path-safety hardening change.

## Completion Audit Refresh 17

Current evidence on May 6, 2026:
- `scripts/build_release.sh` now guards release cleanup paths before prerequisite checks or deletion.
- Unsafe release path override smoke tests fail early for root `DIST_DIR`, parent-directory `ARCHIVE_PATH`, and outside-dist `ARCHIVE_PATH`.
- Default `scripts/build_release.sh` execution reaches the known production prerequisite failure, confirming normal default paths are accepted by the new safety guard.
- `scripts/verify_app.sh` passed after adding release cleanup safety coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `git diff --check` passed on the current tree.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, and release-script safety verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Appcast Output And URL Safety Hardening

Plan:
- [x] Normalize appcast `DIST_DIR` and `APPCAST_PATH` before writing XML.
- [x] Reject root, home, repo-root, dist-root, parent-directory, or outside-dist appcast output paths.
- [x] Reject local or placeholder appcast download URLs even when `DOWNLOAD_URL` is passed directly.
- [x] Add app verifier coverage for appcast path and URL safety.
- [x] Run bad-path, placeholder-URL, and successful fake-signer appcast smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/generate_appcast.sh` now normalizes `DIST_DIR` and `APPCAST_PATH` before writing XML.
- `scripts/generate_appcast.sh` now rejects empty/root/home/repo-root/dist-root output targets, parent-directory references, and appcast output paths outside `DIST_DIR`.
- `scripts/generate_appcast.sh` now rejects direct `DOWNLOAD_URL` or `NEXT_PUBLIC_DOWNLOAD_URL` values containing `CHANGE_ME`, `example`, `localhost`, `127.0.0.1`, or `0.0.0.0`.
- `scripts/verify_app.sh` now checks for appcast output path safety, direct download URL production checks, and inside-`DIST_DIR` output enforcement.
- `APPCAST_PATH=/tmp/appcast.xml ... scripts/generate_appcast.sh` failed with `APPCAST_PATH must stay inside DIST_DIR`.
- `APPCAST_PATH='dist/../appcast.xml' ... scripts/generate_appcast.sh` failed with `APPCAST_PATH must not contain parent-directory references`.
- `DOWNLOAD_URL=https://localhost/SoundDeck.zip ... scripts/generate_appcast.sh` failed with `DOWNLOAD_URL or NEXT_PUBLIC_DOWNLOAD_URL must be a real production URL`.
- A fake-signer appcast smoke generated valid XML in a temporary `DIST_DIR`, and `xmllint --noout` plus `rg 'sparkle:edSignature="FAKE_ED_SIGNATURE"'` passed.
- `bash -n scripts/generate_appcast.sh scripts/verify_app.sh` passed.
- `scripts/verify_app.sh` passed after the appcast output and URL safety hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `git diff --check` passed after the appcast output and URL safety hardening change.

## Completion Audit Refresh 18

Current evidence on May 6, 2026:
- `scripts/generate_appcast.sh` now guards `APPCAST_PATH` and direct download URLs before writing the appcast XML.
- Unsafe appcast path and placeholder/local URL smoke tests fail early.
- A fake-signer appcast smoke still generates valid XML with a parsed Sparkle EdDSA signature.
- `scripts/verify_app.sh` passed after adding appcast path and URL safety coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, and appcast safety verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Release Download Artifact URL Hardening

Plan:
- [x] Require `NEXT_PUBLIC_DOWNLOAD_URL` to point at a `.zip` artifact in the release prerequisite gate.
- [x] Require appcast `DOWNLOAD_URL` or `NEXT_PUBLIC_DOWNLOAD_URL` to point at a `.zip` artifact, while allowing signed URLs with query strings.
- [x] Add app verifier coverage for the `.zip` artifact URL guards.
- [x] Run non-zip and signed-query URL smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_release_prereqs.sh` now checks non-empty `NEXT_PUBLIC_DOWNLOAD_URL` values for `.zip` or `.zip?...` release artifact URLs.
- `scripts/generate_appcast.sh` now rejects appcast download URLs that do not point to `.zip` or `.zip?...` release artifacts.
- `scripts/verify_app.sh` now checks that release prerequisite and appcast scripts keep the `.zip` artifact URL guards.
- A release-prereq smoke with `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/download` failed with `NEXT_PUBLIC_DOWNLOAD_URL must point to a .zip release artifact`.
- An appcast smoke with `DOWNLOAD_URL=https://sounddeck.app/download` failed with `DOWNLOAD_URL or NEXT_PUBLIC_DOWNLOAD_URL must point to a .zip release artifact`.
- An appcast smoke with `DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip?token=abc` generated valid XML.
- The empty-download release-prereq path still aggregates all expected missing production inputs after fixing the helper to `return 0` on empty values.
- `bash -n scripts/verify_release_prereqs.sh scripts/generate_appcast.sh scripts/verify_app.sh` passed.
- `scripts/verify_app.sh` passed after the release download artifact URL hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the release download artifact URL hardening change.

## Completion Audit Refresh 19

Current evidence on May 6, 2026:
- Release prerequisite and appcast generation scripts now require the public download URL to point at a `.zip` release artifact, including signed `.zip?...` URLs.
- Targeted non-zip URL smokes fail in both `scripts/verify_release_prereqs.sh` and `scripts/generate_appcast.sh`.
- A targeted signed-query `.zip` appcast smoke still generates valid XML.
- `scripts/verify_app.sh` passed after adding `.zip` artifact URL guard coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, and release URL safety verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Appcast Release Notes URL Hardening

Plan:
- [x] Add production HTTPS validation for `RELEASE_NOTES_URL` in `scripts/generate_appcast.sh`.
- [x] Reject local or placeholder release notes URLs before appcast XML generation.
- [x] Document the optional `RELEASE_NOTES_URL` override in `RELEASE.md`.
- [x] Add app verifier coverage for release-notes URL safety.
- [x] Run targeted bad/good release-notes URL smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/generate_appcast.sh` now validates `RELEASE_NOTES_URL` with production HTTPS URL rules before appcast XML generation.
- `scripts/generate_appcast.sh` now splits general production HTTPS validation from `.zip` artifact URL validation so release notes can be validated without inheriting the download-artifact rule.
- `RELEASE.md` now documents the optional `RELEASE_NOTES_URL` override and requires a production HTTPS URL.
- `scripts/verify_app.sh` now checks release-notes URL validation and release documentation coverage.
- `RELEASE_NOTES_URL=http://sounddeck.app/changelog ... scripts/generate_appcast.sh` failed with `Set RELEASE_NOTES_URL to a public https URL`.
- `RELEASE_NOTES_URL=https://localhost/changelog ... scripts/generate_appcast.sh` failed with `RELEASE_NOTES_URL must be a real production URL`.
- `RELEASE_NOTES_URL=https://sounddeck.app/changelog#v1 ... scripts/generate_appcast.sh` generated valid XML, and `xmllint --noout` plus an `rg` check for the custom URL passed.
- `bash -n scripts/generate_appcast.sh scripts/verify_app.sh` passed.
- `scripts/verify_app.sh` passed after the appcast release-notes URL hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the appcast release-notes URL hardening change.

## Completion Audit Refresh 20

Current evidence on May 6, 2026:
- `scripts/generate_appcast.sh` now validates `RELEASE_NOTES_URL` as a production HTTPS URL before generating XML.
- Targeted HTTP and localhost release-notes URL smokes fail early.
- A targeted production HTTPS release-notes URL smoke still generates valid XML.
- `RELEASE.md` documents the optional `RELEASE_NOTES_URL` override and production HTTPS requirement.
- `scripts/verify_app.sh` passed after adding release-notes URL and docs coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, and release-notes safety verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Source Release Metadata Hardening

Plan:
- [x] Validate source `SoundDeckApp/Info.plist` `SUFeedURL` against the production appcast URL in the release prerequisite gate.
- [x] Validate source `SUPublicEDKey` is wired to the `SPARKLE_PUBLIC_ED_KEY` build setting instead of a blank, test, or hardcoded key.
- [x] Add app verifier coverage for source release metadata checks.
- [x] Run targeted bad-plist smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_release_prereqs.sh` now validates source `SUFeedURL` against `https://updates.sounddeck.app/appcast.xml`.
- `scripts/verify_release_prereqs.sh` now validates source `SUPublicEDKey` is `$(SPARKLE_PUBLIC_ED_KEY)`, keeping the production Sparkle key injected at build time.
- `scripts/verify_release_prereqs.sh` accepts an `APP_PLIST` override for targeted verifier smokes without mutating the real source plist.
- `scripts/verify_app.sh` now checks for the source Sparkle metadata guards in the release prerequisite script.
- A bad-plist smoke with `SUFeedURL=https://example.com/appcast.xml` failed with `SUFeedURL must be https://updates.sounddeck.app/appcast.xml`.
- A bad-plist smoke with `SUPublicEDKey=TEST_RELEASE_PUBLIC_KEY` failed with `SUPublicEDKey must be $(SPARKLE_PUBLIC_ED_KEY)`.
- `bash -n scripts/verify_release_prereqs.sh scripts/verify_app.sh` passed.
- `scripts/verify_app.sh` passed after the source release metadata hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` passed the source metadata checks on the real plist and still failed with the expected 11 missing production inputs.
- `git diff --check` passed after the source release metadata hardening change.

## Completion Audit Refresh 21

Current evidence on May 6, 2026:
- The release prerequisite gate now validates the exact source Sparkle feed URL and public-key build setting before archive/sign/notarize work.
- Targeted bad-plist smokes fail for a wrong `SUFeedURL` and a hardcoded/test `SUPublicEDKey`.
- The real `SoundDeckApp/Info.plist` passes the new source release metadata checks.
- `scripts/verify_app.sh` passed after adding source release metadata coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, and source metadata verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Appcast Archive Filename Consistency Hardening

Plan:
- [x] Require `ARCHIVE_ZIP` to use the `SoundDeck-{version}-{build}.zip` filename expected from `scripts/build_release.sh`.
- [x] Keep version/build overrides supported for targeted release metadata, but validate the archive filename against the effective values.
- [x] Document the expected archive filename in `RELEASE.md`.
- [x] Add app verifier coverage for the archive filename consistency check.
- [x] Run mismatched and matched archive smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/generate_appcast.sh` now derives `EXPECTED_ARCHIVE_NAME="SoundDeck-${VERSION}-${BUILD}.zip"` from the effective version/build values.
- `scripts/generate_appcast.sh` now rejects `ARCHIVE_ZIP` basenames that do not match the appcast version/build metadata.
- `RELEASE.md` now documents the `SoundDeck-{CFBundleShortVersionString}-{CFBundleVersion}.zip` archive filename contract.
- `scripts/verify_app.sh` now checks appcast archive filename consistency guards and release documentation coverage.
- A fake appcast smoke with `ARCHIVE_ZIP=WrongName.zip` failed with `ARCHIVE_ZIP filename must be SoundDeck-1.0.0-1.zip`.
- A fake appcast smoke with `ARCHIVE_ZIP=SoundDeck-1.0.0-1.zip` generated valid XML, and `xmllint --noout` plus an `rg` check for `sparkle:version="1"` passed.
- `bash -n scripts/generate_appcast.sh scripts/verify_app.sh` passed.
- `scripts/verify_app.sh` passed after the appcast archive filename consistency hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the appcast archive filename consistency hardening change.

## Completion Audit Refresh 22

Current evidence on May 6, 2026:
- `scripts/generate_appcast.sh` now requires the signed archive filename to match the effective appcast version/build metadata.
- Targeted archive filename smokes fail for `WrongName.zip` and pass for `SoundDeck-1.0.0-1.zip`.
- `RELEASE.md` documents the expected archive filename contract.
- `scripts/verify_app.sh` passed after adding archive filename consistency coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, and archive consistency verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Release Download Filename Consistency Hardening

Plan:
- [x] Require `NEXT_PUBLIC_DOWNLOAD_URL` filename to match `SoundDeck-{CFBundleShortVersionString}-{CFBundleVersion}.zip` in the release prerequisite gate.
- [x] Require appcast `DOWNLOAD_URL` filename to match the effective `SoundDeck-{version}-{build}.zip` archive name, including signed URLs with query strings.
- [x] Add app verifier coverage for public download filename consistency.
- [x] Run mismatched and matched URL smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_release_prereqs.sh` now derives `SoundDeck-{CFBundleShortVersionString}-{CFBundleVersion}.zip` from the source plist and validates the public download URL filename against it.
- `scripts/generate_appcast.sh` now strips query strings and fragments before comparing the public download URL filename with the expected archive filename.
- `scripts/verify_app.sh` now checks the release prerequisite and appcast public download filename consistency guards.
- A release prerequisite smoke with `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/Other.zip` failed with `NEXT_PUBLIC_DOWNLOAD_URL filename must be SoundDeck-1.0.0-1.zip`.
- An appcast smoke with `DOWNLOAD_URL=https://sounddeck.app/downloads/Other.zip` failed with `DOWNLOAD_URL filename must be SoundDeck-1.0.0-1.zip`.
- An appcast smoke with `DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip?token=abc#frag` generated valid XML.
- `bash -n scripts/verify_release_prereqs.sh scripts/generate_appcast.sh scripts/verify_app.sh` passed.
- `scripts/verify_app.sh` passed after the release download filename consistency hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the release download filename consistency hardening change.

## Completion Audit Refresh 23

Current evidence on May 6, 2026:
- Release prerequisite and appcast generation scripts now require the public download URL filename to match the effective SoundDeck release archive filename.
- Targeted mismatched public zip URL smokes fail in both `scripts/verify_release_prereqs.sh` and `scripts/generate_appcast.sh`.
- A targeted signed matching public zip URL smoke still generates valid appcast XML.
- `scripts/verify_app.sh` passed after adding public download filename consistency coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, and public download filename verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Release Version Metadata Safety Hardening

Plan:
- [x] Validate `CFBundleShortVersionString` uses numeric `major.minor.patch` format before release paths are derived.
- [x] Validate `CFBundleVersion` uses numeric build format before release paths are derived.
- [x] Apply the same validation in release prereqs, release build, and appcast generation paths.
- [x] Add app verifier coverage for version/build metadata guards.
- [x] Run targeted invalid-version smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_release_prereqs.sh` now validates `CFBundleShortVersionString` with numeric `major.minor.patch` format and `CFBundleVersion` with numeric build format before deriving the expected release archive filename.
- `scripts/build_release.sh` now validates version/build metadata before deriving `ZIP_PATH`.
- `scripts/generate_appcast.sh` now validates effective `VERSION` and `BUILD` values before deriving archive and public download filename requirements.
- `scripts/verify_app.sh` now checks for version/build metadata guards in release prerequisite, release build, and appcast scripts.
- A temporary bad-plist smoke with `CFBundleShortVersionString=1/0/0` failed with `CFBundleShortVersionString must use numeric major.minor.patch format`.
- A temporary bad-plist smoke with `CFBundleVersion=1/2` failed with `CFBundleVersion must use numeric build format`.
- An appcast smoke with `VERSION=1/0/0` failed with `VERSION must use numeric major.minor.patch format`.
- An appcast smoke with `BUILD=1/2` failed with `BUILD must use numeric build format`.
- An appcast smoke with current valid metadata generated valid XML.
- `bash -n scripts/verify_release_prereqs.sh scripts/build_release.sh scripts/generate_appcast.sh scripts/verify_app.sh` passed.
- `scripts/verify_app.sh` passed after the release version metadata safety hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the release version metadata safety hardening change.

## Completion Audit Refresh 24

Current evidence on May 6, 2026:
- Release prerequisite, release build, and appcast scripts now validate version/build metadata before using those values in filenames or appcast metadata.
- Targeted invalid-version and invalid-build smokes fail in release prereqs and appcast generation.
- Current valid `1.0.0` / `1` metadata still generates valid appcast XML.
- `scripts/verify_app.sh` passed after adding version/build metadata safety coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, and version metadata verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Gatekeeper Assessment Prerequisite Hardening

Plan:
- [x] Require `spctl` in the release prerequisite command gate because `scripts/build_release.sh` uses it for Gatekeeper assessment after stapling.
- [x] Add app verifier coverage so release prereqs keep checking `spctl`.
- [x] Run script syntax, app verification, landing verification, release prerequisite audit, and `git diff --check`.

Evidence:
- `scripts/verify_release_prereqs.sh` now checks `spctl` before release work starts.
- `scripts/verify_app.sh` now checks that release prerequisites keep requiring `spctl` for Gatekeeper assessment.
- `bash -n scripts/verify_release_prereqs.sh scripts/verify_app.sh` passed.
- `scripts/verify_release_prereqs.sh` reported `[ok] command available: spctl` and still failed with the expected 11 missing production inputs.
- `scripts/verify_app.sh` passed after the Gatekeeper assessment prerequisite hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `git diff --check` passed after the Gatekeeper assessment prerequisite hardening change.

## Completion Audit Refresh 25

Current evidence on May 6, 2026:
- The release prerequisite gate now checks `spctl`, matching the Gatekeeper assessment step in `scripts/build_release.sh`.
- `scripts/verify_release_prereqs.sh` confirms `spctl` is available on this machine, then still fails on the expected external production inputs.
- `scripts/verify_app.sh` passed after adding `spctl` prerequisite coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, and Gatekeeper prerequisite verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Clean-Mac Driver Smoke Diagnostics Hardening

Plan:
- [x] Add explicit command preflight checks to `scripts/smoke_test_driver.sh`.
- [x] Replace terse install-path checks with actionable driver path diagnostics.
- [x] Add app verifier coverage for smoke-test diagnostics.
- [x] Run targeted smoke-script diagnostics plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/smoke_test_driver.sh` now uses `fail`, `require_command`, and `verify_install_path_present` helpers for consistent `[driver-smoke]` diagnostics.
- `--install`, `--verify`, and `--uninstall` now preflight the commands they need before touching driver state.
- The old bare `test -d "$INSTALL_PATH"` checks were replaced with `Driver bundle is not installed at $INSTALL_PATH` diagnostics.
- `scripts/verify_app.sh` now checks that the smoke script keeps command preflights, explicit install-path diagnostics, and the actionable missing-bundle message.
- `bash -n scripts/smoke_test_driver.sh` passed.
- `bash -n scripts/verify_app.sh` passed.
- `scripts/smoke_test_driver.sh --help` printed usage and exited 0.
- `scripts/smoke_test_driver.sh --verify` failed locally with `[driver-smoke] Missing audio input: SoundDeck Virtual Mic`; on this machine the driver bundle path exists, so the local failure path is the missing virtual input rather than the missing bundle path.
- `scripts/verify_app.sh` passed after the clean-Mac driver smoke diagnostics hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the clean-Mac driver smoke diagnostics hardening change.

## Completion Audit Refresh 26

Current evidence on May 6, 2026:
- The clean-Mac driver smoke script now fails with consistent actionable `[driver-smoke]` diagnostics for missing commands, missing driver bundle installation, missing virtual input, and uninstall leftovers.
- `scripts/verify_app.sh` passed after adding smoke-script diagnostics coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, and driver-smoke diagnostics verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Release Download Example Consistency Hardening

Plan:
- [x] Update root release environment examples to use the version/build-specific release archive filename.
- [x] Update landing environment examples to use the same release archive filename contract.
- [x] Add verifier coverage so README and `.env.example` download URLs cannot drift back to generic `SoundDeck.zip`.
- [x] Run targeted docs checks plus app, landing, release prerequisite, and diff checks.

Evidence:
- `README.md`, `landing/README.md`, and `landing/.env.example` now use `https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`.
- `scripts/verify_app.sh` now derives `SoundDeck-{CFBundleShortVersionString}-{CFBundleVersion}.zip` from `SoundDeckApp/Info.plist` and requires README, landing README, landing env example, and release docs to mention the current archive filename.
- `scripts/verify_app.sh` now fails if release environment examples regress to generic `SoundDeck.zip`.
- `bash -n scripts/verify_app.sh` passed.
- `rg -n "SoundDeck\\.zip" README.md landing/README.md landing/.env.example RELEASE.md` returned no matches.
- `rg -Fn "SoundDeck-1.0.0-1.zip" README.md landing/README.md landing/.env.example RELEASE.md` found the expected examples in all release docs/env files.
- `scripts/verify_app.sh` passed after the release download example consistency change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the release download example consistency change.

## Completion Audit Refresh 27

Current evidence on May 6, 2026:
- Release environment examples in root docs, landing docs, and `landing/.env.example` now match the version/build-specific archive filename enforced by the release prerequisite and appcast scripts.
- `scripts/verify_app.sh` passed after adding release download example consistency coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, and release example verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Release Zip URL Suffix Normalization Hardening

Plan:
- [x] Normalize download URLs before `.zip` suffix validation in `scripts/verify_release_prereqs.sh`.
- [x] Normalize download URLs before `.zip` suffix validation in `scripts/generate_appcast.sh`.
- [x] Add app verifier coverage so URL suffix validation keeps stripping query strings and fragments.
- [x] Run targeted query/fragment URL smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_release_prereqs.sh` now uses `url_path` to strip query strings and fragments before checking that `NEXT_PUBLIC_DOWNLOAD_URL` points to a `.zip` artifact.
- `scripts/generate_appcast.sh` now uses the same `url_path` normalization before checking that `DOWNLOAD_URL` or `NEXT_PUBLIC_DOWNLOAD_URL` points to a `.zip` artifact.
- `scripts/verify_app.sh` now checks that both release prerequisite and appcast zip URL validators use normalized URL paths.
- `bash -n scripts/verify_release_prereqs.sh scripts/generate_appcast.sh scripts/verify_app.sh` passed.
- A targeted release-prereq smoke with `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip#cdn` passed zip-artifact and filename validation, then failed only because the fake Developer ID signing identity is not installed.
- A targeted release-prereq smoke with `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.dmg#cdn` failed with `NEXT_PUBLIC_DOWNLOAD_URL must point to a .zip release artifact` and the expected filename mismatch.
- A targeted appcast smoke with `DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip#cdn` generated XML and passed `xmllint --noout`.
- A targeted appcast smoke with `DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.dmg#cdn` failed with `DOWNLOAD_URL or NEXT_PUBLIC_DOWNLOAD_URL must point to a .zip release artifact`.
- `scripts/verify_app.sh` passed after the release zip URL suffix normalization change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the release zip URL suffix normalization change.

## Completion Audit Refresh 28

Current evidence on May 6, 2026:
- Release prerequisite and appcast zip-artifact URL validation now normalizes public download URLs before checking the `.zip` suffix, matching the filename comparison behavior for signed/CDN URLs with queries or fragments.
- Targeted fragment-only `.zip` URL smokes pass the URL suffix gate, while fragment-only non-zip URLs still fail early.
- `scripts/verify_app.sh` passed after adding normalized zip URL validation coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, and normalized release URL validation remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Production HTTPS URL Shape Hardening

Plan:
- [x] Require production HTTPS URLs to include a non-empty host in `scripts/verify_release_prereqs.sh`.
- [x] Require production HTTPS URLs to include a non-empty host in `scripts/generate_appcast.sh`.
- [x] Add app verifier coverage for the shared non-empty host URL guard.
- [x] Run malformed URL smokes plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_release_prereqs.sh` now uses `is_https_url_with_host` so release URLs must be HTTPS and include a non-empty host.
- `scripts/generate_appcast.sh` now uses `is_https_url_with_host` for download and release-notes URL production checks.
- URL diagnostics now state that malformed values must be public HTTPS URLs with a non-empty host.
- `scripts/verify_app.sh` now checks that both release prerequisite and appcast scripts keep the non-empty host URL guard and diagnostics.
- `bash -n scripts/verify_release_prereqs.sh scripts/generate_appcast.sh scripts/verify_app.sh` passed.
- A targeted release-prereq smoke with `NEXT_PUBLIC_DOWNLOAD_URL=https:///downloads/SoundDeck-1.0.0-1.zip` failed with `NEXT_PUBLIC_DOWNLOAD_URL must be an https URL with a non-empty host`.
- A targeted appcast smoke with `DOWNLOAD_URL=https:///downloads/SoundDeck-1.0.0-1.zip` failed with `Set DOWNLOAD_URL or NEXT_PUBLIC_DOWNLOAD_URL to a public https URL with a non-empty host`.
- A targeted appcast smoke with `RELEASE_NOTES_URL=https:///changelog` failed with `Set RELEASE_NOTES_URL to a public https URL with a non-empty host`.
- `scripts/verify_app.sh` passed after the production HTTPS URL shape hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the production HTTPS URL shape hardening change.

## Completion Audit Refresh 29

Current evidence on May 6, 2026:
- Release prerequisite and appcast production URL validation now rejects malformed HTTPS values without hosts, instead of accepting any `https://` prefix.
- Targeted malformed URL smokes fail with explicit non-empty-host diagnostics.
- `scripts/verify_app.sh` passed after adding URL-shape verifier coverage.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, and production URL shape validation remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing SoftwareApplication Download URL Schema Hardening

Plan:
- [x] Wire homepage `SoftwareApplication.downloadUrl` to the configured `NEXT_PUBLIC_DOWNLOAD_URL` value.
- [x] Keep fallback behavior absolute and crawlable when no release artifact URL is configured.
- [x] Add landing verifier coverage so schema download URLs cannot drift back to a hardcoded `/download`.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/app/page.tsx` now sets `SoftwareApplication.downloadUrl` to `absoluteUrl(siteConfig.downloadUrl)` instead of hardcoding `absoluteUrl("/download")`.
- `absoluteUrl(siteConfig.downloadUrl)` keeps the no-env fallback crawlable as `https://sounddeck.app/download` while allowing production builds to emit the signed artifact URL.
- `scripts/verify_landing.sh` now checks rendered homepage JSON-LD for `downloadUrl`.
- `scripts/verify_landing.sh` now checks the source contract that `SoftwareApplication` schema uses `siteConfig.downloadUrl` and does not hardcode `/download` as the artifact URL.
- `bash -n scripts/verify_landing.sh` passed.
- `rg -n "downloadUrl: absoluteUrl\\(siteConfig\\.downloadUrl\\)|downloadUrl: absoluteUrl\\(\\\"/download\\\"\\)|assert_contains \\\"\\$home\\\" \\\"downloadUrl\\\"|environment-driven schema" landing/app/page.tsx scripts/verify_landing.sh` found the expected schema wiring and verifier coverage, with no hardcoded `/download` schema match.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- A production-env render smoke with `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip` built the landing site, started `next start`, fetched `/`, and confirmed the homepage JSON-LD contains the production artifact URL plus `downloadUrl`.
- `scripts/verify_app.sh` passed after the landing schema download URL hardening change.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the landing schema download URL hardening change.

## Completion Audit Refresh 30

Current evidence on May 6, 2026:
- Homepage `SoftwareApplication.downloadUrl` now follows the configured landing download URL, so production schema can point to the signed public artifact instead of only the `/download` page.
- The landing verifier now covers both rendered `downloadUrl` JSON-LD and the source-level env wiring contract.
- A production-env render smoke confirmed the built homepage contains `https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip` in JSON-LD when `NEXT_PUBLIC_DOWNLOAD_URL` is set.
- `scripts/verify_app.sh` passed after the schema hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, and placeholder regression checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, and landing schema download URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Version Metadata Drift Guard

Plan:
- [x] Derive the app release version from `SoundDeckApp/Info.plist` during landing verification.
- [x] Require landing `siteConfig.currentVersion` to match `CFBundleShortVersionString`.
- [x] Require the public changelog release version to match `CFBundleShortVersionString`.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_landing.sh` now reads `CFBundleShortVersionString` from `SoundDeckApp/Info.plist`.
- `scripts/verify_landing.sh` now requires rendered homepage JSON-LD to include `softwareVersion` and the current app version.
- `scripts/verify_landing.sh` now requires `landing/lib/site.ts` `currentVersion` to match the app plist version.
- `scripts/verify_landing.sh` now requires `landing/lib/content.ts` changelog version to match the app plist version.
- `bash -n scripts/verify_landing.sh` passed.
- A targeted source check found `currentVersion: "1.0.0"`, `version: "1.0.0"`, `softwareVersion`, and the new landing version metadata verifier guard.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_app.sh` passed after the landing version metadata drift guard change.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the landing version metadata drift guard change.

## Completion Audit Refresh 31

Current evidence on May 6, 2026:
- Landing version metadata is now verified against `SoundDeckApp/Info.plist` so public schema and changelog release version cannot silently drift from the app release version.
- The landing verifier checks rendered `softwareVersion`, `siteConfig.currentVersion`, and changelog version against `CFBundleShortVersionString`.
- `scripts/verify_app.sh` passed after the landing version metadata drift guard change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, placeholder regression checks, schema download URL wiring, and landing version metadata checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, and landing version metadata verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## App Verifier Source Version Drift Hardening

Plan:
- [x] Compare built app `CFBundleShortVersionString` against the source plist value instead of a hardcoded version.
- [x] Compare built app `CFBundleVersion` against the source plist build value.
- [x] Add verifier self-coverage so hardcoded app-version assertions do not return.
- [x] Run targeted verifier source checks plus app, landing, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_app.sh` now reuses source `DOC_APP_VERSION` and `DOC_APP_BUILD` values from `SoundDeckApp/Info.plist`.
- Built app verification now compares `CFBundleShortVersionString` to `$DOC_APP_VERSION` instead of the hardcoded `1.0.0`.
- Built app verification now compares `CFBundleVersion` to `$DOC_APP_BUILD`.
- `scripts/verify_app.sh` now checks its own source for the source-derived app version/build assertions and fails if the old hardcoded short-version assertion returns.
- `bash -n scripts/verify_app.sh` passed.
- `rg -n "CFBundleShortVersionString|CFBundleVersion|DOC_APP_VERSION|DOC_APP_BUILD|1\\.0\\.0" scripts/verify_app.sh` confirmed source-derived version/build checks and only the guard pattern references `1.0.0`.
- `scripts/verify_app.sh` passed after the app verifier source version drift hardening change.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the app verifier source version drift hardening change.

## Completion Audit Refresh 32

Current evidence on May 6, 2026:
- The app verifier now compares built app version/build metadata against `SoundDeckApp/Info.plist` instead of a hardcoded release version.
- Built app verification now covers both `CFBundleShortVersionString` and `CFBundleVersion`.
- `scripts/verify_app.sh` passed after adding source-derived version/build checks.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run verify` passed from `landing/`, including dependency audit, lint, production build, route checks, metadata/schema checks, crawl asset checks, placeholder regression checks, schema download URL wiring, and landing version metadata checks.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, landing version metadata verification, and source-derived app verifier version checks remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Production Env URL Render Verification And CTA Wiring

Plan:
- [x] Wire remaining primary download CTAs to `siteConfig.downloadUrl`.
- [x] Keep `/download` as the fallback URL when no signed artifact URL is configured.
- [x] Add optional landing verifier assertions for rendered `NEXT_PUBLIC_DOWNLOAD_URL` and `NEXT_PUBLIC_CHECKOUT_URL`.
- [x] Run default and production-env landing verification plus app, release prerequisite, and diff checks.

Evidence:
- `landing/components/Hero.tsx`, `landing/components/CTA.tsx`, and `landing/components/SiteHeader.tsx` now use `siteConfig.downloadUrl` for primary download CTAs.
- The fallback remains `/download` through `landing/lib/site.ts`, so local/no-env builds still route users to the download setup page.
- `scripts/verify_landing.sh` now asserts primary download CTAs use `siteConfig.downloadUrl` and rejects hardcoded `/download` in the hero, CTA band, and site header.
- `scripts/verify_landing.sh` now checks rendered homepage and download page output for `NEXT_PUBLIC_DOWNLOAD_URL` when it is set.
- `scripts/verify_landing.sh` now checks rendered homepage output for `NEXT_PUBLIC_CHECKOUT_URL` when it is set.
- The old download-page fallback notice assertion now only runs when `NEXT_PUBLIC_DOWNLOAD_URL` is not configured.
- `scripts/verify_landing.sh` now uses `mktemp "${TMPDIR:-/tmp}/sounddeck-landing.XXXXXX"` so log temp files are unique on macOS; a production-env verifier run exposed the old `/tmp/sounddeck-landing.XXXXXX.log` template collision.
- `bash -n scripts/verify_landing.sh` passed.
- A targeted source check found `href={siteConfig.downloadUrl}` in the hero, CTA band, and header download buttons, plus the new configured download/checkout URL verifier assertions.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`; it checked rendered configured download and checkout URLs.
- Default landing verification passed without production env vars, preserving the fallback download-page notice check.
- `scripts/verify_app.sh` passed after the landing production env URL render verification and CTA wiring change.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the landing production env URL render verification and CTA wiring change.

## Completion Audit Refresh 33

Current evidence on May 6, 2026:
- Primary landing download CTAs now honor `NEXT_PUBLIC_DOWNLOAD_URL` through `siteConfig.downloadUrl`, while no-env fallback still routes to `/download`.
- The landing verifier now covers both fallback and production-env rendering paths for download URLs, and production-env rendering for checkout URLs.
- A verifier temp-log portability issue found during production-env testing is fixed with a macOS-safe `mktemp` template.
- Production-env and default `npm run verify` runs both passed from `landing/`.
- `scripts/verify_app.sh` passed after the CTA/render verification change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Production Site URL Render Verification

Plan:
- [x] Derive expected crawl/canonical URLs in `scripts/verify_landing.sh` from `NEXT_PUBLIC_SITE_URL`.
- [x] Keep the default expected site URL as `https://sounddeck.app` when no env var is configured.
- [x] Verify rendered homepage, robots, and sitemap output use the configured site URL.
- [x] Run default and alternate-site-url landing verification plus app, release prerequisite, and diff checks.

Evidence:
- `scripts/verify_landing.sh` now derives `EXPECTED_SITE_URL` from `NEXT_PUBLIC_SITE_URL`, defaulting to `https://sounddeck.app`.
- `scripts/verify_landing.sh` strips a trailing slash from `EXPECTED_SITE_URL` before building expected crawl URLs.
- Homepage verification now checks the rendered page contains the expected canonical site URL.
- Robots verification now checks `Sitemap: ${EXPECTED_SITE_URL}/sitemap.xml`.
- Sitemap verification now checks `${EXPECTED_SITE_URL}/download` and `${EXPECTED_SITE_URL}/security`.
- `bash -n scripts/verify_landing.sh` passed.
- A targeted source check confirmed `EXPECTED_SITE_URL` is used for homepage, robots, and sitemap assertions, with no remaining hardcoded `sounddeck.app` crawl URL assertions in `scripts/verify_landing.sh`.
- Default landing verification passed without production env vars, preserving `https://sounddeck.app` crawl URL expectations.
- Alternate-site-url landing verification passed with `NEXT_PUBLIC_SITE_URL=https://launch.sounddeck.app`, proving homepage, robots, and sitemap output follow the configured site URL.
- `scripts/verify_app.sh` passed after the landing production site URL render verification change.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the landing production site URL render verification change.

## Completion Audit Refresh 34

Current evidence on May 6, 2026:
- Landing crawl/canonical verification now follows `NEXT_PUBLIC_SITE_URL` instead of hardcoded `https://sounddeck.app` assertions.
- Default and alternate-site-url landing verification runs both passed, covering the fallback production domain and a configured production-site URL.
- `scripts/verify_app.sh` passed after the site URL verifier change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Free Offer Schema Download URL Hardening

Plan:
- [x] Wire the `SoundDeck Free` JSON-LD offer URL to `siteConfig.downloadUrl`.
- [x] Keep the no-env fallback absolute and crawlable through `absoluteUrl(siteConfig.downloadUrl)`.
- [x] Add landing verifier coverage that both schema download fields use the configured download URL.
- [x] Run targeted, default landing, production-env landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/app/page.tsx` now sets the `SoundDeck Free` JSON-LD offer `url` to `absoluteUrl(siteConfig.downloadUrl)`.
- The schema `downloadUrl` and Free offer URL now both use the configured download URL, while no-env fallback remains absolute through `absoluteUrl("/download")`.
- `scripts/verify_landing.sh` now counts `absoluteUrl(siteConfig.downloadUrl)` references in `landing/app/page.tsx` and requires at least two, covering both schema download fields.
- `scripts/verify_landing.sh` now fails if schema URL fields hardcode `absoluteUrl("/download")`.
- `bash -n scripts/verify_landing.sh` passed.
- A targeted source check found two `absoluteUrl(siteConfig.downloadUrl)` schema references and no `absoluteUrl("/download")` schema URL reference.
- Default landing verification passed without production env vars.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the Free offer schema download URL hardening change.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the Free offer schema download URL hardening change.

## Completion Audit Refresh 35

Current evidence on May 6, 2026:
- Homepage SoftwareApplication schema now uses `siteConfig.downloadUrl` for both the top-level `downloadUrl` and the `SoundDeck Free` offer URL.
- Default and production-env landing verification runs both passed after the Free offer schema URL change.
- `scripts/verify_app.sh` passed after the schema URL consistency change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Mobile Upgrade CTA Parity

Plan:
- [x] Add an Upgrade to Pro CTA to the opened mobile navigation.
- [x] Keep the mobile Download CTA wired to `siteConfig.downloadUrl`.
- [x] Add landing verifier coverage so mobile navigation has both download and checkout actions.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/components/SiteHeader.tsx` now includes an `Upgrade to Pro` CTA in the opened mobile navigation.
- The mobile Download CTA remains wired to `siteConfig.downloadUrl`; the mobile Upgrade CTA is wired to `siteConfig.checkoutUrl`.
- `scripts/verify_landing.sh` now requires `SiteHeader` to expose configured download URLs in both desktop and mobile navigation.
- `scripts/verify_landing.sh` now requires `SiteHeader` to expose configured checkout URLs in both desktop and mobile navigation.
- `scripts/verify_landing.sh` now requires the mobile `Upgrade to Pro` CTA text.
- `bash -n scripts/verify_landing.sh` passed.
- A targeted source check found two `href={siteConfig.downloadUrl}` references, two `href={siteConfig.checkoutUrl}` references, the `Upgrade to Pro` CTA, and the new mobile navigation verifier guards.
- Default landing verification passed without production env vars.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the landing mobile Upgrade CTA parity change.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the landing mobile Upgrade CTA parity change.

## Completion Audit Refresh 36

Current evidence on May 6, 2026:
- Mobile navigation now has conversion parity with desktop navigation: Download and Upgrade actions are both available and wired through production env URL config.
- The landing verifier now checks desktop/mobile header download and checkout URL parity at the source level.
- Default and production-env landing verification runs both passed after the mobile nav change.
- `scripts/verify_app.sh` passed after the mobile CTA parity change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, mobile navigation conversion parity, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Product Mockup Accessibility And Interaction Polish

Plan:
- [x] Make product mockup folder controls update selected state instead of behaving as inert buttons.
- [x] Expose selected folder and active pad state with `aria-pressed`.
- [x] Make the mockup Stop All control clear the active pad preview.
- [x] Add landing verifier coverage for the mockup interaction/accessibility contract.
- [x] Run landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/components/ProductMockup.tsx` now tracks `selectedFolder` and updates it when folder controls are clicked.
- Product mockup folder controls now expose `aria-pressed={item === selectedFolder}`.
- Product mockup sound pads now expose `aria-pressed={active === pad.label}`.
- The Stop All control now has `aria-label="Stop all active sound previews"` and clears the active pad preview with `setActive("")`.
- The route preview now shows `No SFX armed` when Stop All clears the active sound.
- `scripts/verify_landing.sh` now checks for selected folder state, folder `aria-pressed`, pad `aria-pressed`, Stop All clearing behavior, and the stopped route state.
- `bash -n scripts/verify_landing.sh` passed.
- A targeted source check found `selectedFolder`, `aria-pressed`, `setActive("")`, `No SFX armed`, and the new ProductMockup verifier guards.
- Default landing verification passed without production env vars.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the product mockup accessibility and interaction polish change.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the product mockup accessibility and interaction polish change.

## Completion Audit Refresh 37

Current evidence on May 6, 2026:
- The landing product mockup now has functional folder selection, accessible pressed states for folder and pad controls, and a working Stop All preview state.
- The landing verifier now covers the product mockup interaction/accessibility contract.
- Default and production-env landing verification runs both passed after the product mockup accessibility change.
- `scripts/verify_app.sh` passed after the product mockup accessibility change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, mobile navigation conversion parity, product mockup accessibility, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Support SearchAction Fulfillment

Plan:
- [x] Make the `/support?q=...` target advertised by homepage WebSite `SearchAction` actually filter support content.
- [x] Add an accessible support search form with clear fallback content when no query is provided.
- [x] Preserve crawlable support topics and FAQ content on the default support page.
- [x] Add landing verifier coverage for the rendered query route and SearchAction contract.
- [x] Run landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/app/support/page.tsx` now reads `searchParams`, normalizes `q`, and filters support topics and FAQ entries for `/support?q=...`.
- The support page now exposes a `role="search"` form with a visible label, `type="search"` input, `aria-describedby` helper text, and a clear-search link after a query.
- Default `/support` keeps the crawlable setup guide, common fixes, and launch FAQ content visible when no query is provided.
- `scripts/verify_landing.sh` now verifies homepage `SearchAction`, `/support?q={search_term_string}`, default support content, rendered `/support?q=driver` results, and source-level support search guards.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `searchParams`, `role="search"`, `filteredTopics`, `filteredFaqs`, `SearchAction`, `support?q`, and the support search verifier assertions.
- Default landing verification passed without production env vars; `/support` is now a dynamic route, which is expected for query-backed server rendering.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the support SearchAction fulfillment change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- `git diff --check` passed after the support SearchAction fulfillment change.

## Completion Audit Refresh 38

Current evidence on May 6, 2026:
- Homepage WebSite `SearchAction` now points at a real server-rendered `/support?q=...` search path that filters support fixes and FAQ content.
- The support page has an accessible search form, query result messaging, a clear-search path, and default crawlable content when no query is present.
- The landing verifier now covers the SearchAction schema contract, default support content, and rendered support query filtering.
- Default and production-env landing verification runs both passed after the support search change.
- `scripts/verify_app.sh` passed after the support search change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.
- `git diff --check` passed on the current tree.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Site URL Normalization

Plan:
- [x] Normalize `NEXT_PUBLIC_SITE_URL` once so trailing slashes, paths, query strings, and hashes cannot leak into canonical public URLs.
- [x] Use the parsed site host for `robots.txt` instead of emitting a scheme-qualified Host value.
- [x] Build WebSite `SearchAction` from `absoluteUrl("/support")` so the support query target cannot double-slash.
- [x] Add landing verifier coverage for normalized source contracts and rendered trailing-slash production env output.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/lib/site.ts` now normalizes the configured site URL to an origin-only value and exports `siteHost` from the parsed URL.
- `landing/lib/site.ts` now builds `absoluteUrl()` with a slash-terminated normalized base, so relative paths stay stable.
- `landing/app/robots.ts` now emits `host: siteHost` instead of `host: siteConfig.url`.
- `landing/app/page.tsx` now builds the WebSite `SearchAction` target with `${absoluteUrl("/support")}?q={search_term_string}` instead of concatenating `siteConfig.url`.
- `scripts/verify_landing.sh` now normalizes its expected site URL with Node, checks the full rendered SearchAction URL, checks `Host: sounddeck.app`, rejects scheme-qualified `Host:` values, and source-checks `normalizeSiteUrl`, `siteHost`, `host: siteHost`, and the `absoluteUrl("/support")` SearchAction contract.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `normalizeSiteUrl`, `siteHost`, `absoluteUrl("/support")`, the normalized expected site URL calculation, and the rendered robots host verifier.
- `git diff --check` passed after the source and verifier edits.
- Default landing verification passed without production env vars.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app/`, proving trailing-slash normalization.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app/launch?utm=local#hero`, proving path, query, and hash stripping in rendered public output.
- `scripts/verify_app.sh` passed after the landing site URL normalization change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 39

Current evidence on May 6, 2026:
- Landing site URL handling now normalizes the configured public site URL before canonical URLs, schema, sitemap, and robots output consume it.
- `robots.txt` now emits a host name instead of a scheme-qualified URL, and the verifier rejects regressions.
- WebSite `SearchAction` now uses the shared absolute URL helper for `/support?q=...`, avoiding raw string concatenation and double-slash risks.
- Default landing verification passed, plus production-env landing verification passed for both trailing-slash and path/query/hash site URL variants.
- `scripts/verify_app.sh` passed after the URL normalization change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, site URL normalization, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Changelog RSS Feed

Plan:
- [x] Add a machine-readable `/feed.xml` route generated from the same changelog content as the public changelog page.
- [x] Add feed discovery metadata and a footer link so browsers, crawlers, and release watchers can find it.
- [x] Add stable changelog anchors that match the feed item links.
- [x] Add landing verifier coverage for route availability, content type, rendered feed content, and source contract.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/app/feed.xml/route.ts` now generates a static RSS 2.0 feed from the shared `changelog` data.
- `landing/lib/content.ts` now exposes `releaseAnchor(version)` so the changelog page and RSS feed share stable version anchors.
- `landing/app/changelog/page.tsx` now adds `id={releaseAnchor(release.version)}` to each release article.
- `landing/app/layout.tsx` now advertises `/feed.xml` through alternate type metadata, and `landing/components/Footer.tsx` links to the RSS feed.
- `scripts/verify_landing.sh` now treats `/feed.xml` as a public route, verifies `application/rss+xml`, checks the feed body for RSS 2.0, atom self-link, the `SoundDeck 1.0.0` item, the `#v1-0-0` changelog link, and release-note content, and source-checks the shared feed/changelog contract.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `releaseAnchor`, `/feed.xml`, `application/rss+xml`, `const items = changelog`, `atom:link`, `RSS feed`, `v1-0-0`, and the feed header verifier.
- `git diff --check` passed after the source and verifier edits.
- Default landing verification passed without production env vars; Next built `/feed.xml` as a static route and the production server returned HTTP 200 for it.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the changelog RSS feed change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 40

Current evidence on May 6, 2026:
- The public changelog now has a machine-readable `/feed.xml` RSS route generated from the same source data as the visible changelog page.
- Feed discovery is exposed through page metadata and the footer search-assets links.
- RSS item links now resolve to stable changelog section anchors.
- The landing verifier now covers the feed route, content type, feed body, source data contract, and discovery links.
- Default and production-env landing verification runs both passed after the RSS feed change.
- `scripts/verify_app.sh` passed after the RSS feed change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, site URL normalization, changelog RSS feed, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Security.txt Discovery

Plan:
- [x] Add a `/.well-known/security.txt` route for security disclosure discovery.
- [x] Point the file at the existing support contact and public security policy page.
- [x] Include canonical, preferred language, and expiration metadata.
- [x] Add landing verifier coverage for route availability, text/plain content type, rendered body, and source contract.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/app/.well-known/security.txt/route.ts` now serves a static `text/plain` security contact file.
- The file renders `Contact: mailto:support@sounddeck.app`, `Expires: 2027-05-06T00:00:00.000Z`, `Preferred-Languages: en`, a canonical `/.well-known/security.txt` URL, and a `Policy: /security` URL from the normalized site URL helper.
- `landing/components/Footer.tsx` now links to `/.well-known/security.txt` in the search-assets column.
- `scripts/verify_landing.sh` now treats `/.well-known/security.txt` as a public route, verifies `text/plain`, checks the rendered contact, expiration, language, canonical, and policy fields, and source-checks the support-email/absolute-URL contract.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `security.txt`, contact, expiration, preferred language, canonical, policy, `text/plain`, and `.well-known` verifier coverage.
- `git diff --check` passed after the source and verifier edits.
- Default landing verification passed without production env vars; Next built `/.well-known/security.txt` as a static route and the production server returned HTTP 200 for it.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the security.txt discovery change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 41

Current evidence on May 6, 2026:
- The landing site now exposes `/.well-known/security.txt` for standard security disclosure discovery.
- `security.txt` points reporters to the public support contact and the existing `/security` policy page.
- The landing verifier now covers the `security.txt` route, content type, rendered fields, footer discovery link, and source-level helper usage.
- Default and production-env landing verification runs both passed after the security.txt change.
- `scripts/verify_app.sh` passed after the security.txt change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, site URL normalization, changelog RSS feed, security.txt discovery, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing HTTP Security Headers

Plan:
- [x] Add production HTTP security headers through `landing/next.config.ts`.
- [x] Cover content sniffing, referrer leakage, clickjacking, HSTS, browser feature permissions, and baseline CSP.
- [x] Document the headers in the landing README launch assets.
- [x] Add landing verifier coverage for rendered response headers and source-level header names.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/next.config.ts` now applies security headers to `/:path*`.
- The header set includes `Content-Security-Policy`, `Referrer-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`, and `Permissions-Policy`.
- The CSP blocks framing with `frame-ancestors 'none'`, limits default/base/form/object/image/font/style/script/connect/manifest sources, and keeps the current Next runtime functional.
- The Permissions-Policy disables browser camera, microphone, geolocation, payment, and USB access on the marketing site.
- `landing/README.md` now documents launch security headers in the launch assets section.
- `scripts/verify_landing.sh` now captures homepage response headers from the production server, checks each rendered security header, and source-checks `next.config.ts` for the required header names and CSP/Permissions-Policy clauses.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found the security header names, `frame-ancestors 'none'`, `microphone=()`, `async headers()`, README documentation, and verifier header assertions.
- `git diff --check` passed after the source and verifier edits.
- Default landing verification passed without production env vars; the production server returned the expected security headers.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the HTTP security header change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 42

Current evidence on May 6, 2026:
- The landing site now applies launch-grade browser security headers through Next response headers.
- The landing verifier now proves those headers are present in the served production homepage and that `next.config.ts` retains the required source contract.
- Landing README launch assets now document the security header coverage.
- Default and production-env landing verification runs both passed after the HTTP security header change.
- `scripts/verify_app.sh` passed after the HTTP security header change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## App Support Diagnostics Copy

Plan:
- [x] Add a Copy Diagnostics action to the in-app Support sheet.
- [x] Include app version, macOS, plan, driver, microphone permission, audio engine, monitoring, sound counts, folder count, and selected device IDs.
- [x] Copy diagnostics to the macOS pasteboard with user-visible success/failure feedback.
- [x] Add app verifier source coverage for the diagnostics payload and pasteboard action.
- [x] Run targeted source checks plus app, landing, release prerequisite, and diff checks.

Evidence:
- `SoundDeckApp/Views/SupportView.swift` now shows microphone permission in System Info and adds a `Copy Diagnostics` action.
- The support diagnostics payload includes app version, macOS, plan, driver status, microphone permission, audio engine status, muted state, monitor states, voice changer state, sound count, custom sound count, folder count, and selected input/output device IDs.
- `SupportView` now copies the diagnostics payload to `NSPasteboard.general` and displays success or failure feedback.
- `scripts/verify_app.sh` now source-checks the support diagnostics action, pasteboard usage, diagnostics payload, microphone permission, custom sound count, selected input device ID, and copy feedback state.
- `bash -n scripts/verify_app.sh` passed after the verifier update.
- A targeted source check found `Copy Diagnostics`, `supportDiagnostics`, `NSPasteboard.general`, `diagnosticsStatusMessage`, `Microphone Permission`, `customSoundCount`, `selectedInputDeviceID`, and the app verifier diagnostics checks.
- `git diff --check` passed after the source and verifier edits.
- `scripts/verify_app.sh` passed after the support diagnostics copy change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- Default landing verification passed without production env vars.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 43

Current evidence on May 6, 2026:
- The in-app Support sheet now lets users copy a concise diagnostic payload for launch support emails.
- The app verifier now covers the support diagnostics source contract before building the macOS app.
- `scripts/verify_app.sh` passed after the support diagnostics change.
- Default and production-env landing verification runs both passed after the support diagnostics change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## App Prefilled Support Email

Plan:
- [x] Generate the in-app support email URL with `URLComponents`.
- [x] Prefill the subject with the SoundDeck app version.
- [x] Prefill the body with the same support diagnostics payload used by Copy Diagnostics.
- [x] Add app verifier source coverage for the diagnostic mailto payload.
- [x] Run targeted source checks plus app, landing, release prerequisite, and diff checks.

Evidence:
- `SoundDeckApp/Views/SupportView.swift` now opens `supportEmailURL` for the Email Support action instead of a bare `mailto:` URL.
- `supportEmailURL` is built with `URLComponents`, targets `support@sounddeck.app`, and adds `URLQueryItem` values for subject and body.
- The support email subject includes the app version as `SoundDeck Support - v{appVersion}`.
- The support email body includes a short prompt plus the same `supportDiagnostics` payload used by Copy Diagnostics.
- `scripts/verify_app.sh` now source-checks the support email URL helper, `URLComponents`, versioned subject, body query item, diagnostics interpolation, and rejects the old bare support `mailto:` URL.
- `bash -n scripts/verify_app.sh` passed after the verifier update.
- A targeted source check found `supportEmailURL`, `URLComponents`, `URLQueryItem`, `SoundDeck Support`, the body query item, `supportDiagnostics`, and the app verifier mailto guards.
- `git diff --check` passed after the source and verifier edits.
- `scripts/verify_app.sh` passed after the prefilled support email change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- Default landing verification passed without production env vars.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 44

Current evidence on May 6, 2026:
- The in-app Email Support action now opens a versioned, diagnostic-prefilled message through a URLComponents-built mailto URL.
- The support diagnostics payload is reusable for both Copy Diagnostics and Email Support.
- The app verifier now covers the prefilled support email source contract before building the macOS app.
- `scripts/verify_app.sh` passed after the prefilled support email change.
- Default and production-env landing verification runs both passed after the prefilled support email change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Web App Manifest

Plan:
- [x] Add a `/manifest.webmanifest` route with SoundDeck app identity, description, colors, categories, and icon references.
- [x] Advertise the manifest from root metadata.
- [x] Add viewport theme color and color-scheme metadata for mobile/browser UI.
- [x] Add landing verifier coverage for route availability, content type/body, rendered discovery link, and source contract.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/app/manifest.ts` now emits a Next `MetadataRoute.Manifest` at `/manifest.webmanifest`.
- The manifest includes SoundDeck name/short name, description, normalized `start_url` and `scope`, standalone display mode, background/theme colors, product categories, language, and favicon icon reference.
- `landing/app/layout.tsx` now advertises `manifest: "/manifest.webmanifest"` and exports viewport theme color/color scheme metadata.
- `landing/README.md` now documents `app/manifest.ts` in the launch assets section.
- `scripts/verify_landing.sh` now treats `/manifest.webmanifest` as a public route, verifies `application/manifest+json`, checks the manifest identity, start URL, standalone display, theme color, categories, and icon URL, and source-checks the manifest/viewport contract.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `manifest.webmanifest`, `MetadataRoute.Manifest`, `themeColor`, viewport export, `start_url`, `display: "standalone"`, categories, manifest content-type checks, and manifest verifier assertions.
- The first default landing verifier run built `/manifest.webmanifest` successfully and exposed a brittle verifier regex for categories; after tightening the regex, `git diff --check` passed.
- Default landing verification passed without production env vars; Next built `/manifest.webmanifest` as a static route and the production server returned HTTP 200 for it.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the web app manifest change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 45

Current evidence on May 6, 2026:
- The landing site now exposes `/manifest.webmanifest` with launch identity, colors, categories, and icon reference.
- Homepage metadata now advertises the manifest and viewport theme metadata for browser/mobile presentation.
- The landing verifier now covers manifest route availability, rendered body, content type, discovery link, and source contract.
- Default and production-env landing verification runs both passed after the manifest change.
- `scripts/verify_app.sh` passed after the manifest change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Install Icon Assets

Plan:
- [x] Generate web PNG icon assets from the existing macOS `Resources/AppIcon.icns`.
- [x] Add 192x192, 512x512, and Apple touch icon assets under `landing/public`.
- [x] Wire the manifest to PNG icons instead of favicon-only install metadata.
- [x] Add Apple touch icon metadata in the root layout.
- [x] Add landing verifier coverage for icon routes, dimensions, content type, rendered metadata, and source contract.
- [x] Run targeted source/asset checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/public/icon-192.png`, `landing/public/icon-512.png`, and `landing/public/apple-touch-icon.png` were generated from `Resources/AppIcon.icns` with `sips`.
- `sips` verified the generated PNG dimensions: `icon-192.png` is 192x192, `icon-512.png` is 512x512, and `apple-touch-icon.png` is 180x180.
- `file` verified all three generated assets are PNG image data.
- `landing/app/manifest.ts` now references `/icon-192.png` and `/icon-512.png` as PNG install icons with `192x192` and `512x512` sizes.
- `landing/app/layout.tsx` now includes `apple: "/apple-touch-icon.png"` in root icon metadata.
- `scripts/verify_landing.sh` now checks the icon routes, image/png content type, local PNG dimensions via Node, rendered manifest PNG icon URLs/sizes, Apple touch icon metadata, and rejects favicon-only manifest install icons.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source and asset check found the icon paths, PNG dimension verifier, Apple touch icon metadata, manifest icon sizes, and local PNG dimensions.
- The first default landing verifier run built and served all icon routes, then exposed a case-sensitive static-file header assertion; after switching the PNG header checks to the case-insensitive header assertion, `git diff --check` passed.
- Default landing verification passed without production env vars; the production server returned HTTP 200 for `/icon-192.png`, `/icon-512.png`, and `/apple-touch-icon.png`.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the install icon asset change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 46

Current evidence on May 6, 2026:
- The landing manifest now uses proper 192x192 and 512x512 PNG install icons derived from the SoundDeck macOS app icon.
- Root metadata now exposes a 180x180 Apple touch icon.
- The landing verifier now covers public icon routes, content types, local PNG dimensions, rendered manifest icon URLs/sizes, Apple touch icon discovery, and favicon-only manifest regression.
- Default and production-env landing verification runs both passed after the install icon asset change.
- `scripts/verify_app.sh` passed after the install icon asset change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing OpenSearch Descriptor

Plan:
- [x] Add an `/opensearch.xml` route that exposes the existing `/support?q=...` search endpoint.
- [x] Add a root `rel="search"` discovery link for browsers and crawlers.
- [x] Generate the descriptor from normalized `siteConfig` URLs and support email.
- [x] Add landing verifier coverage for route availability, content type, rendered XML, homepage discovery, and source contract.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/app/opensearch.xml/route.ts` now serves a static OpenSearch 1.1 descriptor for SoundDeck support search.
- The descriptor includes `ShortName`, `LongName`, `Description`, `Contact`, UTF-8 input encoding, favicon image, and a `Url` template targeting the existing normalized `/support?q={searchTerms}` endpoint.
- `landing/app/layout.tsx` now includes a `rel="search"` discovery link for `/opensearch.xml`.
- `scripts/verify_landing.sh` now treats `/opensearch.xml` as a public route, verifies `application/opensearchdescription+xml`, checks the descriptor XML/body fields, checks homepage discovery, and source-checks the OpenSearch route/discovery contract.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `opensearch.xml`, `OpenSearch`, `rel="search"`, `application/opensearchdescription+xml`, `searchTerms`, `Support Search`, `siteConfig.supportEmail`, and the `absoluteUrl("/support")` template source.
- `git diff --check` passed after the source and verifier edits.
- Default landing verification passed without production env vars; Next built `/opensearch.xml` as a static route and the production server returned HTTP 200 for it.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the OpenSearch descriptor change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 47

Current evidence on May 6, 2026:
- The landing site now exposes `/opensearch.xml` for browser/crawler support-search discovery.
- The OpenSearch descriptor reuses the existing `/support?q=...` search route and normalized site URL helper.
- Homepage markup now advertises the OpenSearch descriptor through a `rel="search"` link.
- The landing verifier now covers route availability, content type, XML body, support-search template, homepage discovery, and source contract.
- Default and production-env landing verification runs both passed after the OpenSearch change.
- `scripts/verify_app.sh` passed after the OpenSearch change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Prefilled Contact Emails

Plan:
- [x] Add centralized landing mailto helpers that encode subject and body with `URLSearchParams`.
- [x] Use diagnostic-prefilled support links in the shared CTA, footer, and support page.
- [x] Use context-specific encoded subjects for privacy, terms, security disclosure, and press inquiries.
- [x] Add landing verifier coverage for rendered encoded mailto links and source contracts.
- [x] Run targeted source checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/lib/site.ts` now exposes `mailtoLink`, `supportMailtoLink`, `privacyMailtoLink`, `termsMailtoLink`, `securityDisclosureMailtoLink`, and `pressMailtoLink`.
- `mailtoLink` encodes subjects and bodies with `URLSearchParams` instead of hand-assembled query strings.
- The shared CTA, footer, and support page now use `supportMailtoLink()` so support requests include a request template with app/workflow, macOS version, SoundDeck version, driver status, microphone permission, and selected devices.
- The privacy, terms, security, and press pages now use context-specific encoded subjects and body prompts.
- `scripts/verify_landing.sh` now fetches `/privacy`, `/terms`, `/security`, and `/press`, checks rendered encoded mailto subjects/bodies, source-checks all mailto helpers, and rejects old bare contact mailto hrefs in landing pages/components.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found the new mailto helpers, page imports/usages, security.txt contact exception, and verifier assertions.
- `git diff --check` passed after the mailto changes.
- Default landing verification passed without production env vars.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the landing mailto change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 48

Current evidence on May 6, 2026:
- Public landing support/contact links now open encoded, prefilled mailto messages instead of blank email drafts.
- The shared support template asks for app/workflow, macOS version, SoundDeck version, driver status, microphone permission, input device, and output device.
- Legal, security, and press contact routes have topic-specific subjects and body prompts.
- The landing verifier now covers rendered contact links and source-level helper usage before accepting the site.
- Default and production-env landing verification runs both passed after the prefilled contact email change.
- `scripts/verify_app.sh` passed after the prefilled contact email change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Contact Hub

Plan:
- [x] Add a dedicated `/contact` page that routes support, security, privacy, terms, and press inquiries.
- [x] Reuse the centralized prefilled mailto helpers for every contact action.
- [x] Link `/contact` from the primary navigation, mobile navigation, footer, and sitemap.
- [x] Add landing verifier route, rendered content, mailto, sitemap, and source-contract coverage.
- [x] Run targeted checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- Added `landing/app/contact/page.tsx` as a dedicated public contact hub for setup support, security reports, privacy questions, terms questions, and press inquiries.
- The contact page uses `supportMailtoLink`, `securityDisclosureMailtoLink`, `privacyMailtoLink`, `termsMailtoLink`, and `pressMailtoLink` for all contact actions.
- The contact page includes `ContactPage` JSON-LD with customer support, security, and press contact points.
- `landing/components/SiteHeader.tsx` now includes `/contact` in desktop and mobile navigation.
- `landing/components/Footer.tsx` now links `/contact` in the Company column.
- `landing/app/sitemap.ts` now includes `/contact`.
- `scripts/verify_landing.sh` now requires `/contact` to return HTTP 200, appear in the sitemap and homepage navigation, render the expected contact categories, render `ContactPage` structured data, and use every prefilled contact mailto helper.
- `bash -n scripts/verify_landing.sh` passed after the contact route verifier update.
- A targeted source check found `/contact`, `ContactPage`, all contact mailto helpers, sitemap inclusion, navigation links, and verifier assertions.
- `git diff --check` passed after the contact hub changes.
- Default landing verification passed without production env vars and prerendered `/contact`.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the contact hub change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 49

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/contact` page for support, security, privacy, terms, and press inquiries.
- `/contact` is linked from the primary navigation, mobile navigation, footer, and sitemap.
- `/contact` exposes `ContactPage` structured data and reuses the centralized prefilled contact email helpers.
- The landing verifier now covers `/contact` route availability, rendered content, structured data, sitemap inclusion, navigation discovery, helper usage, and rendered mailto links.
- Default and production-env landing verification runs both passed after the contact hub change.
- `scripts/verify_app.sh` passed after the contact hub change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing llms.txt Contact Discovery

Plan:
- [x] Add the `/contact` route to `llms.txt` core pages.
- [x] Add verifier coverage so AI-facing crawl guidance includes the contact hub.
- [x] Run targeted checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/public/llms.txt` now lists `/contact` under Core Pages and describes it as direct routes for support, security, privacy, terms, and press inquiries.
- `scripts/verify_landing.sh` now checks the served `llms.txt` for `https://sounddeck.app/contact` and the contact-hub inquiry description.
- `bash -n scripts/verify_landing.sh` passed after the `llms.txt` verifier update.
- A targeted source check found the `/contact` `llms.txt` entry and verifier assertions.
- `git diff --check` passed after the `llms.txt` changes.
- Default landing verification passed without production env vars and verified the served `llms.txt` contact entry.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the `llms.txt` change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 50

Current evidence on May 6, 2026:
- The AI-facing `llms.txt` crawl guide now includes the new `/contact` page and its inquiry routing purpose.
- The landing verifier now requires the served `llms.txt` to expose the contact hub.
- Default and production-env landing verification runs both passed after the `llms.txt` contact-discovery change.
- `scripts/verify_app.sh` passed after the `llms.txt` contact-discovery change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Compatibility Page

Plan:
- [x] Add shared app-specific compatibility details for major meeting, streaming, recording, and browser targets.
- [x] Add a dedicated `/compatibility` public page with setup notes, structured data, and troubleshooting guidance.
- [x] Link `/compatibility` from navigation, footer, sitemap, `llms.txt`, and the homepage compatibility section.
- [x] Add landing verifier route, rendered content, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run targeted checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/lib/content.ts` now exports `compatibilityDetails` with app-specific setup notes for Zoom, Discord, Google Meet, Microsoft Teams, FaceTime, Slack Huddles, OBS, Riverside, Chrome/Safari/Firefox, and any app with a microphone picker.
- Added `landing/app/compatibility/page.tsx` as a dedicated public compatibility page with setup guidance, troubleshooting notes, a prefilled support CTA, and a link to the getting started guide.
- The compatibility page includes `CollectionPage`, `BreadcrumbList`, and `ItemList` JSON-LD generated from the shared compatibility detail data.
- `landing/components/SiteHeader.tsx` now links Compatibility to `/compatibility` instead of only the homepage section anchor.
- `landing/components/Screenshots.tsx` now links the homepage compatibility panel to `/compatibility` with "See app setup notes".
- `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, and `landing/public/llms.txt` now link or list `/compatibility`.
- `scripts/verify_landing.sh` now requires `/compatibility` to return HTTP 200, checks rendered app notes and structured data, checks homepage/sitemap/llms discovery, and source-checks the shared `compatibilityDetails` contract.
- `bash -n scripts/verify_landing.sh` passed after the compatibility verifier update.
- A targeted source check found `/compatibility`, `compatibilityDetails`, `CollectionPage`, `ItemList`, the homepage setup-notes CTA, sitemap inclusion, `llms.txt` inclusion, and verifier assertions.
- `git diff --check` passed after the compatibility page changes.
- Default landing verification passed without production env vars and prerendered `/compatibility`.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the compatibility page change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 51

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/compatibility` page with app-specific setup notes for meeting, streaming, recording, browser, and general microphone-picker workflows.
- `/compatibility` is linked from primary navigation, mobile navigation, footer, sitemap, `llms.txt`, and the homepage compatibility section.
- `/compatibility` exposes `CollectionPage`, `BreadcrumbList`, and `ItemList` structured data backed by shared compatibility content.
- The landing verifier now covers `/compatibility` route availability, rendered app notes, structured data, sitemap inclusion, AI crawl guidance, homepage discovery, and source-level content contracts.
- Default and production-env landing verification runs both passed after the compatibility page change.
- `scripts/verify_app.sh` passed after the compatibility page change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Pricing Page

Plan:
- [x] Move Free and Pro feature lists plus pricing FAQs into shared landing content.
- [x] Add a dedicated `/pricing` page with Free vs Pro details, support guidance, and configured download/checkout CTAs.
- [x] Add pricing offer and FAQ structured data for search and AI answer engines.
- [x] Link `/pricing` from navigation, footer, sitemap, `llms.txt`, and the homepage pricing section.
- [x] Add landing verifier route, rendered content, configured URL, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run targeted checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/lib/content.ts` now exports `freePlanFeatures`, `proPlanFeatures`, and `pricingFaqs` for shared pricing content.
- `landing/components/Pricing.tsx` now renders the homepage pricing cards from the shared feature lists and links to `/pricing` with "Compare plans".
- Added `landing/app/pricing/page.tsx` as a dedicated public pricing page with Free and SoundDeck Pro cards, download/checkout CTAs, setup guidance, billing/refund support guidance, and pricing FAQs.
- The pricing page includes `BreadcrumbList`, `Product`, `Offer`, and `FAQPage` JSON-LD; Free offer URLs use `absoluteUrl(siteConfig.downloadUrl)` and Pro offer/CTA URLs use `siteConfig.checkoutUrl`.
- `landing/components/Hero.tsx`, `landing/components/SiteHeader.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, and `landing/public/llms.txt` now link or list `/pricing`.
- `landing/app/globals.css` now adds spacing between stacked buttons in pricing/info panels.
- `scripts/verify_landing.sh` now requires `/pricing` to return HTTP 200, checks rendered Free/Pro pricing content, structured data, support CTA, configured download/checkout URLs, homepage discovery, sitemap inclusion, `llms.txt` inclusion, and source-level pricing contracts.
- `bash -n scripts/verify_landing.sh` passed after the pricing verifier update.
- A targeted source check found `/pricing`, shared pricing content exports/usages, pricing page structured data, homepage "Compare plans", sitemap inclusion, `llms.txt` inclusion, and verifier assertions.
- The first default landing verifier run exposed a brittle rendered monthly price assertion because Next split the interpolated price with HTML comments; the verifier now checks the stable `$4.99` and `/mo in app` fragments.
- `git diff --check` passed after the pricing page changes.
- Default landing verification passed without production env vars and prerendered `/pricing`.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the pricing page change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 52

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/pricing` page with Free vs Pro plan details, pricing FAQs, setup guidance, billing support, and environment-driven download/checkout CTAs.
- `/pricing` is linked from the hero, homepage pricing section, primary navigation, mobile navigation, footer, sitemap, and `llms.txt`.
- `/pricing` exposes `Product`, `Offer`, `BreadcrumbList`, and `FAQPage` structured data backed by shared pricing content and configured URL helpers.
- The landing verifier now covers `/pricing` route availability, rendered pricing content, structured data, configured URL rendering, sitemap inclusion, AI crawl guidance, homepage discovery, and source-level content contracts.
- Default and production-env landing verification runs both passed after the pricing page change.
- `scripts/verify_app.sh` passed after the pricing page change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, landing pricing page, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Use Cases Page

Plan:
- [x] Expand shared use-case content with workflow, fit, and setup guidance.
- [x] Add a dedicated `/use-cases` page with meeting, streaming, podcast, and workshop scenarios plus structured data.
- [x] Link `/use-cases` from homepage, navigation, footer, sitemap, and `llms.txt`.
- [x] Add landing verifier route, rendered content, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run targeted checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/lib/content.ts` now expands each use case with workflow, best-fit, and setup guidance.
- Added `landing/app/use-cases/page.tsx` as a dedicated public use-cases page for remote meetings, streams/live shows, podcasts/interviews, and classes/workshops.
- The use-cases page includes `CollectionPage`, `BreadcrumbList`, and `ItemList` JSON-LD generated from shared `useCases` content.
- `landing/components/Testimonials.tsx` now links the homepage use-case section to `/use-cases` with an "Explore use cases" CTA.
- `landing/app/globals.css` now adds `.section-actions` styling for the homepage use-case CTA.
- `landing/components/SiteHeader.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, and `landing/public/llms.txt` now link or list `/use-cases`.
- `scripts/verify_landing.sh` now requires `/use-cases` to return HTTP 200, checks rendered use-case content and structured data, checks homepage/sitemap/llms discovery, and source-checks use-case workflow/setup content contracts.
- `bash -n scripts/verify_landing.sh` passed after the use-cases verifier update.
- A targeted source check found `/use-cases`, workflow/best-fit/setup guidance, `SoundDeck live audio use cases`, homepage "Explore use cases", sitemap inclusion, `llms.txt` inclusion, and verifier assertions.
- `git diff --check` passed after the use-cases page changes.
- Default landing verification passed without production env vars and prerendered `/use-cases`.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the use-cases page change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 53

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/use-cases` page with workflow, fit, and setup guidance for meetings, streams, podcasts/interviews, and classes/workshops.
- `/use-cases` is linked from the homepage use-case section, primary navigation, mobile navigation, footer, sitemap, and `llms.txt`.
- `/use-cases` exposes `CollectionPage`, `BreadcrumbList`, and `ItemList` structured data backed by shared use-case content.
- The landing verifier now covers `/use-cases` route availability, rendered use-case content, structured data, sitemap inclusion, AI crawl guidance, homepage discovery, and source-level content contracts.
- Default and production-env landing verification runs both passed after the use-cases page change.
- `scripts/verify_app.sh` passed after the use-cases page change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, landing pricing page, landing use-cases page, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Features Page

Plan:
- [x] Add a dedicated `/features` page with the shared product feature set and structured data.
- [x] Link `/features` from the homepage feature section, primary navigation, footer, sitemap, and `llms.txt`.
- [x] Add landing verifier route, rendered content, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run targeted checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- Added `landing/app/features/page.tsx` as a dedicated public features page rendered from shared `productFeatures` and `trustItems` content.
- The features page includes `CollectionPage`, `BreadcrumbList`, and `ItemList` JSON-LD generated from the shared product feature content.
- `landing/components/Features.tsx` now links the homepage feature section to `/features` with an "Explore features" CTA.
- `landing/components/SiteHeader.tsx` now links Features to `/features` instead of only the homepage section anchor.
- `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, and `landing/public/llms.txt` now link or list `/features`.
- `scripts/verify_landing.sh` now requires `/features` to return HTTP 200, checks rendered feature/trust content and structured data, checks homepage/sitemap/llms discovery, and source-checks shared feature content usage.
- `bash -n scripts/verify_landing.sh` passed after the features verifier update.
- A targeted source check found `/features`, `productFeatures.map`, `trustItems.map`, `SoundDeck feature set`, homepage "Explore features", sitemap inclusion, `llms.txt` inclusion, and verifier assertions.
- `git diff --check` passed after the features page changes.
- Default landing verification passed without production env vars and prerendered `/features`.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the features page change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 54

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/features` page with product feature and trust content backed by shared landing data.
- `/features` is linked from the homepage feature section, primary navigation, mobile navigation, footer, sitemap, and `llms.txt`.
- `/features` exposes `CollectionPage`, `BreadcrumbList`, and `ItemList` structured data backed by shared `productFeatures`.
- The landing verifier now covers `/features` route availability, rendered feature/trust content, structured data, sitemap inclusion, AI crawl guidance, homepage discovery, and source-level content contracts.
- Default and production-env landing verification runs both passed after the features page change.
- `scripts/verify_app.sh` passed after the features page change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, landing pricing page, landing use-cases page, landing features page, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Comparison Page

Plan:
- [x] Add shared comparison detail content for SoundDeck, web soundboards, hardware-only setups, and manual routing.
- [x] Add a dedicated `/compare` page with comparison table, decision guidance, and structured data.
- [x] Link `/compare` from the homepage comparison table, primary navigation, footer, sitemap, and `llms.txt`.
- [x] Add landing verifier route, rendered content, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run targeted checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- `landing/lib/content.ts` now exports `comparisonDetails` for SoundDeck, web soundboards, hardware-only setups, and manual routing.
- Added `landing/app/compare/page.tsx` as a dedicated public comparison page with the shared comparison table, detailed tradeoff cards, download CTA, and prefilled support CTA.
- The comparison page includes `CollectionPage`, `BreadcrumbList`, and `ItemList` JSON-LD generated from the shared comparison detail content.
- `landing/components/Screenshots.tsx` now links the homepage comparison table to `/compare` with a "Compare workflows" CTA.
- `landing/components/SiteHeader.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, and `landing/public/llms.txt` now link or list `/compare`.
- `scripts/verify_landing.sh` now requires `/compare` to return HTTP 200, checks rendered comparison table/detail content and structured data, checks homepage/sitemap/llms discovery, and source-checks shared comparison content usage.
- `bash -n scripts/verify_landing.sh` passed after the comparison verifier update.
- A targeted source check found `/compare`, `comparisonDetails`, `SoundDeck workflow comparison`, homepage "Compare workflows", manual routing content, sitemap inclusion, `llms.txt` inclusion, and verifier assertions.
- `git diff --check` passed after the comparison page changes.
- Default landing verification passed without production env vars and prerendered `/compare`.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the comparison page change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 55

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/compare` page comparing SoundDeck with web soundboards, hardware-only setups, and manual routing.
- `/compare` is linked from the homepage comparison table, primary navigation, mobile navigation, footer, sitemap, and `llms.txt`.
- `/compare` exposes `CollectionPage`, `BreadcrumbList`, and `ItemList` structured data backed by shared comparison content.
- The landing verifier now covers `/compare` route availability, rendered comparison content, structured data, sitemap inclusion, AI crawl guidance, homepage discovery, and source-level content contracts.
- Default and production-env landing verification runs both passed after the comparison page change.
- `scripts/verify_app.sh` passed after the comparison page change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, landing pricing page, landing use-cases page, landing features page, landing comparison page, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing FAQ Page

Plan:
- [x] Add a dedicated `/faq` page with shared FAQ content and `FAQPage` structured data.
- [x] Link `/faq` from the homepage FAQ section, footer, sitemap, and `llms.txt`.
- [x] Add landing verifier route, rendered content, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run targeted checks plus landing, app, release prerequisite, and diff checks.

Evidence:
- Added `landing/app/faq/page.tsx` as a dedicated public FAQ page rendered from shared `faqs` content.
- The FAQ page includes `BreadcrumbList` and `FAQPage` JSON-LD generated from the shared FAQ content.
- `landing/components/FAQ.tsx` now links the homepage FAQ section to `/faq` with a "Read all FAQs" CTA.
- `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, and `landing/public/llms.txt` now link or list `/faq`.
- `scripts/verify_landing.sh` now requires `/faq` to return HTTP 200, checks rendered FAQ content and structured data, checks homepage/sitemap/llms discovery, and source-checks shared FAQ content usage.
- `bash -n scripts/verify_landing.sh` passed after the FAQ verifier update.
- A targeted source check found `/faq`, `faqs.map`, `FAQPage`, homepage "Read all FAQs", support CTA, sitemap inclusion, `llms.txt` inclusion, and verifier assertions.
- `git diff --check` passed after the FAQ page changes.
- Default landing verification passed without production env vars and prerendered `/faq`.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the FAQ page change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 56

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/faq` page with crawlable setup, compatibility, privacy, pricing, uninstall, and support answers backed by shared FAQ content.
- `/faq` is linked from the homepage FAQ section, footer, sitemap, and `llms.txt`.
- `/faq` exposes `FAQPage` structured data backed by shared `faqs`.
- The landing verifier now covers `/faq` route availability, rendered FAQ content, structured data, sitemap inclusion, AI crawl guidance, homepage discovery, and source-level content contracts.
- Default and production-env landing verification runs both passed after the FAQ page change.
- `scripts/verify_app.sh` passed after the FAQ page change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Troubleshooting Guide

Plan:
- [x] Move common support fixes into shared landing content so `/support` and docs render the same source of truth.
- [x] Add a dedicated `/docs/troubleshooting` page with driver, virtual mic, microphone permission, routing, and uninstall recovery steps plus structured data.
- [x] Link `/docs/troubleshooting` from support, getting started, footer, sitemap, and `llms.txt`.
- [x] Add landing verifier route, rendered content, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, landing default, landing production-env, app verifier, and release prerequisite checks.

Evidence:
- `landing/lib/content.ts` now exports shared `supportTopics` with driver approval, virtual mic visibility, routing, microphone permission, and uninstall fixes plus step lists.
- `landing/app/support/page.tsx` now imports shared `supportTopics`, filters support search against topic steps, and links to `/docs/troubleshooting`.
- Added `landing/app/docs/troubleshooting/page.tsx` with `CollectionPage`, `BreadcrumbList`, `ItemList`, and `HowTo`/`HowToStep` JSON-LD for troubleshooting topics.
- `landing/app/docs/getting-started/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, and `landing/public/llms.txt` now link or list `/docs/troubleshooting`.
- `scripts/verify_landing.sh` now requires `/docs/troubleshooting` to return HTTP 200, checks rendered troubleshooting content and structured data, checks support/getting-started/home/footer discovery, checks sitemap and `llms.txt`, and source-checks shared topic contracts.
- `bash -n scripts/verify_landing.sh` passed after the troubleshooting verifier update.
- A targeted source check found `/docs/troubleshooting`, `supportTopics`, `HowTo`, `HowToStep`, "Driver install needs approval", "Open troubleshooting guide", and "SoundDeck troubleshooting topics" across landing source, verifier, and task evidence.
- `git diff --check` passed before and after the full verification run.
- Default landing verification passed without production env vars and prerendered `/docs/troubleshooting`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the troubleshooting docs change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 57

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/troubleshooting` page for driver approval, SoundDeck Virtual Mic visibility, sound routing, macOS microphone permission, and uninstall recovery.
- `/support` and `/docs/troubleshooting` now render from shared troubleshooting content, reducing support-doc drift.
- `/docs/troubleshooting` is linked from support, getting started, footer, sitemap, homepage footer output, and `llms.txt`.
- `/docs/troubleshooting` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, and `HowToStep` structured data backed by shared `supportTopics`.
- The landing verifier now covers `/docs/troubleshooting` route availability, rendered content, structured data, source contracts, sitemap inclusion, AI crawl guidance, and support/getting-started discovery.
- Default and production-env landing verification runs both passed after the troubleshooting page change.
- `scripts/verify_app.sh` passed after the troubleshooting page change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, clean-Mac driver validation, and Browser Use visual QA for the newest public docs page.

## Landing Hotkeys Guide

Plan:
- [x] Add Settings recorders for global mute, Stop All, and Pro voice changer hotkeys so registered handlers are user-configurable.
- [x] Add shared landing content for Free and Pro hotkey actions based on the app's `KeyboardShortcuts.Name` registrations and Pro gates.
- [x] Add a dedicated `/docs/hotkeys` page with setup, plan availability, conflict checks, and structured data.
- [x] Link `/docs/hotkeys` from features, pricing, getting started, footer, sitemap, and `llms.txt`.
- [x] Add landing verifier route, rendered content, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, landing default, landing production-env, app verifier, and release prerequisite checks.

Evidence:
- `SoundDeckApp/Views/SettingsView.swift` now exposes global hotkey recorders for Mute microphone and Stop all sounds, a Pro-gated Toggle voice changer recorder, and a separate Sound Pads subsection for per-sound Pro hotkeys.
- `scripts/verify_app.sh` now source-checks the global hotkey recorders, Pro voice changer gate, locked fallback row, and per-sound hotkey section before compiling the app.
- `landing/lib/content.ts` now exports `hotkeyActions` and `hotkeyConflictChecks` for Free and Pro shortcut behavior.
- Added `landing/app/docs/hotkeys/page.tsx` with Free/Pro hotkey guidance, per-sound setup, conflict checks, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, and `HowToStep` JSON-LD.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/features/page.tsx`, `landing/app/pricing/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, and `landing/public/llms.txt` now link or list `/docs/hotkeys`.
- `scripts/verify_landing.sh` now requires `/docs/hotkeys` to return HTTP 200, checks rendered hotkey content, structured data, shortcut names, conflict guidance, support CTA, source contracts, sitemap inclusion, and `llms.txt` AI crawl guidance.
- `bash -n scripts/verify_landing.sh scripts/verify_app.sh` passed after the hotkeys verifier update.
- A targeted source check found `/docs/hotkeys`, `hotkeyActions`, `hotkeyConflictChecks`, `globalMute`, `stopAll`, `toggleVoiceChanger`, "SoundDeck hotkeys guide", and "Email hotkey support" across landing source, app source, verifiers, and task evidence.
- `git diff --check` passed after the hotkeys guide changes.
- Default landing verification passed without production env vars and prerendered `/docs/hotkeys`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the Settings hotkey change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 58

Current evidence on May 6, 2026:
- The macOS app Settings panel now exposes configurable global hotkey recorders for Mute microphone and Stop all sounds, plus a Pro-gated voice changer recorder and per-sound Pro hotkey section.
- The landing site now has a dedicated `/docs/hotkeys` page explaining Free hotkeys, Pro hotkeys, per-sound behavior, shortcut conflicts, and support escalation.
- `/docs/hotkeys` is linked from getting started, features, pricing, footer, sitemap, homepage footer output, and `llms.txt`.
- `/docs/hotkeys` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, and `HowToStep` structured data backed by shared `hotkeyActions`.
- The landing verifier now covers `/docs/hotkeys` route availability, rendered content, structured data, source contracts, sitemap inclusion, AI crawl guidance, and internal discovery.
- The app verifier now covers the Settings hotkey recorder contracts in addition to compiling the updated macOS app.
- Default and production-env landing verification runs both passed after the hotkeys page change.
- `scripts/verify_app.sh` passed after the Settings hotkey change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, clean-Mac driver validation, and Browser Use visual QA for the newest public docs pages.

## Browser Use Docs Visual QA

Plan:
- [x] Start the built landing site locally on a fixed free port.
- [x] Attempt Browser Use against the new docs pages; fall back to local Playwright because the Browser Use Node REPL tool and Chrome DevTools transport were unavailable.
- [x] Check `/docs/troubleshooting` on desktop for visible layout, content hierarchy, links, and console errors.
- [x] Check `/docs/hotkeys` on desktop for visible layout, content hierarchy, links, and console errors.
- [x] Check responsive/mobile sizing and menu behavior for the new docs pages so buttons and panels do not overlap or overflow.
- [x] Fix any visual or interaction defects found, then rerun targeted verification.
- [x] Record visual QA evidence and update the completion audit.

Evidence:
- Local production server started on `http://127.0.0.1:4329`.
- Browser Use `iab` runtime could not be bootstrapped because the Node REPL JavaScript execution tool was not exposed after tool discovery.
- Chrome DevTools fallback was also unavailable because its transport closed on `new_page` and `list_pages`.
- Local Playwright fallback loaded `/docs/troubleshooting` and `/docs/hotkeys` at `1440x1000` desktop and `390x844` mobile.
- Playwright fallback screenshots were captured at `/tmp/sounddeck-browser-qa/troubleshooting-desktop.png`, `/tmp/sounddeck-browser-qa/hotkeys-desktop.png`, `/tmp/sounddeck-browser-qa/troubleshooting-mobile.png`, and `/tmp/sounddeck-browser-qa/hotkeys-mobile.png`.
- Desktop and mobile checks for both pages returned HTTP 200, expected document titles, expected `h1` text, expected `h2` hierarchy, footer docs links, no horizontal overflow, no offscreen interactive controls, no tiny buttons, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/hotkeys` opened successfully at `390x844`, showed expected navigation links and production CTA URLs, had no horizontal overflow, no offscreen interactive controls, no console warnings/errors, and no page errors.
- Screenshot review found the docs pages readable on desktop and mobile: cards stack correctly, CTAs fit, footer links remain visible, and mobile menu layout is coherent.
- No source changes were required after visual QA.

## Completion Audit Refresh 59

Current evidence on May 6, 2026:
- The newest docs pages now have fallback visual-browser evidence in addition to route, build, schema, and source-contract verification.
- `/docs/troubleshooting` and `/docs/hotkeys` both pass desktop and mobile browser checks for HTTP status, heading hierarchy, visible links, overflow, offscreen controls, and console/page errors.
- The mobile menu opens cleanly on the newest docs page and retains expected navigation and CTA links.
- Browser Use itself remains unavailable in this session due missing Node REPL execution and closed Chrome DevTools transport, but the same local-browser QA intent was covered by Playwright screenshots and runtime checks.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing compatibility page, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Docs Hub

Plan:
- [x] Add shared docs guide metadata for setup, troubleshooting, and hotkeys.
- [x] Add a dedicated `/docs` page that routes users to the right guide and exposes structured data.
- [x] Point the primary Docs navigation at `/docs` while preserving links to individual docs pages.
- [x] Add `/docs` to sitemap and `llms.txt`.
- [x] Extend the landing verifier with route, rendered content, structured data, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, release prerequisite, and final diff checks.

Evidence:
- `landing/lib/content.ts` now exports shared `docsGuides` metadata for Getting Started, Troubleshooting, and Hotkeys.
- Added `landing/app/docs/page.tsx` as a documentation hub with guide cards, clean setup guidance, support CTA, and `CollectionPage`, `BreadcrumbList`, and `ItemList` JSON-LD.
- `landing/components/SiteHeader.tsx` now points the primary Docs navigation item to `/docs`.
- `landing/components/Footer.tsx` now includes `/docs` plus direct links to Getting Started, Troubleshooting, and Hotkeys.
- `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now list `/docs`.
- `scripts/verify_landing.sh` now requires `/docs` to return HTTP 200, checks rendered docs hub content, structured data, guide links, support CTA, source contracts, sitemap inclusion, `llms.txt` AI crawl guidance, and README route documentation.
- `bash -n scripts/verify_landing.sh` passed after the docs hub verifier update.
- A targeted source check found `/docs`, `docsGuides`, `SoundDeck documentation guides`, `Email docs support`, and "Documentation hub for setup" across landing source, verifier, `llms.txt`, README, and task evidence.
- `git diff --check` passed after the docs hub changes.
- Default landing verification passed without production env vars and prerendered `/docs`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 60

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs` hub that routes users to setup, troubleshooting, and hotkeys documentation.
- The primary navigation Docs item now points to `/docs`, while the footer still exposes direct links to individual guides.
- `/docs` is included in sitemap, `llms.txt`, and landing README public page documentation.
- `/docs` exposes `CollectionPage`, `BreadcrumbList`, and `ItemList` structured data backed by shared `docsGuides`.
- The landing verifier now covers `/docs` route availability, rendered content, structured data, source contracts, sitemap inclusion, AI crawl guidance, homepage discovery, and README route docs.
- Default and production-env landing verification runs both passed after the docs hub change.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing App Setup Guides

Plan:
- [x] Add shared app-specific guide content for Zoom, Discord, Google Meet, Microsoft Teams, OBS, and Riverside.
- [x] Add a `/guides` hub with structured data and support routing.
- [x] Add static `/guides/[slug]` pages with app-specific setup steps, troubleshooting checks, and structured data.
- [x] Link app guides from compatibility, docs, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with guide route, rendered content, schema, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, and final diff checks.

Evidence:
- `landing/lib/content.ts` now exports shared `appGuides` content for Zoom, Discord, Google Meet, Microsoft Teams, OBS, and Riverside with setup steps, best-fit guidance, and troubleshooting checks.
- Added `landing/app/guides/page.tsx` as a public app setup guide hub with `CollectionPage`, `BreadcrumbList`, and `ItemList` JSON-LD.
- Added `landing/app/guides/[slug]/page.tsx` with `generateStaticParams`, `dynamicParams = false`, app-specific metadata, `Article`, `BreadcrumbList`, `HowTo`, and `HowToStep` JSON-LD.
- `landing/app/compatibility/page.tsx` now links supported compatibility rows to dedicated app setup guides.
- `landing/app/docs/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/guides` plus the six guide detail routes.
- `scripts/verify_landing.sh` now requires `/guides`, `/guides/zoom`, `/guides/discord`, `/guides/google-meet`, `/guides/microsoft-teams`, `/guides/obs`, and `/guides/riverside` to return HTTP 200.
- The landing verifier checks rendered guide hub content, detail page setup/troubleshooting content, structured data, docs/compatibility discovery, sitemap entries, `llms.txt` AI crawl guidance, and source-level contracts for shared guide content and static guide generation.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- Targeted source checks found `appGuides`, `/guides`, `generateStaticParams`, `dynamicParams = false`, `Article`, `HowToStep`, and `supportMailtoLink` across the new guide source and verifier.
- `git diff --check` passed before and after the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/guides` plus six static guide detail paths; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the app guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.

## Completion Audit Refresh 61

Current evidence on May 6, 2026:
- The landing site now has crawlable app-specific setup coverage for Zoom, Discord, Google Meet, Microsoft Teams, OBS, and Riverside.
- `/guides` provides a public hub for app routing instructions, support escalation, and compatibility discovery.
- Each `/guides/[slug]` page is statically generated from shared content and includes setup steps, troubleshooting checks, related docs links, and prefilled setup support.
- The guide hub and detail pages expose structured data for AI/search discovery: `CollectionPage`, `BreadcrumbList`, `ItemList`, `Article`, `HowTo`, and `HowToStep`.
- App setup guides are discoverable from compatibility, docs, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- The landing verifier now covers guide route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, and compatibility discovery.
- Default and production-env landing verification runs both passed after the app setup guide changes.
- `scripts/verify_app.sh` passed after the app setup guide changes.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Browser Use App Guides Visual QA

Plan:
- [x] Start the built landing site locally on a fixed free port.
- [x] Attempt Browser Use `iab` against the new app guide pages; use local Playwright fallback only if the required Browser Use Node REPL execution path remains unavailable.
- [x] Check `/guides` and all six `/guides/[slug]` pages on desktop for visible layout, headings, CTAs, links, and console errors.
- [x] Check representative mobile guide layouts and mobile menu behavior so guide cards, setup lists, and CTAs do not overlap or overflow.
- [x] Fix any visual or interaction defects found, then rerun targeted verification.
- [x] Record visual QA evidence and update the completion audit.

Evidence:
- Local production server started on `http://127.0.0.1:4330` from the current built landing site and was stopped after QA.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local Playwright fallback loaded `/guides`, `/guides/zoom`, `/guides/discord`, `/guides/google-meet`, `/guides/microsoft-teams`, `/guides/obs`, and `/guides/riverside` at `1440x1000` desktop and `390x844` mobile.
- Playwright fallback screenshots were captured under `/tmp/sounddeck-browser-qa-app-guides/`, including desktop and mobile screenshots for the hub and all six detail pages.
- Desktop and mobile checks for every guide page returned HTTP 200, expected document titles, expected `h1` text, required guide section text, no horizontal overflow, no horizontally offscreen interactive controls, no tiny button controls, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/guides/zoom` opened successfully at `390x844`, set `aria-expanded="true"`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.
- No source changes were required after visual QA.

## Completion Audit Refresh 62

Current evidence on May 6, 2026:
- The newest app setup guide pages now have fallback visual-browser evidence in addition to route, build, schema, and source-contract verification.
- `/guides` and all six `/guides/[slug]` pages pass desktop and mobile browser checks for HTTP status, titles, heading hierarchy, required guide content, overflow, offscreen controls, tiny button controls, panel overlap, console warnings/errors, and page errors.
- The mobile menu opens cleanly from a guide detail page and retains expected navigation and CTA links.
- Browser Use itself remains unavailable in this session because the required Node REPL JavaScript execution tool is not exposed, but the same local-browser QA intent was covered by Playwright screenshots and runtime checks.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing System Requirements Page

Plan:
- [x] Add shared system requirement content for macOS version, hardware, driver, permissions, target apps, imports, storage, network, and plans.
- [x] Add a `/system-requirements` public page with crawlable requirement details, install readiness checks, FAQs, and structured data.
- [x] Link system requirements from download, docs, footer, sitemap, `llms.txt`, and landing README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, and final diff checks.

Evidence:
- `landing/lib/content.ts` now exports shared `systemRequirements`, `systemReadinessChecks`, and `systemRequirementFaqs` content covering macOS version, Mac hardware, virtual audio driver approval, microphone permission, target app support, audio imports, local storage, network access, and Free or Pro plan requirements.
- Added `landing/app/system-requirements/page.tsx` with crawlable requirement panels, readiness checks, requirements FAQ, setup support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes System Requirements in `docsGuides`, so the docs hub links to `/system-requirements` from shared docs metadata.
- `landing/app/download/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/system-requirements`.
- `scripts/verify_landing.sh` now requires `/system-requirements` to return HTTP 200, checks rendered requirement content, FAQ content, schema markers, download/docs/footer discovery, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `systemRequirements`, `systemReadinessChecks`, `systemRequirementFaqs`, `/system-requirements`, `System Requirements`, and `SoundDeck system requirements` across landing source, verifier, README, and `llms.txt`.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/system-requirements`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the system requirements page change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Local production server started on `http://127.0.0.1:4331` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/system-requirements` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-system-requirements/`.
- Desktop and mobile checks for `/system-requirements` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no tiny button controls, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/system-requirements` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.

## Completion Audit Refresh 63

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/system-requirements` page for supported macOS versions, Apple Silicon and Intel support, CoreAudio driver approval, microphone permission, app compatibility, audio imports, storage, network access, and Free or Pro plan requirements.
- `/system-requirements` is discoverable from download, docs, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/system-requirements` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/system-requirements` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` AI guidance, docs discovery, download discovery, and README route docs.
- Default and production-env landing verification runs both passed after the system requirements page change.
- `scripts/verify_app.sh` passed after the system requirements page change.
- Targeted fallback visual QA passed for `/system-requirements` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Virtual Microphone Guide

Plan:
- [x] Add shared virtual microphone routing content for driver setup, hardware mic selection, target app selection, monitoring, browser cache checks, and Stop All safety.
- [x] Add a `/docs/virtual-microphone` public page with route flow, setup checklist, FAQ, and structured data.
- [x] Link the guide from docs, getting started, features, compatibility, footer, sitemap, `llms.txt`, and landing README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.

Evidence:
- `landing/lib/content.ts` now exports shared `virtualMicrophoneFlow`, `virtualMicrophoneChecks`, and `virtualMicrophoneFaqs` content for driver installation, microphone permission, hardware mic selection, target app selection, monitoring, browser refreshes, and Stop All safety.
- Added `landing/app/docs/virtual-microphone/page.tsx` with route explanation, selection rule, numbered setup flow, clean route checklist, virtual mic FAQ, related setup links, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Virtual Microphone in `docsGuides`, so the docs hub links to `/docs/virtual-microphone` from shared docs metadata.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/features/page.tsx`, `landing/app/compatibility/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/virtual-microphone`.
- `scripts/verify_landing.sh` now requires `/docs/virtual-microphone` to return HTTP 200, checks rendered virtual mic content, FAQ content, schema markers, docs/getting-started/features/compatibility/footer discovery, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `virtualMicrophoneFlow`, `virtualMicrophoneChecks`, `virtualMicrophoneFaqs`, `/docs/virtual-microphone`, `Virtual Microphone`, `Email virtual mic support`, and `SoundDeck Virtual Mic routing` across landing source, verifier, README, and `llms.txt`.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/virtual-microphone`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the virtual microphone guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4332` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/docs/virtual-microphone` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-virtual-microphone/`.
- Desktop and mobile checks for `/docs/virtual-microphone` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no tiny button controls, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/virtual-microphone` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.

## Completion Audit Refresh 64

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/virtual-microphone` guide that explains SoundDeck Virtual Mic routing in one canonical support/GEO page.
- `/docs/virtual-microphone` covers the complete route: CoreAudio driver install, macOS microphone permission, hardware mic selected inside SoundDeck, SoundDeck Virtual Mic selected inside the target app, monitoring, browser reloads, and Stop All safety.
- `/docs/virtual-microphone` is discoverable from docs, getting started, features, compatibility, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/virtual-microphone` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/virtual-microphone` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, features discovery, compatibility discovery, and README route docs.
- Default and production-env landing verification runs both passed after the virtual microphone guide change.
- `scripts/verify_app.sh` passed after the virtual microphone guide change.
- Targeted fallback visual QA passed for `/docs/virtual-microphone` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Uninstall Guide

Plan:
- [x] Add shared uninstall content for driver removal, app removal, target-app restarts, verification, and support escalation.
- [x] Add `/docs/uninstall` with uninstall checklist, verification checks, FAQ, and structured data.
- [x] Link the uninstall guide from docs, troubleshooting, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `landing/lib/content.ts` now exports shared `uninstallSteps`, `uninstallVerificationChecks`, and `uninstallFaqs` content covering driver-first removal, app removal, target-app restarts, stale microphone pickers, reinstall prep, and support escalation.
- Added `landing/app/docs/uninstall/page.tsx` with the public uninstall guide, checklist, verification checks, FAQ, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Uninstall in `docsGuides`, so the docs hub links to `/docs/uninstall` from shared docs metadata.
- `landing/app/docs/troubleshooting/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/uninstall`.
- `scripts/verify_landing.sh` now requires `/docs/uninstall` to return HTTP 200, checks rendered uninstall content, FAQ content, schema markers, docs/troubleshooting/footer discovery, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `uninstallSteps`, `uninstallVerificationChecks`, `uninstallFaqs`, `/docs/uninstall`, `Email uninstall support`, `Remove SoundDeck safely`, and `Open uninstall guide` across landing source, verifier, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/uninstall`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the uninstall guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4333` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/docs/uninstall` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-uninstall/`.
- Desktop and mobile checks for `/docs/uninstall` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/uninstall` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.
- Screenshot review found the uninstall guide readable on desktop and mobile: setup steps stack cleanly, FAQ and verification cards fit, CTAs remain visible, footer discovery includes Uninstall, and the opened mobile menu layout is coherent.
- Final `git diff --check` passed after the uninstall guide evidence update.

## Completion Audit Refresh 65

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/uninstall` guide for removing SoundDeck Virtual Mic and SoundDeck.app without leaving stale target-app microphone state.
- `/docs/uninstall` covers the complete cleanup path: remove the CoreAudio driver first, quit SoundDeck, move the app to Trash, restart target apps, verify microphone pickers, and escalate support with useful diagnostics.
- `/docs/uninstall` is discoverable from docs, troubleshooting, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/uninstall` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/uninstall` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, troubleshooting discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the uninstall guide change.
- `scripts/verify_app.sh` passed after the uninstall guide change.
- Targeted fallback visual QA passed for `/docs/uninstall` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Microphone Permission Guide

Plan:
- [x] Add shared microphone permission content for macOS Settings, SoundDeck relaunch, route checks, reset guidance, and support escalation.
- [x] Add `/docs/microphone-permission` with permission checklist, recovery checks, FAQ, and structured data.
- [x] Link the guide from docs, getting started, troubleshooting, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `landing/lib/content.ts` now exports shared `microphonePermissionSteps`, `microphonePermissionChecks`, and `microphonePermissionFaqs` content covering macOS Privacy & Security, SoundDeck relaunch, route checks, permission prompt recovery, and support escalation.
- Added `landing/app/docs/microphone-permission/page.tsx` with the public permission guide, recovery checks, FAQ, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Microphone Permission in `docsGuides`, so the docs hub links to `/docs/microphone-permission` from shared docs metadata.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/docs/troubleshooting/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/microphone-permission`.
- `scripts/verify_landing.sh` now requires `/docs/microphone-permission` to return HTTP 200, checks rendered permission content, FAQ content, schema markers, docs/getting-started/troubleshooting/support/footer discovery, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `microphonePermissionSteps`, `microphonePermissionChecks`, `microphonePermissionFaqs`, `/docs/microphone-permission`, `Email microphone support`, `Grant microphone access to SoundDeck`, and `Open microphone permission guide` across landing source, verifier, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/microphone-permission`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the microphone permission guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4334` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/docs/microphone-permission` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-microphone-permission/`.
- Desktop and mobile checks for `/docs/microphone-permission` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/microphone-permission` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.
- Screenshot review found the microphone permission guide readable on desktop and mobile: setup steps stack cleanly, FAQ and recovery cards fit, CTAs remain visible, footer discovery includes Microphone Permission, and the opened mobile menu layout is coherent.
- Final `git diff --check` passed after the microphone permission guide evidence update.

## Completion Audit Refresh 66

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/microphone-permission` guide for granting macOS microphone access to SoundDeck before virtual microphone routing.
- `/docs/microphone-permission` covers the complete permission path: System Settings, Privacy & Security, Microphone, enabling SoundDeck, restarting SoundDeck, rechecking the hardware mic inside SoundDeck, and reloading target apps or browser tabs.
- `/docs/microphone-permission` is discoverable from docs, getting started, troubleshooting, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/microphone-permission` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/microphone-permission` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, troubleshooting discovery, support discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the microphone permission guide change.
- `scripts/verify_app.sh` passed after the microphone permission guide change.
- Targeted fallback visual QA passed for `/docs/microphone-permission` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Audio Driver Guide

Plan:
- [x] Add shared audio driver content for install, macOS approval, reinstall, target-app restarts, verification, and support escalation.
- [x] Add `/docs/audio-driver` with driver setup checklist, verification checks, FAQ, and structured data.
- [x] Link the guide from docs, getting started, troubleshooting, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `landing/lib/content.ts` now exports shared `audioDriverSteps`, `audioDriverChecks`, and `audioDriverFaqs` content covering Audio Driver settings, SoundDeck Virtual Mic install, administrator approval, macOS security prompts, target-app restarts, reinstall guidance, and support escalation.
- Added `landing/app/docs/audio-driver/page.tsx` with the public audio driver guide, driver verification checks, FAQ, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Audio Driver in `docsGuides`, so the docs hub links to `/docs/audio-driver` from shared docs metadata.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/docs/troubleshooting/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/audio-driver`.
- `scripts/verify_landing.sh` now requires `/docs/audio-driver` to return HTTP 200, checks rendered driver content, FAQ content, schema markers, docs/getting-started/troubleshooting/support/footer discovery, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `audioDriverSteps`, `audioDriverChecks`, `audioDriverFaqs`, `/docs/audio-driver`, `Email driver support`, `Install the SoundDeck audio driver`, and `Open audio driver guide` across landing source, verifier, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/audio-driver`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the audio driver guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4335` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/docs/audio-driver` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-audio-driver/`.
- Desktop and mobile checks for `/docs/audio-driver` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/audio-driver` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.
- Screenshot review found the audio driver guide readable on desktop and mobile: install steps stack cleanly, FAQ and verification cards fit, CTAs remain visible, footer discovery includes Audio Driver, and the opened mobile menu layout is coherent.
- Final `git diff --check` passed after the audio driver guide evidence update.

## Completion Audit Refresh 67

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/audio-driver` guide for installing, approving, reinstalling, and verifying the SoundDeck CoreAudio driver.
- `/docs/audio-driver` covers the complete driver path: open Audio Driver settings, install SoundDeck Virtual Mic, approve administrator and macOS security prompts, restart target apps, verify SoundDeck Virtual Mic, and escalate support with useful diagnostics.
- `/docs/audio-driver` is discoverable from docs, getting started, troubleshooting, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/audio-driver` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/audio-driver` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, troubleshooting discovery, support discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the audio driver guide change.
- `scripts/verify_app.sh` passed after the audio driver guide change.
- Targeted fallback visual QA passed for `/docs/audio-driver` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing audio driver guide, fallback visual QA for audio driver guide, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Import Sounds Guide

Plan:
- [x] Add shared import content for supported formats, drag-and-drop, file picker import, folder organization, Free limits, and support escalation.
- [x] Add `/docs/import-sounds` with import checklist, verification checks, FAQ, and structured data.
- [x] Link the guide from docs, getting started, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `landing/lib/content.ts` now exports shared `importSoundSteps`, `importSoundChecks`, and `importSoundFaqs` content covering supported MP3, WAV, M4A, AAC, AIFF, and CAF files, Add Sound import, drag-and-drop import, folder organization, Free plan slot limits, preview, trim, volume, and support escalation.
- Added `landing/app/docs/import-sounds/page.tsx` with the public import guide, import verification checks, FAQ, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Import Sounds in `docsGuides`, so the docs hub links to `/docs/import-sounds` from shared docs metadata.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/import-sounds`.
- `scripts/verify_landing.sh` now requires `/docs/import-sounds` to return HTTP 200, checks rendered import content, FAQ content, schema markers, docs/getting-started/support/footer discovery, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `importSoundSteps`, `importSoundChecks`, `importSoundFaqs`, `/docs/import-sounds`, `Email import support`, `Import sounds into SoundDeck`, and `Open import sounds guide` across landing source, verifier, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/import-sounds`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the import sounds guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4336` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/docs/import-sounds` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-import-sounds/`.
- Desktop and mobile checks for `/docs/import-sounds` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/import-sounds` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.
- Screenshot review found the import sounds guide readable on desktop and mobile: import steps stack cleanly, FAQ and verification cards fit, CTAs remain visible, footer discovery includes Import Sounds, and the opened mobile menu layout is coherent.
- Final `git diff --check` passed after the import sounds guide evidence update.

## Completion Audit Refresh 68

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/import-sounds` guide for adding supported audio files to SoundDeck and checking they are safe for a live session.
- `/docs/import-sounds` covers the complete import path: prepare supported files, import with Add Sound or drag-and-drop, organize folders, trim and set pad volume, preview locally, respect Free plan custom sound limits, and escalate support with useful diagnostics.
- `/docs/import-sounds` is discoverable from docs, getting started, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/import-sounds` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/import-sounds` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, support discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the import sounds guide change.
- `scripts/verify_app.sh` passed after the import sounds guide change.
- Targeted fallback visual QA passed for `/docs/import-sounds` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing audio driver guide, fallback visual QA for audio driver guide, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing import sounds guide, fallback visual QA for import sounds guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Voice Effects Guide

Plan:
- [x] Add shared voice effects content for Pro access, microphone permission, pitch slider/presets, voice monitor, target-app routing, hotkeys, and support escalation.
- [x] Add `/docs/voice-effects` with voice effects checklist, verification checks, FAQ, and structured data.
- [x] Link the guide from docs, getting started, features, pricing, hotkeys, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `landing/lib/content.ts` now exports shared `voiceEffectsSteps`, `voiceEffectsChecks`, and `voiceEffectsFaqs` content covering Pro access, microphone permission, Voice Changer enablement, Deep/Normal/High/Chipmunk or custom pitch testing, Voice Monitor, target-app routing, Toggle voice changer hotkey setup, and support escalation.
- Added `landing/app/docs/voice-effects/page.tsx` with the public voice effects guide, verification checks, FAQ, pricing/privacy/setup CTAs, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Voice Effects in `docsGuides`, so the docs hub links to `/docs/voice-effects` from shared docs metadata.
- Added a shared support topic for "Voice effects not reaching a call" so `/support` and `/support?q=voice` cover Pro state, Voice Changer enabled state, hardware mic selection, target-app SoundDeck Virtual Mic routing, and Voice Monitor checks.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/features/page.tsx`, `landing/app/pricing/page.tsx`, `landing/app/docs/hotkeys/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/voice-effects`.
- `scripts/verify_landing.sh` now requires `/docs/voice-effects` to return HTTP 200, checks rendered voice effects content, FAQ content, schema markers, docs/getting-started/features/pricing/hotkeys/support/footer discovery, support search coverage, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `voiceEffectsSteps`, `voiceEffectsChecks`, `voiceEffectsFaqs`, `/docs/voice-effects`, `Email voice effects support`, `Use voice effects in SoundDeck`, `Open voice effects guide`, `Read voice effects guide`, `Review voice effects`, and `Voice effects not reaching a call` across landing source, verifier, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/voice-effects`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the voice effects guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4337` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/docs/voice-effects` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-voice-effects/`.
- Desktop and mobile checks for `/docs/voice-effects` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/voice-effects` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.
- Screenshot review found the voice effects guide readable on desktop and mobile: Pro/local-processing panels fit, setup steps stack cleanly, FAQ and verification cards fit, CTAs remain visible, footer discovery includes Voice Effects, and the opened mobile menu layout is coherent.
- Final `git diff --check` passed after the voice effects guide evidence update.

## Completion Audit Refresh 69

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/voice-effects` guide for using SoundDeck Pro voice changer controls safely with SoundDeck Virtual Mic.
- `/docs/voice-effects` covers the complete voice effects path: confirm Pro access, grant microphone permission, enable Voice Changer, start near Normal, test Deep/High/Chipmunk or custom pitch privately, use Voice Monitor through headphones, choose SoundDeck Virtual Mic in the target app, and assign a Toggle voice changer hotkey before going live.
- `/docs/voice-effects` is discoverable from docs, getting started, features, pricing, hotkeys, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/voice-effects` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/voice-effects` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, features discovery, pricing discovery, hotkeys discovery, support discovery, support search discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the voice effects guide change.
- `scripts/verify_app.sh` passed after the voice effects guide change.
- Targeted fallback visual QA passed for `/docs/voice-effects` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing audio driver guide, fallback visual QA for audio driver guide, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing import sounds guide, fallback visual QA for import sounds guide, landing voice effects guide, fallback visual QA for voice effects guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Monitoring Preview Guide

Plan:
- [x] Add shared monitoring content for Preview, SFX Monitor, Voice Monitor, headphones, output device checks, virtual mic routing, feedback prevention, and support escalation.
- [x] Add `/docs/monitoring-preview` with monitoring checklist, verification checks, FAQ, and structured data.
- [x] Link the guide from docs, getting started, features, import sounds, voice effects, troubleshooting, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, support search, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `landing/lib/content.ts` now exports shared `monitoringPreviewSteps`, `monitoringPreviewChecks`, and `monitoringPreviewFaqs` content covering Preview / Monitor Output, private Preview, SFX Monitor, Voice Monitor, headphones, target-app routing, Stop All, feedback prevention, and support escalation.
- Added `landing/app/docs/monitoring-preview/page.tsx` with the public monitoring and preview guide, verification checks, FAQ, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Monitoring And Preview in `docsGuides`, so the docs hub links to `/docs/monitoring-preview` from shared docs metadata.
- Added a shared support topic for "Monitoring or preview not audible" so `/support` and `/support?q=monitoring` cover Preview / Monitor Output, local output device selection, Preview, SFX Monitor, and Voice Monitor checks.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/features/page.tsx`, `landing/app/docs/import-sounds/page.tsx`, `landing/app/docs/voice-effects/page.tsx`, `landing/app/docs/troubleshooting/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/monitoring-preview`.
- `scripts/verify_landing.sh` now requires `/docs/monitoring-preview` to return HTTP 200, checks rendered monitoring content, FAQ content, schema markers, docs/getting-started/features/import-sounds/voice-effects/troubleshooting/support/footer discovery, support search coverage, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `monitoringPreviewSteps`, `monitoringPreviewChecks`, `monitoringPreviewFaqs`, `/docs/monitoring-preview`, `Email monitoring support`, `Monitor and preview SoundDeck safely`, `Open monitoring guide`, `Read monitoring guide`, and `Monitoring or preview not audible` across landing source, verifier, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/monitoring-preview`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the monitoring and preview guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4338` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/docs/monitoring-preview` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-monitoring-preview/`.
- Desktop and mobile checks for `/docs/monitoring-preview` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/monitoring-preview` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.
- Screenshot review found the monitoring and preview guide readable on desktop and mobile: private-preview and live-monitoring panels fit, setup steps stack cleanly, FAQ and verification cards fit, CTAs remain visible, footer discovery includes Monitoring And Preview, and the opened mobile menu layout is coherent.
- Final `git diff --check` passed after the monitoring and preview guide evidence update.

## Completion Audit Refresh 70

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/monitoring-preview` guide for using Preview, SFX Monitor, Voice Monitor, and Preview / Monitor Output without creating feedback or confusing local monitoring with the live target-app route.
- `/docs/monitoring-preview` covers the complete monitoring path: choose a monitor output, use headphones, preview clips privately, turn on SFX Monitor intentionally, use Voice Monitor only when checking microphone or voice changer output, verify SoundDeck Virtual Mic in the target app, and stop monitoring before switching live rooms.
- `/docs/monitoring-preview` is discoverable from docs, getting started, features, import sounds, voice effects, troubleshooting, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/monitoring-preview` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/monitoring-preview` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, features discovery, import-sounds discovery, voice-effects discovery, troubleshooting discovery, support discovery, support search discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the monitoring and preview guide change.
- `scripts/verify_app.sh` passed after the monitoring and preview guide change.
- Targeted fallback visual QA passed for `/docs/monitoring-preview` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing audio driver guide, fallback visual QA for audio driver guide, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing import sounds guide, fallback visual QA for import sounds guide, landing voice effects guide, fallback visual QA for voice effects guide, landing monitoring and preview guide, fallback visual QA for monitoring and preview guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Trim Volume Guide

Plan:
- [x] Add shared trim and volume content for right-click pad controls, per-sound volume, Pro trim editor, waveform handles, preview, Save/Cancel behavior, monitoring, and support escalation.
- [x] Add `/docs/trim-volume` with trim/volume checklist, verification checks, FAQ, and structured data.
- [x] Link the guide from docs, getting started, features, pricing, import sounds, monitoring preview, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, support search, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `landing/lib/content.ts` now exports shared `trimVolumeSteps`, `trimVolumeChecks`, and `trimVolumeFaqs` content covering right-click pad controls, per-sound Sound Volume, Pro-gated Trim Audio, waveform start/end handles, Preview, Save, Cancel, monitoring, SoundDeck Virtual Mic live-route tests, and support escalation.
- Added `landing/app/docs/trim-volume/page.tsx` with the public trim and volume guide, verification checks, FAQ, pricing/import/monitoring CTAs, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Trim And Volume in `docsGuides`, so the docs hub links to `/docs/trim-volume` from shared docs metadata.
- Added a shared support topic for "Trim or volume changes sound wrong" so `/support` and `/support?q=trim` cover Sound Volume, Pro Trim Audio, Preview, Save, target app route, and SoundDeck Virtual Mic test checks.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/features/page.tsx`, `landing/app/pricing/page.tsx`, `landing/app/docs/import-sounds/page.tsx`, `landing/app/docs/monitoring-preview/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/trim-volume`.
- `scripts/verify_landing.sh` now requires `/docs/trim-volume` to return HTTP 200, checks rendered trim/volume content, FAQ content, schema markers, docs/getting-started/features/pricing/import-sounds/monitoring/support/footer discovery, support search coverage, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `trimVolumeSteps`, `trimVolumeChecks`, `trimVolumeFaqs`, `/docs/trim-volume`, `Email trim support`, `Trim and balance SoundDeck sounds`, `Open trim and volume guide`, `Read trim and volume guide`, `Review trim controls`, and `Trim or volume changes sound wrong` across landing source, verifier, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/trim-volume`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the trim and volume guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4339` from the current built landing site and was stopped after targeted visual QA.
- Local Playwright fallback loaded `/docs/trim-volume` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-trim-volume/`.
- Desktop and mobile checks for `/docs/trim-volume` returned HTTP 200, expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overlapping info panels, no console warnings/errors, and no page errors.
- Mobile menu interaction on `/docs/trim-volume` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no console/page errors.
- Screenshot review found the trim and volume guide readable on desktop and mobile: Volume Is Per Sound and Trim Is Pro panels fit, setup steps stack cleanly, FAQ and verification cards fit, CTAs remain visible, footer discovery includes Trim And Volume, and the opened mobile menu layout is coherent.
- Final `git diff --check` passed after the trim and volume guide evidence update.

## Completion Audit Refresh 71

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/trim-volume` guide for balancing per-sound volume and using the SoundDeck Pro Trim Audio editor before sounds reach a live microphone path.
- `/docs/trim-volume` covers the complete trim/volume path: open the pad menu, use Sound Volume, understand Trim Audio as a Pro control, move waveform start/end handles, preview before saving, save only after the region sounds right, test one short SoundDeck Virtual Mic trigger, and keep Stop All ready.
- `/docs/trim-volume` is discoverable from docs, getting started, features, pricing, import sounds, monitoring preview, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/trim-volume` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/trim-volume` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, features discovery, pricing discovery, import-sounds discovery, monitoring discovery, support discovery, support search discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the trim and volume guide change.
- `scripts/verify_app.sh` passed after the trim and volume guide change.
- Targeted fallback visual QA passed for `/docs/trim-volume` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing audio driver guide, fallback visual QA for audio driver guide, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing import sounds guide, fallback visual QA for import sounds guide, landing trim and volume guide, fallback visual QA for trim and volume guide, landing voice effects guide, fallback visual QA for voice effects guide, landing monitoring and preview guide, fallback visual QA for monitoring and preview guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Landing Pro Library Guide

Plan:
- [x] Add shared Pro library content for Pro access, Trending/Popular/Recent/Search browsing, preview, Add to Library, optional network requests, privacy notes, and support escalation.
- [x] Add `/docs/pro-library` with Pro library checklist, verification checks, FAQ, structured data, and links to pricing, privacy, imports, and monitoring.
- [x] Link the guide from docs, getting started, features, pricing, import sounds, privacy, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, support search, privacy link, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, visual QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `landing/lib/content.ts` now exports shared `proLibrarySteps`, `proLibraryChecks`, and `proLibraryFaqs` content covering Pro access, Pro Library sidebar entry, Trending/Popular/Recent/Search browsing, optional provider requests, local preview, Add to Library import, local storage, polish checks, and support escalation.
- Added `landing/app/docs/pro-library/page.tsx` with the public Pro Library guide, verification checks, FAQ, pricing/privacy/import/monitoring/trim CTAs, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Pro Library in `docsGuides`, so the docs hub links to `/docs/pro-library` from shared docs metadata.
- Added a shared support topic for "Pro library search or import not working" so `/support` and `/support?q=library` cover Pro state, network availability, library tabs, search terms, local preview, Add to Library completion, and SoundDeck Virtual Mic testing.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/features/page.tsx`, `landing/app/pricing/page.tsx`, `landing/app/docs/import-sounds/page.tsx`, `landing/app/privacy/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/pro-library`.
- `scripts/verify_landing.sh` now requires `/docs/pro-library` to return HTTP 200, checks rendered Pro Library content, FAQ content, schema markers, docs/getting-started/features/pricing/import-sounds/privacy/support/footer discovery, support search coverage, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` passed after the verifier update.
- A targeted source check found `proLibrarySteps`, `proLibraryChecks`, `proLibraryFaqs`, `/docs/pro-library`, `Email Pro library support`, `Use the SoundDeck Pro Library`, `Open Pro library guide`, `Read Pro library guide`, `Review Pro Library`, and `Pro library search or import not working` across landing source, verifier, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/pro-library`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the Pro Library guide change. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- The local landing package did not have Playwright installed; a transient Playwright attempt could not resolve the runner from the temporary spec, so a dependency-free Chrome DevTools Protocol fallback used installed system Chrome against `http://127.0.0.1:4340`.
- Local production server started on `http://127.0.0.1:4340` from the current built landing site and was stopped after targeted browser QA.
- Chrome CDP fallback loaded `/docs/pro-library` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-pro-library/`.
- Desktop and mobile checks for `/docs/pro-library` returned expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overflowing button text, no overlapping info panels, no page errors, and no non-ignored console warnings/errors. Two local-origin manifest warnings were ignored because they are caused by loading the production-origin manifest from `127.0.0.1`.
- Mobile menu interaction on `/docs/pro-library` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no page errors or non-ignored console warnings/errors.
- Screenshot generation confirmed nontrivial desktop, mobile, and mobile-menu PNG captures under `/tmp/sounddeck-browser-qa-pro-library/`.

## Completion Audit Refresh 72

Current evidence on May 6, 2026:
- The landing site now has a dedicated `/docs/pro-library` guide for using the SoundDeck Pro Library before sounds reach a live microphone path.
- `/docs/pro-library` covers the complete Pro Library path: confirm Pro access, open the Pro Library sidebar row, use Trending/Popular/Recent/Search tabs, understand optional provider requests, preview locally, Add to Library, verify the imported sound in the local grid, trim or balance volume if needed, and test one short SoundDeck Virtual Mic trigger before going live.
- `/docs/pro-library` is discoverable from docs, getting started, features, pricing, import sounds, privacy, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/pro-library` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/pro-library` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, features discovery, pricing discovery, import-sounds discovery, privacy discovery, support discovery, support search discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the Pro Library guide change.
- `scripts/verify_app.sh` passed after the Pro Library guide change.
- Targeted fallback browser QA passed for `/docs/pro-library` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, Pro Library runtime entitlement guards, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing audio driver guide, fallback visual QA for audio driver guide, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing import sounds guide, fallback visual QA for import sounds guide, landing Pro Library guide, fallback browser QA for Pro Library guide, landing trim and volume guide, fallback visual QA for trim and volume guide, landing voice effects guide, fallback visual QA for voice effects guide, landing monitoring and preview guide, fallback visual QA for monitoring and preview guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Folder Organization Guide And Move Action

Plan:
- [x] Add a SoundPad context-menu "Move to Folder" action so existing sounds can move into folders or back to All Sounds.
- [x] Extend app verification so selected-folder imports and existing-pad folder moves remain covered.
- [x] Add shared folder organization content for default folders, creating folders, selected-folder import, moving existing sounds, deleting folders safely, and support escalation.
- [x] Add `/docs/folders` with folder organization checklist, verification checks, FAQ, structured data, and links to imports, Pro Library, trim/volume, monitoring, and privacy.
- [x] Link the guide from docs, getting started, import sounds, Pro Library, features, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, support search, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, browser QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `SoundDeckApp/Views/SoundPadView.swift` now includes a pad context-menu `Move to Folder` submenu with All Sounds plus every existing folder, and updates `appState.sounds[index].folderID` through `moveToFolder(_:)`.
- `scripts/verify_app.sh` now checks selected-folder drag/import behavior, selected-folder Add Sound behavior, the `Move to Folder` context-menu label, the All Sounds move path, and state-based `folderID` updates.
- `landing/lib/content.ts` now exports shared `folderOrganizationSteps`, `folderOrganizationChecks`, and `folderOrganizationFaqs` content covering All vs folder filtering, default folders, folder creation, selected-folder import, moving existing sounds, safe folder deletion, preview checks, and support escalation.
- Added `landing/app/docs/folders/page.tsx` with the public folders guide, verification checks, FAQ, storage/import/Pro Library/trim/monitoring CTAs, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Folders in `docsGuides`, so the docs hub links to `/docs/folders` from shared docs metadata.
- Added a shared support topic for "Folders not showing the right sounds" so `/support` and `/support?q=folders` cover All vs selected folder, visible counts, Move to Folder, All Sounds, and deleted-folder recovery.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/features/page.tsx`, `landing/app/docs/import-sounds/page.tsx`, `landing/app/docs/pro-library/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/folders`.
- `scripts/verify_landing.sh` now requires `/docs/folders` to return HTTP 200, checks rendered folder content, FAQ content, schema markers, docs/getting-started/features/import-sounds/Pro-Library/support/footer discovery, support search coverage, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` and `bash -n scripts/verify_app.sh` passed after the verifier updates.
- A targeted source check found `folderOrganizationSteps`, `folderOrganizationChecks`, `folderOrganizationFaqs`, `/docs/folders`, `Email folder support`, `Organize SoundDeck sounds with folders`, `Open folders guide`, `Read folders guide`, `Folders not showing the right sounds`, `Move to Folder`, and `moveToFolder` across landing source, app source, verifiers, and task evidence.
- `git diff --check` passed before the full verification sequence.
- Default landing verification passed without production env vars and prerendered `/docs/folders`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the folder move and guide changes. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4341` from the current built landing site and was stopped after targeted browser QA.
- Chrome CDP fallback loaded `/docs/folders` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-folders/`.
- Desktop and mobile checks for `/docs/folders` returned expected title, expected `h1`, required visible content, no horizontal overflow, no horizontally offscreen interactive controls, no undersized button-like controls under the existing design-system threshold, no overflowing button text, no overlapping info panels, no page errors, and no non-ignored console warnings/errors. Local-origin manifest warnings were ignored because they are caused by loading the production-origin manifest from `127.0.0.1`.
- Mobile menu interaction on `/docs/folders` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, introduced no horizontal overflow, and produced no page errors or non-ignored console warnings/errors.
- Screenshot generation confirmed nontrivial desktop, mobile, and mobile-menu PNG captures under `/tmp/sounddeck-browser-qa-folders/`.

## Completion Audit Refresh 73

Current evidence on May 6, 2026:
- The app now exposes a `Move to Folder` context-menu action for existing sound pads, including moving back to All Sounds.
- The app verifier now covers selected-folder imports and the existing-pad folder move action.
- The landing site now has a dedicated `/docs/folders` guide for organizing SoundDeck boards with folders before sounds reach a live microphone path.
- `/docs/folders` covers the complete folder path: use All and folder filters, create folders, import into the selected folder, move existing pads with Move to Folder, rename or delete folders safely, understand that deleting a folder does not delete audio files, preview the final folder, and test one short SoundDeck Virtual Mic trigger before going live.
- `/docs/folders` is discoverable from docs, getting started, features, import sounds, Pro Library, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/folders` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/folders` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, features discovery, import-sounds discovery, Pro-Library discovery, support discovery, support search discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the folder guide change.
- `scripts/verify_app.sh` passed after the folder move and guide changes.
- Targeted fallback browser QA passed for `/docs/folders` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, folder move action, Pro Library runtime entitlement guards, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing audio driver guide, fallback visual QA for audio driver guide, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing import sounds guide, fallback visual QA for import sounds guide, landing folders guide, fallback browser QA for folders guide, landing Pro Library guide, fallback browser QA for Pro Library guide, landing trim and volume guide, fallback visual QA for trim and volume guide, landing voice effects guide, fallback visual QA for voice effects guide, landing monitoring and preview guide, fallback visual QA for monitoring and preview guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Free Plan And Pro Upgrade Guide

Plan:
- [x] Add app verifier coverage for Free/Pro feature gates, watermark state, UpgradeView feature rows, Restore Purchases, and Manage Subscription.
- [x] Add shared Free plan content for bundled defaults, 8 custom imports, watermark behavior, basic hotkeys, setup verification, Pro unlocks, restore/manage subscription, and support escalation.
- [x] Add `/docs/free-plan` with Free/Pro checklist, verification checks, FAQ, structured data, and links to pricing, import sounds, folders, Pro Library, voice effects, trim/volume, hotkeys, and support.
- [x] Link the guide from docs, getting started, pricing, import sounds, Pro Library, voice effects, hotkeys, support, footer, sitemap, `llms.txt`, and README.
- [x] Extend the landing verifier with route, rendered content, schema, source contract, sitemap, support search, and AI crawl guidance coverage.
- [x] Run syntax, targeted source, diff, default landing, production-env landing, app verifier, release prerequisite, browser QA, and final diff checks.
- [x] Record evidence and update the completion audit.

Evidence:
- `SoundDeckApp/Licensing/WatermarkPlayer.swift` now describes the watermark as the Free-plan watermark that runs while SoundDeck Pro is inactive.
- `scripts/verify_app.sh` now checks the Free/Pro feature gates for voice changer, per-sound hotkeys, trim editor, Pro Library, and watermark removal, plus UpgradeView feature rows, Restore Purchases, Free Plan, SoundDeck Pro Active, Manage Subscription, Apple subscription management, StoreKit restore sync, and restore status messages.
- `landing/lib/content.ts` now exports shared `freePlanSteps`, `freePlanChecks`, and `freePlanFaqs` content covering starter sounds, route testing, 8 custom imports, the Free watermark, Pro unlocks, Restore Purchases, and Manage Subscription.
- Added `landing/app/docs/free-plan/page.tsx` with the public Free Plan And Pro guide, verification checks, FAQ, related guide links, support CTA, and `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` JSON-LD.
- `landing/lib/content.ts` now includes Free Plan And Pro in `docsGuides`, so the docs hub links to `/docs/free-plan` from shared docs metadata.
- Added a shared support topic for "Free plan limit or Pro access looks wrong" so `/support` and `/support?q=free` cover Free Plan vs SoundDeck Pro Active, custom slot accounting, Restore Purchases, and Manage Subscription.
- `landing/app/docs/getting-started/page.tsx`, `landing/app/pricing/page.tsx`, `landing/app/docs/import-sounds/page.tsx`, `landing/app/docs/pro-library/page.tsx`, `landing/app/docs/trim-volume/page.tsx`, `landing/app/docs/voice-effects/page.tsx`, `landing/app/docs/hotkeys/page.tsx`, `landing/app/support/page.tsx`, `landing/components/Footer.tsx`, `landing/app/sitemap.ts`, `landing/public/llms.txt`, and `landing/README.md` now link or list `/docs/free-plan`.
- `scripts/verify_landing.sh` now requires `/docs/free-plan` to return HTTP 200, checks rendered Free/Pro content, FAQ content, schema markers, docs/getting-started/pricing/import-sounds/Pro-Library/trim/voice/hotkeys/support/footer discovery, support search coverage, sitemap entry, `llms.txt` AI guidance, README route documentation, and source-level shared-content contracts.
- `bash -n scripts/verify_landing.sh` and `bash -n scripts/verify_app.sh` passed after the verifier updates.
- A targeted source check found `freePlanSteps`, `freePlanChecks`, `freePlanFaqs`, `/docs/free-plan`, `Email plan support`, `Understand SoundDeck Free and Pro`, `Open Free plan guide`, `Read Free plan guide`, `Free plan limit or Pro access looks wrong`, `Watermark beep`, `Restore Purchases`, `Manage Subscription`, and the Free/Pro gate properties across landing source, app source, verifiers, and task evidence.
- `git diff --check` passed before and after the full verification sequence.
- `PATH=/opt/homebrew/Cellar/node@22/22.22.2_1/bin:$PATH npm run lint` passed from `landing/`.
- Default landing verification passed without production env vars and prerendered 48 routes including `/docs/free-plan`; all public routes returned HTTP 200.
- Production-env landing verification passed with `NEXT_PUBLIC_SITE_URL=https://sounddeck.app`, `NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip`, and `NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions`.
- `scripts/verify_app.sh` passed after the Free Plan And Pro guide and verifier changes. Xcode still reports the known nonblocking CoreSimulator version warning while macOS builds/tests pass.
- `scripts/verify_release_prereqs.sh` still fails with the expected 11 missing production inputs when no production release environment is configured.
- Browser Use `iab` could not be used because tool discovery exposed Chrome DevTools evaluation tools but not the required Node REPL JavaScript execution tool (`mcp__node_repl__js` / `js`).
- Local production server started on `http://127.0.0.1:4342` from the current built landing site and was stopped after targeted browser QA.
- Chrome CDP fallback loaded `/docs/free-plan` at `1440x1000` desktop and `390x844` mobile; screenshots were captured under `/tmp/sounddeck-browser-qa-free-plan/`.
- Desktop and mobile checks for `/docs/free-plan` returned expected title, expected `h1`, required visible content, no horizontal overflow, no oversized text elements, no page errors, and no non-ignored console warnings/errors. Local-origin manifest warnings were ignored because they are caused by loading the production-origin manifest from `127.0.0.1`.
- Mobile menu interaction on `/docs/free-plan` opened successfully at `390x844`, showed expected navigation links and the Upgrade to Pro CTA, and produced no page errors or non-ignored console warnings/errors.
- Screenshot generation confirmed nontrivial desktop, mobile, and mobile-menu PNG captures under `/tmp/sounddeck-browser-qa-free-plan/` with expected dimensions: `1440x1000`, `390x844`, and `390x844`.

## Completion Audit Refresh 74

Current evidence on May 6, 2026:
- The app verifier now locks the Free/Pro gates for voice changer, per-sound hotkeys, trim editor, Pro Library, and Free-plan watermark behavior.
- The app verifier now covers UpgradeView Free vs Pro feature rows, Restore Purchases entry points, Settings Free Plan and Pro Active states, Manage Subscription, Apple subscription management, StoreKit restore sync, and restore status messages.
- The landing site now has a dedicated `/docs/free-plan` guide for understanding SoundDeck Free and SoundDeck Pro before users pay or troubleshoot plan state.
- `/docs/free-plan` covers the complete Free/Pro path: start with Free, test the virtual microphone route, use 8 custom import slots carefully, expect the Free watermark, upgrade when live controls matter, restore purchases, and manage active subscriptions.
- `/docs/free-plan` is discoverable from docs, getting started, pricing, import sounds, Pro Library, trim/volume, voice effects, hotkeys, support, footer, sitemap, `llms.txt`, landing README route documentation, and rendered homepage footer output.
- `/docs/free-plan` exposes `CollectionPage`, `BreadcrumbList`, `ItemList`, `HowTo`, `HowToStep`, and `FAQPage` structured data backed by shared content.
- The landing verifier covers `/docs/free-plan` route availability, rendered content, schema markers, source contracts, sitemap inclusion, `llms.txt` guidance, docs discovery, getting-started discovery, pricing discovery, import-sounds discovery, Pro-Library discovery, trim/voice/hotkey discovery, support discovery, support search discovery, footer discovery, and README route docs.
- Default and production-env landing verification runs both passed after the Free Plan And Pro guide change.
- `scripts/verify_app.sh` passed after the Free Plan And Pro guide and verifier changes.
- Targeted fallback browser QA passed for `/docs/free-plan` on desktop and mobile, including mobile menu behavior.
- `scripts/verify_release_prereqs.sh` still fails with 11 missing production inputs: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_DOWNLOAD_URL`, `NEXT_PUBLIC_CHECKOUT_URL`, `DEVELOPER_ID_APPLICATION`, `DEVELOPMENT_TEAM`, `SPARKLE_PUBLIC_ED_KEY`, notarization credentials, and `SPARKLE_SIGN_UPDATE`.

Completion decision:
- Do not mark the active goal complete yet.
- Local app, Settings hotkey configurability, app support diagnostics, prefilled app support email, folder move action, Free/Pro gate verification, Restore Purchases verification, Pro Library runtime entitlement guards, landing fallback rendering, landing production-env rendering, landing configured site URL rendering, landing web app manifest, landing install icon assets, landing OpenSearch descriptor, landing prefilled contact email links, landing contact hub, landing docs hub, landing compatibility page, landing app setup guides, fallback visual QA for app setup guides, landing system requirements page, fallback visual QA for system requirements, landing audio driver guide, fallback visual QA for audio driver guide, landing microphone permission guide, fallback visual QA for microphone permission guide, landing virtual microphone guide, fallback visual QA for virtual microphone guide, landing uninstall guide, fallback visual QA for uninstall guide, landing import sounds guide, fallback visual QA for import sounds guide, landing folders guide, fallback browser QA for folders guide, landing Pro Library guide, fallback browser QA for Pro Library guide, landing Free Plan And Pro guide, fallback browser QA for Free Plan And Pro guide, landing trim and volume guide, fallback visual QA for trim and volume guide, landing voice effects guide, fallback visual QA for voice effects guide, landing monitoring and preview guide, fallback visual QA for monitoring and preview guide, landing pricing page, landing use-cases page, landing features page, landing comparison page, landing FAQ page, landing troubleshooting guide, landing hotkeys guide, fallback visual QA for newest docs pages, `llms.txt` contact discovery, site URL normalization, changelog RSS feed, security.txt discovery, HTTP security headers, mobile navigation conversion parity, product mockup accessibility, support SearchAction fulfillment, CI, release build, appcast, release URL, release-notes, source metadata, archive consistency, public download filename, version metadata, Gatekeeper prerequisite, driver-smoke diagnostics, release example verification, normalized release URL validation, production URL shape validation, landing schema download URL verification, Free offer schema URL verification, landing version metadata verification, source-derived app verifier version checks, and primary CTA production URL verification remain green, but public-release readiness still requires production URLs, Apple signing/notarization identities, Sparkle update signing, a signed/notarized artifact, appcast publication, and clean-Mac driver validation.

## Duplicate Sound Variants

Plan:
- [ ] Add `Duplicate Sound` to each pad context menu so users can make safe variants before changing volume, trim, icon, color, or folder.
- [ ] Implement duplicate persistence by copying the stored audio file to a unique app-storage file, cloning metadata, keeping folder/trim/volume/icon/color, and clearing hotkey assignment.
- [ ] Respect Free plan custom-sound limits when duplicating because a duplicate creates a new custom stored sound.
- [ ] Extend app verification for the duplicate context-menu action, storage copy, metadata cloning, hotkey clearing, folder retention, and Free-limit guard.
- [ ] Update shared import/trim/support copy so public docs explain duplicate variants and troubleshooting.
- [ ] Extend the landing verifier with rendered content, support search, and source-contract coverage for duplicate sounds.
- [ ] Run syntax, targeted source, diff, landing, app, release prerequisite, and final diff checks.
- [ ] Record evidence and update the completion audit.
