# SoundDeck Release Workflow

This repo now has repeatable gates for the remaining public launch blockers:
Developer ID signing, notarization, Sparkle update signing, production landing
URLs, and clean-Mac driver verification.

## Required Secrets

Set these before running release scripts:

```bash
export NEXT_PUBLIC_SITE_URL=https://sounddeck.app
export NEXT_PUBLIC_DOWNLOAD_URL=https://sounddeck.app/downloads/SoundDeck-1.0.0-1.zip
export NEXT_PUBLIC_CHECKOUT_URL=https://apps.apple.com/account/subscriptions
export DEVELOPER_ID_APPLICATION="Developer ID Application: Example Team (TEAMID)"
export DEVELOPMENT_TEAM=TEAMID
export SPARKLE_PUBLIC_ED_KEY="..."
export SPARKLE_SIGN_UPDATE=/path/to/sign_update
export NOTARY_PROFILE=sounddeck-notary
```

Instead of `NOTARY_PROFILE`, you may set `APPLE_ID`, `APPLE_TEAM_ID`, and
`APPLE_APP_SPECIFIC_PASSWORD`.

Generate the Sparkle key pair with Sparkle's `generate_keys` tool, keep the
private key out of the repo, and pass only the public key through
`SPARKLE_PUBLIC_ED_KEY`.

## Verify Inputs

```bash
scripts/verify_release_prereqs.sh
```

This fails if the production download URL, checkout URL, Sparkle public key,
signing identity, notarization credentials, or appcast signing tool are missing.

## Build, Sign, Notarize

```bash
scripts/build_release.sh
```

The script archives `SoundDeck`, verifies the code signature, submits the zip to
notarytool, staples the app, repacks the stapled app, and prints the final zip
path under `dist/`.

## Generate Appcast

After uploading the zip to the URL in `NEXT_PUBLIC_DOWNLOAD_URL`:

```bash
ARCHIVE_ZIP=dist/SoundDeck-1.0.0-1.zip scripts/generate_appcast.sh
```

The archive filename must match `SoundDeck-{CFBundleShortVersionString}-{CFBundleVersion}.zip`.

Set `RELEASE_NOTES_URL` only if the release notes live somewhere other than
`https://sounddeck.app/changelog`; it must be a production HTTPS URL.

Upload the generated `dist/appcast.xml` to
`https://updates.sounddeck.app/appcast.xml`, which matches `SUFeedURL`.

## Clean-Mac Driver Smoke Test

Build the `SoundDeckInstaller` and `SoundDeckDriver` products, then run on a
clean Mac:

```bash
/path/to/SoundDeckInstaller status

INSTALLER_BIN=/path/to/SoundDeckInstaller \
DRIVER_BUNDLE=/path/to/SoundDeckDriver.driver \
scripts/smoke_test_driver.sh --install

scripts/smoke_test_driver.sh --verify

INSTALLER_BIN=/path/to/SoundDeckInstaller \
scripts/smoke_test_driver.sh --uninstall
```

The install and verify steps must find `SoundDeck Virtual Mic` in
`system_profiler SPAudioDataType`. The uninstall step must remove it.
