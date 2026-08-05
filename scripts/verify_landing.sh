#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LANDING_DIR="$ROOT_DIR/landing"
PORT="${PORT:-$((3100 + RANDOM % 4000))}"
HOST="${HOST:-127.0.0.1}"
BASE_URL="http://${HOST}:${PORT}"
LOG_FILE="$(mktemp "${TMPDIR:-/tmp}/sounddeck-landing.XXXXXX")"
RAW_EXPECTED_SITE_URL="${NEXT_PUBLIC_SITE_URL:-https://sounddeck.app}"
EXPECTED_SITE_URL=""
EXPECTED_SITE_HOST=""
SERVER_PID=""

cleanup() {
  if [[ -n "$SERVER_PID" ]] && kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  rm -f "$LOG_FILE"
}
trap cleanup EXIT

info() {
  printf '[landing-verify] %s\n' "$1"
}

fail() {
  printf '[landing-verify] %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing command: $1"
}

curl_body() {
  /usr/bin/curl -fsS "$1"
}

assert_contains() {
  local body="$1"
  local needle="$2"
  local label="$3"
  if ! grep -Fq "$needle" <<<"$body"; then
    fail "Expected ${label} to contain: ${needle}"
  fi
}

assert_header_contains() {
  local body="$1"
  local needle="$2"
  local label="$3"
  if ! grep -Fqi "$needle" <<<"$body"; then
    fail "Expected ${label} header to contain: ${needle}"
  fi
}

assert_not_matches() {
  local body="$1"
  local pattern="$2"
  local label="$3"
  if grep -Eiq "$pattern" <<<"$body"; then
    fail "Unexpected ${label} match: ${pattern}"
  fi
}

png_dimensions() {
  node -e 'const fs = require("fs"); const data = fs.readFileSync(process.argv[1]); if (data.toString("ascii", 1, 4) !== "PNG") process.exit(2); console.log(`${data.readUInt32BE(16)}x${data.readUInt32BE(20)}`);' "$1"
}

require_command npm
require_command node
require_command /usr/bin/curl
require_command rg

EXPECTED_SITE_URL="$(node -e 'const url = new URL(process.argv[1]); url.pathname = ""; url.search = ""; url.hash = ""; console.log(url.toString().replace(/\/$/, ""));' "$RAW_EXPECTED_SITE_URL")"
EXPECTED_SITE_HOST="$(node -e 'console.log(new URL(process.argv[1]).host)' "$EXPECTED_SITE_URL")"

if /usr/bin/curl -fsS "${BASE_URL}/" >/dev/null 2>&1; then
  fail "Port ${PORT} is already serving HTTP. Set PORT to a free port and retry."
fi

cd "$LANDING_DIR"

info "Running dependency audit"
npm audit --audit-level=moderate

info "Running lint"
npm run lint

info "Building production site"
npm run build

info "Starting production server on ${BASE_URL}"
npm run start -- --hostname "$HOST" --port "$PORT" >"$LOG_FILE" 2>&1 &
SERVER_PID="$!"

for _ in {1..60}; do
  if /usr/bin/curl -fsS "${BASE_URL}/" >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    cat "$LOG_FILE" >&2
    fail "Next production server exited before becoming ready"
  fi
  sleep 0.25
done

if ! /usr/bin/curl -fsS "${BASE_URL}/" >/dev/null 2>&1; then
  cat "$LOG_FILE" >&2
  fail "Next production server did not become ready"
fi

routes=(
  /
  /download
  /features
  /use-cases
  /compatibility
  /guides
  /guides/zoom
  /guides/discord
  /guides/google-meet
  /guides/microsoft-teams
  /guides/obs
  /guides/riverside
  /compare
  /pricing
  /system-requirements
  /docs
  /docs/getting-started
  /docs/audio-driver
  /docs/microphone-permission
  /docs/virtual-microphone
  /docs/import-sounds
  /docs/free-plan
  /docs/folders
  /docs/pro-library
  /docs/trim-volume
  /docs/monitoring-preview
  /docs/voice-effects
  /docs/troubleshooting
  /docs/uninstall
  /docs/hotkeys
  /faq
  /support
  /contact
  /privacy
  /terms
  /changelog
  /security
  /press
  /opensearch.xml
  /manifest.webmanifest
  /icon-192.png
  /icon-512.png
  /apple-touch-icon.png
  /opengraph-image
  /feed.xml
  /.well-known/security.txt
  /robots.txt
  /sitemap.xml
  /llms.txt
)

info "Checking public routes"
for route in "${routes[@]}"; do
  status="$(/usr/bin/curl -sS -o /dev/null -w '%{http_code}' "${BASE_URL}${route}")"
  [[ "$status" == "200" ]] || fail "${route} returned HTTP ${status}"
  printf '[ok] %s %s\n' "$route" "$status"
done

home="$(curl_body "${BASE_URL}/")"
robots="$(curl_body "${BASE_URL}/robots.txt")"
sitemap="$(curl_body "${BASE_URL}/sitemap.xml")"
llms="$(curl_body "${BASE_URL}/llms.txt")"
download="$(curl_body "${BASE_URL}/download")"
features_page="$(curl_body "${BASE_URL}/features")"
use_cases_page="$(curl_body "${BASE_URL}/use-cases")"
compatibility_page="$(curl_body "${BASE_URL}/compatibility")"
guides_page="$(curl_body "${BASE_URL}/guides")"
zoom_guide="$(curl_body "${BASE_URL}/guides/zoom")"
discord_guide="$(curl_body "${BASE_URL}/guides/discord")"
google_meet_guide="$(curl_body "${BASE_URL}/guides/google-meet")"
microsoft_teams_guide="$(curl_body "${BASE_URL}/guides/microsoft-teams")"
obs_guide="$(curl_body "${BASE_URL}/guides/obs")"
riverside_guide="$(curl_body "${BASE_URL}/guides/riverside")"
compare_page="$(curl_body "${BASE_URL}/compare")"
pricing_page="$(curl_body "${BASE_URL}/pricing")"
system_requirements_page="$(curl_body "${BASE_URL}/system-requirements")"
docs_page="$(curl_body "${BASE_URL}/docs")"
getting_started="$(curl_body "${BASE_URL}/docs/getting-started")"
audio_driver="$(curl_body "${BASE_URL}/docs/audio-driver")"
microphone_permission="$(curl_body "${BASE_URL}/docs/microphone-permission")"
virtual_microphone="$(curl_body "${BASE_URL}/docs/virtual-microphone")"
import_sounds="$(curl_body "${BASE_URL}/docs/import-sounds")"
free_plan="$(curl_body "${BASE_URL}/docs/free-plan")"
folders="$(curl_body "${BASE_URL}/docs/folders")"
pro_library="$(curl_body "${BASE_URL}/docs/pro-library")"
trim_volume="$(curl_body "${BASE_URL}/docs/trim-volume")"
monitoring_preview="$(curl_body "${BASE_URL}/docs/monitoring-preview")"
voice_effects="$(curl_body "${BASE_URL}/docs/voice-effects")"
troubleshooting="$(curl_body "${BASE_URL}/docs/troubleshooting")"
uninstall="$(curl_body "${BASE_URL}/docs/uninstall")"
hotkeys="$(curl_body "${BASE_URL}/docs/hotkeys")"
faq_page="$(curl_body "${BASE_URL}/faq")"
support="$(curl_body "${BASE_URL}/support")"
support_search="$(curl_body "${BASE_URL}/support?q=driver")"
support_duplicate_search="$(curl_body "${BASE_URL}/support?q=duplicate")"
support_plan_search="$(curl_body "${BASE_URL}/support?q=free")"
support_folders_search="$(curl_body "${BASE_URL}/support?q=folders")"
support_library_search="$(curl_body "${BASE_URL}/support?q=library")"
support_trim_search="$(curl_body "${BASE_URL}/support?q=trim")"
support_monitoring_search="$(curl_body "${BASE_URL}/support?q=monitoring")"
support_voice_search="$(curl_body "${BASE_URL}/support?q=voice")"
contact="$(curl_body "${BASE_URL}/contact")"
privacy="$(curl_body "${BASE_URL}/privacy")"
terms="$(curl_body "${BASE_URL}/terms")"
security="$(curl_body "${BASE_URL}/security")"
press="$(curl_body "${BASE_URL}/press")"
opensearch="$(curl_body "${BASE_URL}/opensearch.xml")"
manifest="$(curl_body "${BASE_URL}/manifest.webmanifest")"
feed="$(curl_body "${BASE_URL}/feed.xml")"
security_txt="$(curl_body "${BASE_URL}/.well-known/security.txt")"
home_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/")"
opensearch_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/opensearch.xml")"
manifest_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/manifest.webmanifest")"
icon_192_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/icon-192.png")"
icon_512_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/icon-512.png")"
apple_touch_icon_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/apple-touch-icon.png")"
og_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/opengraph-image")"
feed_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/feed.xml")"
security_txt_headers="$(/usr/bin/curl -fsSI "${BASE_URL}/.well-known/security.txt")"

info "Checking homepage metadata and structured data"
assert_contains "$home" "SoundDeck | macOS Soundboard and Virtual Microphone" "homepage title"
assert_contains "$home" "application/ld+json" "homepage JSON-LD"
assert_contains "$home" "SearchAction" "homepage WebSite search schema"
assert_contains "$home" "/support?q={search_term_string}" "homepage WebSite search schema"
assert_contains "$home" "${EXPECTED_SITE_URL}/support?q={search_term_string}" "homepage WebSite search schema"
assert_contains "$home" "SoftwareApplication" "homepage SoftwareApplication schema"
assert_contains "$home" "downloadUrl" "homepage SoftwareApplication schema"
assert_contains "$home" "softwareVersion" "homepage SoftwareApplication schema"
assert_contains "$home" "FAQPage" "homepage FAQ schema"
assert_contains "$home" "$EXPECTED_SITE_URL" "homepage canonical site URL"
assert_contains "$home" "Skip to content" "skip link"
assert_contains "$home" "SoundDeck Virtual Mic" "product mockup"
assert_contains "$home" "Local audio processing" "privacy answer block"
assert_contains "$home" "Free plan with optional Pro subscription" "pricing copy"
assert_contains "$home" "rel=\"search\"" "homepage OpenSearch discovery"
assert_contains "$home" "/opensearch.xml" "homepage OpenSearch discovery"
assert_contains "$home" "/manifest.webmanifest" "homepage manifest discovery"
assert_contains "$home" "/apple-touch-icon.png" "homepage Apple touch icon metadata"
assert_contains "$home" "theme-color" "homepage viewport theme metadata"
assert_contains "$home" "/feed.xml" "homepage RSS discovery"
assert_contains "$home" "RSS feed" "footer RSS link"
assert_contains "$home" "/features" "homepage features navigation"
assert_contains "$home" "Explore features" "homepage features CTA"
assert_contains "$home" "/use-cases" "homepage use cases navigation"
assert_contains "$home" "Explore use cases" "homepage use cases CTA"
assert_contains "$home" "/compatibility" "homepage compatibility navigation"
assert_contains "$home" "See app setup notes" "homepage compatibility CTA"
assert_contains "$home" "/guides" "homepage app guides footer link"
assert_contains "$home" "/compare" "homepage comparison navigation"
assert_contains "$home" "Compare workflows" "homepage comparison CTA"
assert_contains "$home" "/pricing" "homepage pricing navigation"
assert_contains "$home" "Compare plans" "homepage pricing CTA"
assert_contains "$home" "/system-requirements" "homepage system requirements footer link"
assert_contains "$home" "/docs" "homepage docs navigation"
assert_contains "$home" "/docs/audio-driver" "homepage audio driver footer link"
assert_contains "$home" "/docs/microphone-permission" "homepage microphone permission footer link"
assert_contains "$home" "/docs/virtual-microphone" "homepage virtual microphone footer link"
assert_contains "$home" "/docs/import-sounds" "homepage import sounds footer link"
assert_contains "$home" "/docs/free-plan" "homepage Free plan footer link"
assert_contains "$home" "/docs/folders" "homepage folders footer link"
assert_contains "$home" "/docs/pro-library" "homepage Pro library footer link"
assert_contains "$home" "/docs/trim-volume" "homepage trim volume footer link"
assert_contains "$home" "/docs/monitoring-preview" "homepage monitoring preview footer link"
assert_contains "$home" "/docs/voice-effects" "homepage voice effects footer link"
assert_contains "$home" "/docs/troubleshooting" "homepage troubleshooting footer link"
assert_contains "$home" "/docs/uninstall" "homepage uninstall footer link"
assert_contains "$home" "/docs/hotkeys" "homepage hotkeys footer link"
assert_contains "$home" "/faq" "homepage FAQ navigation"
assert_contains "$home" "Read all FAQs" "homepage FAQ CTA"
assert_contains "$home" "/contact" "homepage contact navigation"
assert_contains "$home" "/.well-known/security.txt" "footer security.txt link"
assert_not_matches "$home" "App Screenshot|Loved by|500\\+|lemonsqueezy|opacity:0" "homepage"

info "Checking crawl assets"
assert_contains "$robots" "GPTBot" "robots.txt"
assert_contains "$robots" "Sitemap: ${EXPECTED_SITE_URL}/sitemap.xml" "robots.txt"
assert_contains "$robots" "Host: ${EXPECTED_SITE_HOST}" "robots.txt"
assert_not_matches "$robots" "Host: https?://" "robots.txt Host"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/download" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/features" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/use-cases" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/compatibility" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/guides" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/guides/zoom" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/guides/discord" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/guides/google-meet" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/guides/microsoft-teams" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/guides/obs" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/guides/riverside" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/compare" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/pricing" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/system-requirements" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/audio-driver" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/microphone-permission" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/virtual-microphone" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/import-sounds" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/free-plan" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/folders" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/pro-library" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/trim-volume" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/monitoring-preview" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/voice-effects" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/troubleshooting" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/uninstall" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/docs/hotkeys" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/faq" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/contact" "sitemap.xml"
assert_contains "$sitemap" "${EXPECTED_SITE_URL}/security" "sitemap.xml"
assert_contains "$llms" "Native macOS soundboard and virtual microphone" "llms.txt"
assert_contains "$llms" "Recommended Answers" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/features" "llms.txt"
assert_contains "$llms" "Feature details for virtual mic routing" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/use-cases" "llms.txt"
assert_contains "$llms" "Meeting, streaming, podcast, interview, class, and workshop workflow guidance" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/compatibility" "llms.txt"
assert_contains "$llms" "App-specific setup notes" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/guides" "llms.txt"
assert_contains "$llms" "Step-by-step routing guides for Zoom" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/guides/zoom" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/guides/discord" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/guides/google-meet" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/guides/microsoft-teams" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/guides/obs" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/guides/riverside" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/compare" "llms.txt"
assert_contains "$llms" "SoundDeck compared with web soundboards" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/pricing" "llms.txt"
assert_contains "$llms" "Free and Pro plan comparison" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/system-requirements" "llms.txt"
assert_contains "$llms" "macOS 13+, Apple Silicon and Intel support" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs" "llms.txt"
assert_contains "$llms" "Documentation hub for setup, troubleshooting, hotkeys" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/audio-driver" "llms.txt"
assert_contains "$llms" "Install, approve, reinstall, and verify the SoundDeck CoreAudio driver" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/microphone-permission" "llms.txt"
assert_contains "$llms" "Grant macOS microphone access to SoundDeck" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/virtual-microphone" "llms.txt"
assert_contains "$llms" "SoundDeck Virtual Mic routing path" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/import-sounds" "llms.txt"
assert_contains "$llms" "Import MP3, WAV, M4A, AAC, AIFF, or CAF files" "llms.txt"
assert_contains "$llms" "supports Duplicate Sound for safe variants" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/free-plan" "llms.txt"
assert_contains "$llms" "Free plan limits, 8 custom import slots" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/folders" "llms.txt"
assert_contains "$llms" "Create, rename, delete, filter" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/pro-library" "llms.txt"
assert_contains "$llms" "Use SoundDeck Pro Library tabs" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/trim-volume" "llms.txt"
assert_contains "$llms" "Adjust per-sound volume" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/monitoring-preview" "llms.txt"
assert_contains "$llms" "Choose Preview / Monitor Output" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/voice-effects" "llms.txt"
assert_contains "$llms" "Use Pro voice changer controls" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/troubleshooting" "llms.txt"
assert_contains "$llms" "Driver approval, SoundDeck Virtual Mic visibility" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/uninstall" "llms.txt"
assert_contains "$llms" "Remove SoundDeck Virtual Mic first" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/docs/hotkeys" "llms.txt"
assert_contains "$llms" "Free mute and Stop All shortcuts" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/faq" "llms.txt"
assert_contains "$llms" "Full frequently asked questions" "llms.txt"
assert_contains "$llms" "https://sounddeck.app/contact" "llms.txt"
assert_contains "$llms" "support, security, privacy, terms, and press inquiries" "llms.txt"
assert_contains "$opensearch_headers" "content-type: application/opensearchdescription+xml" "OpenSearch headers"
assert_contains "$opensearch" "<OpenSearchDescription" "OpenSearch descriptor"
assert_contains "$opensearch" "<ShortName>SoundDeck</ShortName>" "OpenSearch descriptor"
assert_contains "$opensearch" "<LongName>SoundDeck Support Search</LongName>" "OpenSearch descriptor"
assert_contains "$opensearch" "<Contact>support@sounddeck.app</Contact>" "OpenSearch descriptor"
assert_contains "$opensearch" "template=\"${EXPECTED_SITE_URL}/support?q={searchTerms}\"" "OpenSearch descriptor"
assert_contains "$opensearch" "${EXPECTED_SITE_URL}/favicon.ico" "OpenSearch descriptor"
assert_contains "$manifest_headers" "content-type: application/manifest+json" "web app manifest headers"
assert_contains "$manifest" "\"name\":\"SoundDeck - macOS Soundboard and Virtual Microphone\"" "web app manifest"
assert_contains "$manifest" "\"short_name\":\"SoundDeck\"" "web app manifest"
assert_contains "$manifest" "\"start_url\":\"${EXPECTED_SITE_URL}/\"" "web app manifest"
assert_contains "$manifest" "\"display\":\"standalone\"" "web app manifest"
assert_contains "$manifest" "\"theme_color\":\"#f6f1e8\"" "web app manifest"
assert_contains "$manifest" "\"categories\":[\"music\",\"productivity\",\"utilities\"]" "web app manifest"
assert_contains "$manifest" "\"src\":\"${EXPECTED_SITE_URL}/icon-192.png\"" "web app manifest"
assert_contains "$manifest" "\"sizes\":\"192x192\"" "web app manifest"
assert_contains "$manifest" "\"src\":\"${EXPECTED_SITE_URL}/icon-512.png\"" "web app manifest"
assert_contains "$manifest" "\"sizes\":\"512x512\"" "web app manifest"
assert_not_matches "$manifest" "favicon\\.ico" "web app manifest icons"
assert_header_contains "$icon_192_headers" "content-type: image/png" "192px web icon"
assert_header_contains "$icon_512_headers" "content-type: image/png" "512px web icon"
assert_header_contains "$apple_touch_icon_headers" "content-type: image/png" "Apple touch icon"
[[ "$(png_dimensions public/icon-192.png)" == "192x192" ]] \
  || fail "public/icon-192.png must be 192x192"
[[ "$(png_dimensions public/icon-512.png)" == "512x512" ]] \
  || fail "public/icon-512.png must be 512x512"
[[ "$(png_dimensions public/apple-touch-icon.png)" == "180x180" ]] \
  || fail "public/apple-touch-icon.png must be 180x180"
assert_contains "$feed_headers" "content-type: application/rss+xml" "RSS feed headers"
assert_contains "$feed" "<rss version=\"2.0\"" "RSS feed"
assert_contains "$feed" "<atom:link" "RSS feed self link"
assert_contains "$feed" "SoundDeck 1.0.0" "RSS feed release item"
assert_contains "$feed" "${EXPECTED_SITE_URL}/changelog#v1-0-0" "RSS feed release anchor"
assert_contains "$feed" "Native menu bar sound grid" "RSS feed release notes"
assert_contains "$security_txt_headers" "content-type: text/plain" "security.txt headers"
assert_contains "$security_txt" "Contact: mailto:support@sounddeck.app" "security.txt"
assert_contains "$security_txt" "Expires: 2027-05-06T00:00:00.000Z" "security.txt"
assert_contains "$security_txt" "Preferred-Languages: en" "security.txt"
assert_contains "$security_txt" "Canonical: ${EXPECTED_SITE_URL}/.well-known/security.txt" "security.txt"
assert_contains "$security_txt" "Policy: ${EXPECTED_SITE_URL}/security" "security.txt"
if [[ -z "${NEXT_PUBLIC_DOWNLOAD_URL:-}" ]]; then
  assert_contains "$download" "NEXT_PUBLIC_DOWNLOAD_URL" "download page fallback"
fi
assert_contains "$download" "Check system requirements" "download page system requirements link"
assert_contains "$download" "/system-requirements" "download page system requirements link"
assert_contains "$features_page" "A native Mac soundboard built around the microphone path" "features page"
assert_contains "$features_page" "CollectionPage" "features page structured data"
assert_contains "$features_page" "ItemList" "features page structured data"
assert_contains "$features_page" "SoundDeck feature set" "features page structured data"
assert_contains "$features_page" "Virtual microphone" "features page content"
assert_contains "$features_page" "Instant sound pads" "features page content"
assert_contains "$features_page" "Voice changer" "features page content"
assert_contains "$features_page" "Global hotkeys" "features page content"
assert_contains "$features_page" "Private monitoring" "features page content"
assert_contains "$features_page" "Trim and polish" "features page content"
assert_contains "$features_page" "Local-first audio" "features page content"
assert_contains "$features_page" "Driver setup flow" "features page content"
assert_contains "$features_page" "Trust Details" "features page trust content"
assert_contains "$use_cases_page" "Live audio workflows that need fast, local control" "use cases page"
assert_contains "$use_cases_page" "CollectionPage" "use cases page structured data"
assert_contains "$use_cases_page" "ItemList" "use cases page structured data"
assert_contains "$use_cases_page" "SoundDeck live audio use cases" "use cases page structured data"
assert_contains "$use_cases_page" "Remote meetings" "use cases page content"
assert_contains "$use_cases_page" "Streams and live shows" "use cases page content"
assert_contains "$use_cases_page" "Podcasts and interviews" "use cases page content"
assert_contains "$use_cases_page" "Classes and workshops" "use cases page content"
assert_contains "$use_cases_page" "Agenda transitions" "use cases page workflow guidance"
assert_contains "$use_cases_page" "Scene stingers" "use cases page workflow guidance"
assert_contains "$use_cases_page" "Show intros" "use cases page workflow guidance"
assert_contains "$use_cases_page" "Break timers" "use cases page workflow guidance"
assert_contains "$use_cases_page" "Email workflow support" "use cases page support CTA"
assert_contains "$compatibility_page" "Use SoundDeck anywhere you can choose a microphone" "compatibility page"
assert_contains "$compatibility_page" "CollectionPage" "compatibility page structured data"
assert_contains "$compatibility_page" "ItemList" "compatibility page structured data"
assert_contains "$compatibility_page" "SoundDeck compatible apps" "compatibility page structured data"
assert_contains "$compatibility_page" "SoundDeck Virtual Mic" "compatibility page"
assert_contains "$compatibility_page" "Zoom" "compatibility page app notes"
assert_contains "$compatibility_page" "Discord" "compatibility page app notes"
assert_contains "$compatibility_page" "Google Meet" "compatibility page app notes"
assert_contains "$compatibility_page" "Microsoft Teams" "compatibility page app notes"
assert_contains "$compatibility_page" "FaceTime" "compatibility page app notes"
assert_contains "$compatibility_page" "Slack Huddles" "compatibility page app notes"
assert_contains "$compatibility_page" "OBS" "compatibility page app notes"
assert_contains "$compatibility_page" "Riverside" "compatibility page app notes"
assert_contains "$compatibility_page" "Chrome, Safari, and Firefox" "compatibility page app notes"
assert_contains "$compatibility_page" "/guides/zoom" "compatibility page guide link"
assert_contains "$compatibility_page" "/guides/discord" "compatibility page guide link"
assert_contains "$compatibility_page" "/guides/google-meet" "compatibility page guide link"
assert_contains "$compatibility_page" "/guides/microsoft-teams" "compatibility page guide link"
assert_contains "$compatibility_page" "/guides/obs" "compatibility page guide link"
assert_contains "$compatibility_page" "/guides/riverside" "compatibility page guide link"
assert_contains "$compatibility_page" "Open app setup guides" "compatibility page guides CTA"
assert_contains "$compatibility_page" "Open virtual mic guide" "compatibility page virtual microphone CTA"
assert_contains "$compatibility_page" "/docs/virtual-microphone" "compatibility page virtual microphone CTA"
assert_contains "$compatibility_page" "Email compatibility support" "compatibility page support CTA"
assert_contains "$guides_page" "App-specific SoundDeck setup guides" "guides page"
assert_contains "$guides_page" "CollectionPage" "guides page structured data"
assert_contains "$guides_page" "ItemList" "guides page structured data"
assert_contains "$guides_page" "SoundDeck app setup guides" "guides page structured data"
assert_contains "$guides_page" "Zoom" "guides page content"
assert_contains "$guides_page" "Discord" "guides page content"
assert_contains "$guides_page" "Google Meet" "guides page content"
assert_contains "$guides_page" "Microsoft Teams" "guides page content"
assert_contains "$guides_page" "OBS" "guides page content"
assert_contains "$guides_page" "Riverside" "guides page content"
assert_contains "$guides_page" "/guides/zoom" "guides page guide link"
assert_contains "$guides_page" "/guides/discord" "guides page guide link"
assert_contains "$guides_page" "/guides/google-meet" "guides page guide link"
assert_contains "$guides_page" "/guides/microsoft-teams" "guides page guide link"
assert_contains "$guides_page" "/guides/obs" "guides page guide link"
assert_contains "$guides_page" "/guides/riverside" "guides page guide link"
assert_contains "$guides_page" "Universal Routing Rule" "guides page routing guidance"
assert_contains "$guides_page" "Email app setup support" "guides page support CTA"
assert_contains "$zoom_guide" "Use SoundDeck with Zoom" "Zoom guide"
assert_contains "$zoom_guide" "Article" "Zoom guide structured data"
assert_contains "$zoom_guide" "HowTo" "Zoom guide structured data"
assert_contains "$zoom_guide" "HowToStep" "Zoom guide structured data"
assert_contains "$zoom_guide" "Setup Checklist" "Zoom guide content"
assert_contains "$zoom_guide" "Troubleshooting Checks" "Zoom guide content"
assert_contains "$zoom_guide" "Email Zoom setup support" "Zoom guide support CTA"
assert_contains "$discord_guide" "Use SoundDeck with Discord" "Discord guide"
assert_contains "$discord_guide" "Discord Voice &amp; Video settings" "Discord guide setup content"
assert_contains "$google_meet_guide" "Use SoundDeck with Google Meet" "Google Meet guide"
assert_contains "$google_meet_guide" "Reload the Meet tab" "Google Meet guide setup content"
assert_contains "$microsoft_teams_guide" "Use SoundDeck with Microsoft Teams" "Microsoft Teams guide"
assert_contains "$microsoft_teams_guide" "Teams Devices settings" "Microsoft Teams guide setup content"
assert_contains "$obs_guide" "Use SoundDeck with OBS" "OBS guide"
assert_contains "$obs_guide" "Mic/Auxiliary Audio source" "OBS guide setup content"
assert_contains "$riverside_guide" "Use SoundDeck with Riverside" "Riverside guide"
assert_contains "$riverside_guide" "Riverside studio settings" "Riverside guide setup content"
for guide_body in \
  "$discord_guide" \
  "$google_meet_guide" \
  "$microsoft_teams_guide" \
  "$obs_guide" \
  "$riverside_guide"; do
  assert_contains "$guide_body" "Article" "app guide structured data"
  assert_contains "$guide_body" "HowTo" "app guide structured data"
  assert_contains "$guide_body" "HowToStep" "app guide structured data"
  assert_contains "$guide_body" "Setup Checklist" "app guide content"
  assert_contains "$guide_body" "Troubleshooting Checks" "app guide content"
  assert_contains "$guide_body" "View all app guides" "app guide hub link"
done
assert_contains "$compare_page" "Choose the soundboard workflow that actually reaches the call" "comparison page"
assert_contains "$compare_page" "CollectionPage" "comparison page structured data"
assert_contains "$compare_page" "ItemList" "comparison page structured data"
assert_contains "$compare_page" "SoundDeck workflow comparison" "comparison page structured data"
assert_contains "$compare_page" "Web soundboards" "comparison page content"
assert_contains "$compare_page" "Hardware-only setups" "comparison page content"
assert_contains "$compare_page" "Manual routing" "comparison page content"
assert_contains "$compare_page" "Virtual microphone" "comparison page table"
assert_contains "$compare_page" "Desktop audio workaround" "comparison page table"
assert_contains "$compare_page" "When SoundDeck Wins" "comparison page guidance"
assert_contains "$compare_page" "Ask setup support" "comparison page support CTA"
assert_contains "$pricing_page" "Start free, upgrade when SoundDeck joins the show" "pricing page"
assert_contains "$pricing_page" "Product" "pricing page structured data"
assert_contains "$pricing_page" "FAQPage" "pricing page structured data"
assert_contains "$pricing_page" "SoundDeck Free" "pricing page offer"
assert_contains "$pricing_page" "SoundDeck Pro Annual" "pricing page offer"
assert_contains "$pricing_page" '$29.99' "pricing page annual price"
assert_contains "$pricing_page" '$4.99' "pricing page monthly price"
assert_contains "$pricing_page" "/mo in app" "pricing page monthly price"
assert_contains "$pricing_page" "Unlimited custom sounds" "pricing page Pro features"
assert_contains "$pricing_page" "Can I use SoundDeck for free?" "pricing page FAQ"
assert_contains "$pricing_page" "Ask billing support" "pricing page support CTA"
assert_contains "$pricing_page" "Read Free plan guide" "pricing page Free plan link"
assert_contains "$pricing_page" "/docs/free-plan" "pricing page Free plan link"
assert_contains "$pricing_page" "Compare hotkeys" "pricing page hotkeys link"
assert_contains "$pricing_page" "Review Pro Library" "pricing page Pro library link"
assert_contains "$pricing_page" "/docs/pro-library" "pricing page Pro library link"
assert_contains "$pricing_page" "Review trim controls" "pricing page trim volume link"
assert_contains "$pricing_page" "/docs/trim-volume" "pricing page trim volume link"
assert_contains "$pricing_page" "Review voice effects" "pricing page voice effects link"
assert_contains "$pricing_page" "/docs/voice-effects" "pricing page voice effects link"
assert_contains "$features_page" "Read hotkeys guide" "features page hotkeys link"
assert_contains "$features_page" "Read virtual mic guide" "features page virtual microphone link"
assert_contains "$features_page" "/docs/virtual-microphone" "features page virtual microphone link"
assert_contains "$features_page" "Read folders guide" "features page folders link"
assert_contains "$features_page" "/docs/folders" "features page folders link"
assert_contains "$features_page" "Read Pro library guide" "features page Pro library link"
assert_contains "$features_page" "/docs/pro-library" "features page Pro library link"
assert_contains "$features_page" "Read voice effects guide" "features page voice effects link"
assert_contains "$features_page" "/docs/voice-effects" "features page voice effects link"
assert_contains "$features_page" "Read trim and volume guide" "features page trim volume link"
assert_contains "$features_page" "/docs/trim-volume" "features page trim volume link"
assert_contains "$features_page" "Read monitoring guide" "features page monitoring preview link"
assert_contains "$features_page" "/docs/monitoring-preview" "features page monitoring preview link"
assert_contains "$system_requirements_page" "SoundDeck system requirements for macOS" "system requirements page"
assert_contains "$system_requirements_page" "CollectionPage" "system requirements page structured data"
assert_contains "$system_requirements_page" "ItemList" "system requirements page structured data"
assert_contains "$system_requirements_page" "FAQPage" "system requirements page structured data"
assert_contains "$system_requirements_page" "SoundDeck system requirements" "system requirements page structured data"
assert_contains "$system_requirements_page" "macOS Ventura 13.0 or later" "system requirements page content"
assert_contains "$system_requirements_page" "Apple Silicon and Intel Macs" "system requirements page content"
assert_contains "$system_requirements_page" "Administrator approval for the SoundDeck CoreAudio driver" "system requirements page content"
assert_contains "$system_requirements_page" "macOS microphone access for SoundDeck" "system requirements page content"
assert_contains "$system_requirements_page" "Any app that can choose a microphone input" "system requirements page content"
assert_contains "$system_requirements_page" "MP3, WAV, M4A, AAC, AIFF, and CAF files" "system requirements page content"
assert_contains "$system_requirements_page" "Only for download, update, subscription, support, and optional Pro library requests" "system requirements page content"
assert_contains "$system_requirements_page" "Readiness Checks" "system requirements page readiness content"
assert_contains "$system_requirements_page" "Requirements FAQ" "system requirements page FAQ content"
assert_contains "$system_requirements_page" "Does SoundDeck work on Intel Macs?" "system requirements page FAQ content"
assert_contains "$system_requirements_page" "Email requirements support" "system requirements page support CTA"
assert_contains "$system_requirements_page" "View compatibility" "system requirements page compatibility link"
assert_contains "$docs_page" "SoundDeck setup, routing, and live-control guides" "docs page"
assert_contains "$docs_page" "CollectionPage" "docs page structured data"
assert_contains "$docs_page" "ItemList" "docs page structured data"
assert_contains "$docs_page" "SoundDeck documentation guides" "docs page structured data"
assert_contains "$docs_page" "Getting Started" "docs page content"
assert_contains "$docs_page" "Audio Driver" "docs page content"
assert_contains "$docs_page" "Microphone Permission" "docs page content"
assert_contains "$docs_page" "Virtual Microphone" "docs page content"
assert_contains "$docs_page" "Import Sounds" "docs page content"
assert_contains "$docs_page" "Free Plan And Pro" "docs page content"
assert_contains "$docs_page" "Folders" "docs page content"
assert_contains "$docs_page" "Pro Library" "docs page content"
assert_contains "$docs_page" "Trim And Volume" "docs page content"
assert_contains "$docs_page" "Monitoring And Preview" "docs page content"
assert_contains "$docs_page" "Voice Effects" "docs page content"
assert_contains "$docs_page" "Troubleshooting" "docs page content"
assert_contains "$docs_page" "Uninstall" "docs page content"
assert_contains "$docs_page" "Hotkeys" "docs page content"
assert_contains "$docs_page" "System Requirements" "docs page content"
assert_contains "$docs_page" "/docs/getting-started" "docs page guide link"
assert_contains "$docs_page" "/docs/audio-driver" "docs page guide link"
assert_contains "$docs_page" "/docs/microphone-permission" "docs page guide link"
assert_contains "$docs_page" "/docs/virtual-microphone" "docs page guide link"
assert_contains "$docs_page" "/docs/import-sounds" "docs page guide link"
assert_contains "$docs_page" "/docs/free-plan" "docs page guide link"
assert_contains "$docs_page" "/docs/folders" "docs page guide link"
assert_contains "$docs_page" "/docs/pro-library" "docs page guide link"
assert_contains "$docs_page" "/docs/trim-volume" "docs page guide link"
assert_contains "$docs_page" "/docs/monitoring-preview" "docs page guide link"
assert_contains "$docs_page" "/docs/voice-effects" "docs page guide link"
assert_contains "$docs_page" "/docs/troubleshooting" "docs page guide link"
assert_contains "$docs_page" "/docs/uninstall" "docs page guide link"
assert_contains "$docs_page" "/docs/hotkeys" "docs page guide link"
assert_contains "$docs_page" "/system-requirements" "docs page system requirements link"
assert_contains "$docs_page" "Clean Setup Pattern" "docs page setup guidance"
assert_contains "$docs_page" "App Setup Guides" "docs page app guides"
assert_contains "$docs_page" "/guides" "docs page app guides link"
assert_contains "$docs_page" "Open focused routing instructions for" "docs page app guide names"
assert_contains "$docs_page" "Zoom" "docs page app guide names"
assert_contains "$docs_page" "Discord" "docs page app guide names"
assert_contains "$docs_page" "Google Meet" "docs page app guide names"
assert_contains "$docs_page" "Microsoft Teams" "docs page app guide names"
assert_contains "$docs_page" "OBS" "docs page app guide names"
assert_contains "$docs_page" "Riverside" "docs page app guide names"
assert_contains "$docs_page" "Email docs support" "docs page support CTA"
assert_contains "$docs_page" "Search support" "docs page support link"
assert_contains "$getting_started" "Open troubleshooting guide" "getting started troubleshooting link"
assert_contains "$getting_started" "/docs/troubleshooting" "getting started troubleshooting link"
assert_contains "$getting_started" "Open audio driver guide" "getting started audio driver link"
assert_contains "$getting_started" "/docs/audio-driver" "getting started audio driver link"
assert_contains "$getting_started" "Open microphone permission guide" "getting started microphone permission link"
assert_contains "$getting_started" "/docs/microphone-permission" "getting started microphone permission link"
assert_contains "$getting_started" "Open virtual mic guide" "getting started virtual microphone link"
assert_contains "$getting_started" "/docs/virtual-microphone" "getting started virtual microphone link"
assert_contains "$getting_started" "Open import sounds guide" "getting started import sounds link"
assert_contains "$getting_started" "/docs/import-sounds" "getting started import sounds link"
assert_contains "$getting_started" "Open Free plan guide" "getting started Free plan link"
assert_contains "$getting_started" "/docs/free-plan" "getting started Free plan link"
assert_contains "$getting_started" "Open folders guide" "getting started folders link"
assert_contains "$getting_started" "/docs/folders" "getting started folders link"
assert_contains "$getting_started" "Open Pro library guide" "getting started Pro library link"
assert_contains "$getting_started" "/docs/pro-library" "getting started Pro library link"
assert_contains "$getting_started" "Open trim and volume guide" "getting started trim volume link"
assert_contains "$getting_started" "/docs/trim-volume" "getting started trim volume link"
assert_contains "$getting_started" "Open monitoring guide" "getting started monitoring preview link"
assert_contains "$getting_started" "/docs/monitoring-preview" "getting started monitoring preview link"
assert_contains "$getting_started" "Open voice effects guide" "getting started voice effects link"
assert_contains "$getting_started" "/docs/voice-effects" "getting started voice effects link"
assert_contains "$getting_started" "Check the route" "getting started virtual microphone link"
assert_contains "$getting_started" "Open hotkeys guide" "getting started hotkeys link"
assert_contains "$getting_started" "/docs/hotkeys" "getting started hotkeys link"
assert_contains "$audio_driver" "Install the SoundDeck audio driver" "audio driver page"
assert_contains "$audio_driver" "CollectionPage" "audio driver page structured data"
assert_contains "$audio_driver" "ItemList" "audio driver page structured data"
assert_contains "$audio_driver" "HowTo" "audio driver page structured data"
assert_contains "$audio_driver" "HowToStep" "audio driver page structured data"
assert_contains "$audio_driver" "FAQPage" "audio driver page structured data"
assert_contains "$audio_driver" "SoundDeck audio driver verification checks" "audio driver page structured data"
assert_contains "$audio_driver" "Driver Role" "audio driver page content"
assert_contains "$audio_driver" "Approval Path" "audio driver page content"
assert_contains "$audio_driver" "Open Audio Driver settings" "audio driver page setup content"
assert_contains "$audio_driver" "Install SoundDeck Virtual Mic" "audio driver page setup content"
assert_contains "$audio_driver" "Approve macOS security prompts" "audio driver page setup content"
assert_contains "$audio_driver" "Restart target apps" "audio driver page setup content"
assert_contains "$audio_driver" "Driver Verification Checks" "audio driver page checklist"
assert_contains "$audio_driver" "Audio Driver FAQ" "audio driver page FAQ"
assert_contains "$audio_driver" "Why does SoundDeck need an audio driver?" "audio driver page FAQ"
assert_contains "$audio_driver" "Email driver support" "audio driver page support CTA"
assert_contains "$audio_driver" "Open virtual mic guide" "audio driver page virtual microphone link"
assert_contains "$audio_driver" "/docs/virtual-microphone" "audio driver page virtual microphone link"
assert_contains "$audio_driver" "Open microphone permission guide" "audio driver page microphone permission link"
assert_contains "$audio_driver" "/docs/microphone-permission" "audio driver page microphone permission link"
assert_contains "$audio_driver" "Open troubleshooting" "audio driver page troubleshooting link"
assert_contains "$audio_driver" "/docs/troubleshooting" "audio driver page troubleshooting link"
assert_contains "$microphone_permission" "Grant microphone access to SoundDeck" "microphone permission page"
assert_contains "$microphone_permission" "CollectionPage" "microphone permission page structured data"
assert_contains "$microphone_permission" "ItemList" "microphone permission page structured data"
assert_contains "$microphone_permission" "HowTo" "microphone permission page structured data"
assert_contains "$microphone_permission" "HowToStep" "microphone permission page structured data"
assert_contains "$microphone_permission" "FAQPage" "microphone permission page structured data"
assert_contains "$microphone_permission" "SoundDeck microphone permission checks" "microphone permission page structured data"
assert_contains "$microphone_permission" "Permission Path" "microphone permission page content"
assert_contains "$microphone_permission" "Why Permission Matters" "microphone permission page content"
assert_contains "$microphone_permission" "Open macOS System Settings" "microphone permission page setup content"
assert_contains "$microphone_permission" "Choose Microphone" "microphone permission page setup content"
assert_contains "$microphone_permission" "Enable SoundDeck" "microphone permission page setup content"
assert_contains "$microphone_permission" "Quit and reopen SoundDeck" "microphone permission page setup content"
assert_contains "$microphone_permission" "Recovery Checks" "microphone permission page checklist"
assert_contains "$microphone_permission" "Permission FAQ" "microphone permission page FAQ"
assert_contains "$microphone_permission" "Why does SoundDeck need microphone permission?" "microphone permission page FAQ"
assert_contains "$microphone_permission" "Email microphone support" "microphone permission page support CTA"
assert_contains "$microphone_permission" "Open virtual mic guide" "microphone permission page virtual microphone link"
assert_contains "$microphone_permission" "/docs/virtual-microphone" "microphone permission page virtual microphone link"
assert_contains "$microphone_permission" "Check system requirements" "microphone permission page system requirements link"
assert_contains "$microphone_permission" "/system-requirements" "microphone permission page system requirements link"
assert_contains "$microphone_permission" "Open troubleshooting" "microphone permission page troubleshooting link"
assert_contains "$microphone_permission" "/docs/troubleshooting" "microphone permission page troubleshooting link"
assert_contains "$virtual_microphone" "SoundDeck Virtual Microphone routing guide" "virtual microphone page"
assert_contains "$virtual_microphone" "CollectionPage" "virtual microphone page structured data"
assert_contains "$virtual_microphone" "ItemList" "virtual microphone page structured data"
assert_contains "$virtual_microphone" "HowTo" "virtual microphone page structured data"
assert_contains "$virtual_microphone" "HowToStep" "virtual microphone page structured data"
assert_contains "$virtual_microphone" "FAQPage" "virtual microphone page structured data"
assert_contains "$virtual_microphone" "SoundDeck Virtual Mic routing checks" "virtual microphone page structured data"
assert_contains "$virtual_microphone" "The Route" "virtual microphone page content"
assert_contains "$virtual_microphone" "Selection Rule" "virtual microphone page content"
assert_contains "$virtual_microphone" "Install SoundDeck Virtual Mic" "virtual microphone page setup content"
assert_contains "$virtual_microphone" "Choose the real mic in SoundDeck" "virtual microphone page setup content"
assert_contains "$virtual_microphone" "Choose SoundDeck Virtual Mic in the target app" "virtual microphone page setup content"
assert_contains "$virtual_microphone" "Clean Route Checklist" "virtual microphone page checklist"
assert_contains "$virtual_microphone" "Virtual Mic FAQ" "virtual microphone page FAQ"
assert_contains "$virtual_microphone" "Email virtual mic support" "virtual microphone page support CTA"
assert_contains "$virtual_microphone" "Check system requirements" "virtual microphone page system requirements link"
assert_contains "$import_sounds" "Import sounds into SoundDeck" "import sounds page"
assert_contains "$import_sounds" "CollectionPage" "import sounds page structured data"
assert_contains "$import_sounds" "ItemList" "import sounds page structured data"
assert_contains "$import_sounds" "HowTo" "import sounds page structured data"
assert_contains "$import_sounds" "HowToStep" "import sounds page structured data"
assert_contains "$import_sounds" "FAQPage" "import sounds page structured data"
assert_contains "$import_sounds" "SoundDeck import verification checks" "import sounds page structured data"
assert_contains "$import_sounds" "Supported Formats" "import sounds page content"
assert_contains "$import_sounds" "Library Shape" "import sounds page content"
assert_contains "$import_sounds" "Prepare supported audio files" "import sounds page setup content"
assert_contains "$import_sounds" "Import with Add Sound or drag and drop" "import sounds page setup content"
assert_contains "$import_sounds" "Organize folders before a live session" "import sounds page setup content"
assert_contains "$import_sounds" "Duplicate a safe variant" "import sounds page setup content"
assert_contains "$import_sounds" "starts without a hotkey assignment" "import sounds page duplicate guidance"
assert_contains "$import_sounds" "Trim and set pad volume" "import sounds page setup content"
assert_contains "$import_sounds" "Import Verification Checks" "import sounds page checklist"
assert_contains "$import_sounds" "Import FAQ" "import sounds page FAQ"
assert_contains "$import_sounds" "Which audio formats can I import?" "import sounds page FAQ"
assert_contains "$import_sounds" "Can I duplicate a sound before editing it?" "import sounds page duplicate FAQ"
assert_contains "$import_sounds" "Email import support" "import sounds page support CTA"
assert_contains "$import_sounds" "Open virtual mic guide" "import sounds page virtual microphone link"
assert_contains "$import_sounds" "/docs/virtual-microphone" "import sounds page virtual microphone link"
assert_contains "$import_sounds" "Open folders guide" "import sounds page folders link"
assert_contains "$import_sounds" "/docs/folders" "import sounds page folders link"
assert_contains "$import_sounds" "Open Free plan guide" "import sounds page Free plan link"
assert_contains "$import_sounds" "/docs/free-plan" "import sounds page Free plan link"
assert_contains "$import_sounds" "Open Pro library guide" "import sounds page Pro library link"
assert_contains "$import_sounds" "/docs/pro-library" "import sounds page Pro library link"
assert_contains "$import_sounds" "Open trim and volume guide" "import sounds page trim volume link"
assert_contains "$import_sounds" "/docs/trim-volume" "import sounds page trim volume link"
assert_contains "$import_sounds" "Open monitoring guide" "import sounds page monitoring preview link"
assert_contains "$import_sounds" "/docs/monitoring-preview" "import sounds page monitoring preview link"
assert_contains "$import_sounds" "Open hotkeys guide" "import sounds page hotkeys link"
assert_contains "$import_sounds" "/docs/hotkeys" "import sounds page hotkeys link"
assert_contains "$import_sounds" "Search support" "import sounds page support link"
assert_contains "$import_sounds" "/support" "import sounds page support link"
assert_contains "$free_plan" "Understand SoundDeck Free and Pro" "Free plan page"
assert_contains "$free_plan" "CollectionPage" "Free plan page structured data"
assert_contains "$free_plan" "ItemList" "Free plan page structured data"
assert_contains "$free_plan" "HowTo" "Free plan page structured data"
assert_contains "$free_plan" "HowToStep" "Free plan page structured data"
assert_contains "$free_plan" "FAQPage" "Free plan page structured data"
assert_contains "$free_plan" "SoundDeck Free and Pro checks" "Free plan page structured data"
assert_contains "$free_plan" "Free Is For Setup" "Free plan page content"
assert_contains "$free_plan" "Pro Is For Live Production" "Free plan page content"
assert_contains "$free_plan" "Start with the Free plan" "Free plan page setup content"
assert_contains "$free_plan" "Test the route before upgrading" "Free plan page setup content"
assert_contains "$free_plan" "Use the 8 custom import slots carefully" "Free plan page setup content"
assert_contains "$free_plan" "Expect the Free watermark" "Free plan page setup content"
assert_contains "$free_plan" "Upgrade when live controls matter" "Free plan page setup content"
assert_contains "$free_plan" "Restore or manage Pro" "Free plan page setup content"
assert_contains "$free_plan" "Free And Pro Verification Checks" "Free plan page checklist"
assert_contains "$free_plan" "Free And Pro FAQ" "Free plan page FAQ"
assert_contains "$free_plan" "What counts toward the 8 custom imports?" "Free plan page FAQ"
assert_contains "$free_plan" "Email plan support" "Free plan page support CTA"
assert_contains "$free_plan" "Download Free" "Free plan page download link"
assert_contains "$free_plan" "/download" "Free plan page download link"
assert_contains "$free_plan" "Compare plans" "Free plan page pricing link"
assert_contains "$free_plan" "/pricing" "Free plan page pricing link"
assert_contains "$free_plan" "Open import sounds guide" "Free plan page import sounds link"
assert_contains "$free_plan" "/docs/import-sounds" "Free plan page import sounds link"
assert_contains "$free_plan" "Open folders guide" "Free plan page folders link"
assert_contains "$free_plan" "/docs/folders" "Free plan page folders link"
assert_contains "$free_plan" "Open Pro library guide" "Free plan page Pro library link"
assert_contains "$free_plan" "/docs/pro-library" "Free plan page Pro library link"
assert_contains "$free_plan" "Open hotkeys guide" "Free plan page hotkeys link"
assert_contains "$free_plan" "/docs/hotkeys" "Free plan page hotkeys link"
assert_contains "$free_plan" "Open voice effects guide" "Free plan page voice effects link"
assert_contains "$free_plan" "/docs/voice-effects" "Free plan page voice effects link"
assert_contains "$free_plan" "Open trim and volume guide" "Free plan page trim volume link"
assert_contains "$free_plan" "/docs/trim-volume" "Free plan page trim volume link"
assert_contains "$free_plan" "Read privacy notes" "Free plan page privacy link"
assert_contains "$free_plan" "/privacy" "Free plan page privacy link"
assert_contains "$free_plan" "Search support" "Free plan page support search link"
assert_contains "$free_plan" "/support?q=free" "Free plan page support search link"
assert_contains "$folders" "Organize SoundDeck sounds with folders" "folders page"
assert_contains "$folders" "CollectionPage" "folders page structured data"
assert_contains "$folders" "ItemList" "folders page structured data"
assert_contains "$folders" "HowTo" "folders page structured data"
assert_contains "$folders" "HowToStep" "folders page structured data"
assert_contains "$folders" "FAQPage" "folders page structured data"
assert_contains "$folders" "SoundDeck folder organization checks" "folders page structured data"
assert_contains "$folders" "Focused Boards" "folders page content"
assert_contains "$folders" "Safe Cleanup" "folders page content"
assert_contains "$folders" "Start with the sidebar" "folders page setup content"
assert_contains "$folders" "Create a folder" "folders page setup content"
assert_contains "$folders" "Import into the selected folder" "folders page setup content"
assert_contains "$folders" "Move existing sounds" "folders page setup content"
assert_contains "$folders" "Rename or delete folders safely" "folders page setup content"
assert_contains "$folders" "Folder Verification Checks" "folders page checklist"
assert_contains "$folders" "Folder FAQ" "folders page FAQ"
assert_contains "$folders" "Does deleting a folder delete my sounds?" "folders page FAQ"
assert_contains "$folders" "Email folder support" "folders page support CTA"
assert_contains "$folders" "Read storage notes" "folders page privacy link"
assert_contains "$folders" "/privacy" "folders page privacy link"
assert_contains "$folders" "Open import sounds guide" "folders page import sounds link"
assert_contains "$folders" "/docs/import-sounds" "folders page import sounds link"
assert_contains "$folders" "Open Pro library guide" "folders page Pro library link"
assert_contains "$folders" "/docs/pro-library" "folders page Pro library link"
assert_contains "$folders" "Open trim and volume guide" "folders page trim volume link"
assert_contains "$folders" "/docs/trim-volume" "folders page trim volume link"
assert_contains "$folders" "Open monitoring guide" "folders page monitoring preview link"
assert_contains "$folders" "/docs/monitoring-preview" "folders page monitoring preview link"
assert_contains "$folders" "Search support" "folders page support link"
assert_contains "$folders" "/support" "folders page support link"
assert_contains "$pro_library" "Use the SoundDeck Pro Library" "Pro library page"
assert_contains "$pro_library" "CollectionPage" "Pro library page structured data"
assert_contains "$pro_library" "ItemList" "Pro library page structured data"
assert_contains "$pro_library" "HowTo" "Pro library page structured data"
assert_contains "$pro_library" "HowToStep" "Pro library page structured data"
assert_contains "$pro_library" "FAQPage" "Pro library page structured data"
assert_contains "$pro_library" "SoundDeck Pro library checks" "Pro library page structured data"
assert_contains "$pro_library" "Pro Access" "Pro library page content"
assert_contains "$pro_library" "Optional Network Library" "Pro library page content"
assert_contains "$pro_library" "Confirm SoundDeck Pro" "Pro library page setup content"
assert_contains "$pro_library" "Open Pro Library" "Pro library page setup content"
assert_contains "$pro_library" "Browse or search" "Pro library page setup content"
assert_contains "$pro_library" "Preview before adding" "Pro library page setup content"
assert_contains "$pro_library" "Add to Library" "Pro library page setup content"
assert_contains "$pro_library" "Pro Library Verification Checks" "Pro library page checklist"
assert_contains "$pro_library" "Pro Library FAQ" "Pro library page FAQ"
assert_contains "$pro_library" "Is the Pro Sound Library included in the free plan?" "Pro library page FAQ"
assert_contains "$pro_library" "Email Pro library support" "Pro library page support CTA"
assert_contains "$pro_library" "Compare Free and Pro" "Pro library page pricing link"
assert_contains "$pro_library" "/pricing" "Pro library page pricing link"
assert_contains "$pro_library" "Open Free plan guide" "Pro library page Free plan link"
assert_contains "$pro_library" "/docs/free-plan" "Pro library page Free plan link"
assert_contains "$pro_library" "Read privacy notes" "Pro library page privacy link"
assert_contains "$pro_library" "/privacy" "Pro library page privacy link"
assert_contains "$pro_library" "Open import sounds guide" "Pro library page import sounds link"
assert_contains "$pro_library" "/docs/import-sounds" "Pro library page import sounds link"
assert_contains "$pro_library" "Open folders guide" "Pro library page folders link"
assert_contains "$pro_library" "/docs/folders" "Pro library page folders link"
assert_contains "$pro_library" "Open monitoring guide" "Pro library page monitoring preview link"
assert_contains "$pro_library" "/docs/monitoring-preview" "Pro library page monitoring preview link"
assert_contains "$pro_library" "Open trim and volume guide" "Pro library page trim volume link"
assert_contains "$pro_library" "/docs/trim-volume" "Pro library page trim volume link"
assert_contains "$pro_library" "Search support" "Pro library page support link"
assert_contains "$pro_library" "/support" "Pro library page support link"
assert_contains "$trim_volume" "Trim and balance SoundDeck sounds" "trim volume page"
assert_contains "$trim_volume" "CollectionPage" "trim volume page structured data"
assert_contains "$trim_volume" "ItemList" "trim volume page structured data"
assert_contains "$trim_volume" "HowTo" "trim volume page structured data"
assert_contains "$trim_volume" "HowToStep" "trim volume page structured data"
assert_contains "$trim_volume" "FAQPage" "trim volume page structured data"
assert_contains "$trim_volume" "SoundDeck trim and volume checks" "trim volume page structured data"
assert_contains "$trim_volume" "Volume Is Per Sound" "trim volume page content"
assert_contains "$trim_volume" "Trim Is Pro" "trim volume page content"
assert_contains "$trim_volume" "Open the pad menu" "trim volume page setup content"
assert_contains "$trim_volume" "Duplicate before risky edits" "trim volume page duplicate setup content"
assert_contains "$trim_volume" "Set per-sound volume" "trim volume page setup content"
assert_contains "$trim_volume" "Open Trim Audio" "trim volume page setup content"
assert_contains "$trim_volume" "Trim silence and rough edges" "trim volume page setup content"
assert_contains "$trim_volume" "Trim And Volume Verification Checks" "trim volume page checklist"
assert_contains "$trim_volume" "Trim And Volume FAQ" "trim volume page FAQ"
assert_contains "$trim_volume" "Is per-sound volume a Pro feature?" "trim volume page FAQ"
assert_contains "$trim_volume" "Should I duplicate before trimming?" "trim volume page duplicate FAQ"
assert_contains "$trim_volume" "Email trim support" "trim volume page support CTA"
assert_contains "$trim_volume" "Compare Free and Pro" "trim volume page pricing link"
assert_contains "$trim_volume" "/pricing" "trim volume page pricing link"
assert_contains "$trim_volume" "Open Free plan guide" "trim volume page Free plan link"
assert_contains "$trim_volume" "/docs/free-plan" "trim volume page Free plan link"
assert_contains "$trim_volume" "Open import sounds guide" "trim volume page import sounds link"
assert_contains "$trim_volume" "/docs/import-sounds" "trim volume page import sounds link"
assert_contains "$trim_volume" "Open monitoring guide" "trim volume page monitoring preview link"
assert_contains "$trim_volume" "/docs/monitoring-preview" "trim volume page monitoring preview link"
assert_contains "$trim_volume" "Search support" "trim volume page support link"
assert_contains "$trim_volume" "/support" "trim volume page support link"
assert_contains "$monitoring_preview" "Monitor and preview SoundDeck safely" "monitoring preview page"
assert_contains "$monitoring_preview" "CollectionPage" "monitoring preview page structured data"
assert_contains "$monitoring_preview" "ItemList" "monitoring preview page structured data"
assert_contains "$monitoring_preview" "HowTo" "monitoring preview page structured data"
assert_contains "$monitoring_preview" "HowToStep" "monitoring preview page structured data"
assert_contains "$monitoring_preview" "FAQPage" "monitoring preview page structured data"
assert_contains "$monitoring_preview" "SoundDeck monitoring and preview checks" "monitoring preview page structured data"
assert_contains "$monitoring_preview" "Private Preview" "monitoring preview page content"
assert_contains "$monitoring_preview" "Live Monitoring" "monitoring preview page content"
assert_contains "$monitoring_preview" "Choose a monitor output" "monitoring preview page setup content"
assert_contains "$monitoring_preview" "Preview clips privately" "monitoring preview page setup content"
assert_contains "$monitoring_preview" "Use SFX Monitor intentionally" "monitoring preview page setup content"
assert_contains "$monitoring_preview" "Use Voice Monitor with headphones" "monitoring preview page setup content"
assert_contains "$monitoring_preview" "Monitoring Verification Checks" "monitoring preview page checklist"
assert_contains "$monitoring_preview" "Monitoring FAQ" "monitoring preview page FAQ"
assert_contains "$monitoring_preview" "What is the difference between Preview and SFX Monitor?" "monitoring preview page FAQ"
assert_contains "$monitoring_preview" "Email monitoring support" "monitoring preview page support CTA"
assert_contains "$monitoring_preview" "Open virtual mic guide" "monitoring preview page virtual microphone link"
assert_contains "$monitoring_preview" "/docs/virtual-microphone" "monitoring preview page virtual microphone link"
assert_contains "$monitoring_preview" "Open import sounds guide" "monitoring preview page import sounds link"
assert_contains "$monitoring_preview" "/docs/import-sounds" "monitoring preview page import sounds link"
assert_contains "$monitoring_preview" "Open trim and volume guide" "monitoring preview page trim volume link"
assert_contains "$monitoring_preview" "/docs/trim-volume" "monitoring preview page trim volume link"
assert_contains "$monitoring_preview" "Search support" "monitoring preview page support link"
assert_contains "$monitoring_preview" "/support" "monitoring preview page support link"
assert_contains "$voice_effects" "Use voice effects in SoundDeck" "voice effects page"
assert_contains "$voice_effects" "CollectionPage" "voice effects page structured data"
assert_contains "$voice_effects" "ItemList" "voice effects page structured data"
assert_contains "$voice_effects" "HowTo" "voice effects page structured data"
assert_contains "$voice_effects" "HowToStep" "voice effects page structured data"
assert_contains "$voice_effects" "FAQPage" "voice effects page structured data"
assert_contains "$voice_effects" "SoundDeck voice effects verification checks" "voice effects page structured data"
assert_contains "$voice_effects" "Pro Feature" "voice effects page content"
assert_contains "$voice_effects" "Local Voice Processing" "voice effects page content"
assert_contains "$voice_effects" "Confirm Pro access" "voice effects page setup content"
assert_contains "$voice_effects" "Open Voice Changer" "voice effects page setup content"
assert_contains "$voice_effects" "Set pitch carefully" "voice effects page setup content"
assert_contains "$voice_effects" "Monitor and test the route" "voice effects page setup content"
assert_contains "$voice_effects" "Voice Effects Verification Checks" "voice effects page checklist"
assert_contains "$voice_effects" "Voice Effects FAQ" "voice effects page FAQ"
assert_contains "$voice_effects" "Are voice effects included in the free plan?" "voice effects page FAQ"
assert_contains "$voice_effects" "Email voice effects support" "voice effects page support CTA"
assert_contains "$voice_effects" "Compare Free and Pro" "voice effects page pricing link"
assert_contains "$voice_effects" "/pricing" "voice effects page pricing link"
assert_contains "$voice_effects" "Open Free plan guide" "voice effects page Free plan link"
assert_contains "$voice_effects" "/docs/free-plan" "voice effects page Free plan link"
assert_contains "$voice_effects" "Read privacy notes" "voice effects page privacy link"
assert_contains "$voice_effects" "/privacy" "voice effects page privacy link"
assert_contains "$voice_effects" "Open virtual mic guide" "voice effects page virtual microphone link"
assert_contains "$voice_effects" "/docs/virtual-microphone" "voice effects page virtual microphone link"
assert_contains "$voice_effects" "Open monitoring guide" "voice effects page monitoring preview link"
assert_contains "$voice_effects" "/docs/monitoring-preview" "voice effects page monitoring preview link"
assert_contains "$voice_effects" "Open hotkeys guide" "voice effects page hotkeys link"
assert_contains "$voice_effects" "/docs/hotkeys" "voice effects page hotkeys link"
assert_contains "$voice_effects" "Search support" "voice effects page support link"
assert_contains "$voice_effects" "/support" "voice effects page support link"
assert_contains "$troubleshooting" "Troubleshooting SoundDeck setup" "troubleshooting page"
assert_contains "$troubleshooting" "CollectionPage" "troubleshooting page structured data"
assert_contains "$troubleshooting" "ItemList" "troubleshooting page structured data"
assert_contains "$troubleshooting" "HowTo" "troubleshooting page structured data"
assert_contains "$troubleshooting" "HowToStep" "troubleshooting page structured data"
assert_contains "$troubleshooting" "SoundDeck troubleshooting topics" "troubleshooting page structured data"
assert_contains "$troubleshooting" "Driver install needs approval" "troubleshooting page content"
assert_contains "$troubleshooting" "Virtual mic not appearing" "troubleshooting page content"
assert_contains "$troubleshooting" "Sounds not reaching a call" "troubleshooting page content"
assert_contains "$troubleshooting" "Microphone permission denied" "troubleshooting page content"
assert_contains "$troubleshooting" "Uninstalling" "troubleshooting page content"
assert_contains "$troubleshooting" "SoundDeck Virtual Mic" "troubleshooting page content"
assert_contains "$troubleshooting" "Email troubleshooting support" "troubleshooting page support CTA"
assert_contains "$troubleshooting" "Open getting started" "troubleshooting page setup link"
assert_contains "$troubleshooting" "Open audio driver guide" "troubleshooting page audio driver link"
assert_contains "$troubleshooting" "/docs/audio-driver" "troubleshooting page audio driver link"
assert_contains "$troubleshooting" "Open microphone permission guide" "troubleshooting page microphone permission link"
assert_contains "$troubleshooting" "/docs/microphone-permission" "troubleshooting page microphone permission link"
assert_contains "$troubleshooting" "Open monitoring guide" "troubleshooting page monitoring preview link"
assert_contains "$troubleshooting" "/docs/monitoring-preview" "troubleshooting page monitoring preview link"
assert_contains "$troubleshooting" "Open uninstall guide" "troubleshooting page uninstall link"
assert_contains "$troubleshooting" "/docs/uninstall" "troubleshooting page uninstall link"
assert_contains "$troubleshooting" "Search support" "troubleshooting page support link"
assert_contains "$uninstall" "Remove SoundDeck safely" "uninstall page"
assert_contains "$uninstall" "CollectionPage" "uninstall page structured data"
assert_contains "$uninstall" "ItemList" "uninstall page structured data"
assert_contains "$uninstall" "HowTo" "uninstall page structured data"
assert_contains "$uninstall" "HowToStep" "uninstall page structured data"
assert_contains "$uninstall" "FAQPage" "uninstall page structured data"
assert_contains "$uninstall" "SoundDeck uninstall verification checks" "uninstall page structured data"
assert_contains "$uninstall" "Driver First" "uninstall page content"
assert_contains "$uninstall" "Target Apps Cache Devices" "uninstall page content"
assert_contains "$uninstall" "Remove SoundDeck Virtual Mic first" "uninstall page setup content"
assert_contains "$uninstall" "Quit SoundDeck completely" "uninstall page setup content"
assert_contains "$uninstall" "Move SoundDeck.app to Trash" "uninstall page setup content"
assert_contains "$uninstall" "Restart target apps" "uninstall page setup content"
assert_contains "$uninstall" "Verification Checks" "uninstall page checklist"
assert_contains "$uninstall" "Uninstall FAQ" "uninstall page FAQ"
assert_contains "$uninstall" "Should I uninstall the driver or the app first?" "uninstall page FAQ"
assert_contains "$uninstall" "Email uninstall support" "uninstall page support CTA"
assert_contains "$uninstall" "Check system requirements" "uninstall page system requirements link"
assert_contains "$uninstall" "/system-requirements" "uninstall page system requirements link"
assert_contains "$uninstall" "Download SoundDeck" "uninstall page download link"
assert_contains "$uninstall" "/download" "uninstall page download link"
assert_contains "$uninstall" "Open troubleshooting" "uninstall page troubleshooting link"
assert_contains "$uninstall" "/docs/troubleshooting" "uninstall page troubleshooting link"
assert_contains "$hotkeys" "SoundDeck hotkeys guide" "hotkeys page"
assert_contains "$hotkeys" "CollectionPage" "hotkeys page structured data"
assert_contains "$hotkeys" "ItemList" "hotkeys page structured data"
assert_contains "$hotkeys" "HowTo" "hotkeys page structured data"
assert_contains "$hotkeys" "HowToStep" "hotkeys page structured data"
assert_contains "$hotkeys" "SoundDeck hotkey actions" "hotkeys page structured data"
assert_contains "$hotkeys" "Mute microphone" "hotkeys page content"
assert_contains "$hotkeys" "Stop All" "hotkeys page content"
assert_contains "$hotkeys" "Toggle voice changer" "hotkeys page content"
assert_contains "$hotkeys" "Per-sound hotkeys" "hotkeys page content"
assert_contains "$hotkeys" "Free and Pro" "hotkeys page availability"
assert_contains "$hotkeys" "SoundDeck Pro" "hotkeys page availability"
assert_contains "$hotkeys" "globalMute" "hotkeys page shortcut name"
assert_contains "$hotkeys" "stopAll" "hotkeys page shortcut name"
assert_contains "$hotkeys" "toggleVoiceChanger" "hotkeys page shortcut name"
assert_contains "$hotkeys" "sound_&lt;UUID&gt;" "hotkeys page shortcut name"
assert_contains "$hotkeys" "Conflict Checks" "hotkeys page conflict guidance"
assert_contains "$hotkeys" "Email hotkey support" "hotkeys page support CTA"
assert_contains "$hotkeys" "Open Free plan guide" "hotkeys page Free plan link"
assert_contains "$hotkeys" "/docs/free-plan" "hotkeys page Free plan link"
assert_contains "$hotkeys" "Open voice effects guide" "hotkeys page voice effects link"
assert_contains "$hotkeys" "/docs/voice-effects" "hotkeys page voice effects link"
assert_contains "$hotkeys" "Open troubleshooting guide" "hotkeys page troubleshooting link"
assert_contains "$faq_page" "SoundDeck answers before you install" "FAQ page"
assert_contains "$faq_page" "FAQPage" "FAQ page structured data"
assert_contains "$faq_page" "What is SoundDeck?" "FAQ page content"
assert_contains "$faq_page" "How does the virtual microphone work?" "FAQ page content"
assert_contains "$faq_page" "Which apps does SoundDeck work with?" "FAQ page content"
assert_contains "$faq_page" "What macOS versions are supported?" "FAQ page content"
assert_contains "$faq_page" "Does SoundDeck upload or record my audio?" "FAQ page content"
assert_contains "$faq_page" "Is there a free plan?" "FAQ page content"
assert_contains "$faq_page" "How do I uninstall the audio driver?" "FAQ page content"
assert_contains "$faq_page" "Ask FAQ support" "FAQ page support CTA"
assert_contains "$support" "Search setup help" "support page search form"
assert_contains "$support" "Driver install needs approval" "support page default fixes"
assert_contains "$support" "Virtual mic not appearing" "support page default fixes"
assert_contains "$support" "Microphone permission denied" "support page default fixes"
assert_contains "$support" "Open troubleshooting guide" "support page troubleshooting link"
assert_contains "$support" "/docs/troubleshooting" "support page troubleshooting link"
assert_contains "$support" "Open audio driver guide" "support page audio driver link"
assert_contains "$support" "/docs/audio-driver" "support page audio driver link"
assert_contains "$support" "Open microphone permission guide" "support page microphone permission link"
assert_contains "$support" "/docs/microphone-permission" "support page microphone permission link"
assert_contains "$support" "Open import sounds guide" "support page import sounds link"
assert_contains "$support" "/docs/import-sounds" "support page import sounds link"
assert_contains "$support" "Duplicated sound or variant looks wrong" "support page duplicate fix"
assert_contains "$support" "Open Free plan guide" "support page Free plan link"
assert_contains "$support" "/docs/free-plan" "support page Free plan link"
assert_contains "$support" "Free plan limit or Pro access looks wrong" "support page Free plan fix"
assert_contains "$support" "Open folders guide" "support page folders link"
assert_contains "$support" "/docs/folders" "support page folders link"
assert_contains "$support" "Folders not showing the right sounds" "support page folders fix"
assert_contains "$support" "Open Pro library guide" "support page Pro library link"
assert_contains "$support" "/docs/pro-library" "support page Pro library link"
assert_contains "$support" "Pro library search or import not working" "support page Pro library fix"
assert_contains "$support" "Open trim and volume guide" "support page trim volume link"
assert_contains "$support" "/docs/trim-volume" "support page trim volume link"
assert_contains "$support" "Trim or volume changes sound wrong" "support page trim volume fix"
assert_contains "$support" "Open monitoring guide" "support page monitoring preview link"
assert_contains "$support" "/docs/monitoring-preview" "support page monitoring preview link"
assert_contains "$support" "Monitoring or preview not audible" "support page monitoring preview fix"
assert_contains "$support" "Open voice effects guide" "support page voice effects link"
assert_contains "$support" "/docs/voice-effects" "support page voice effects link"
assert_contains "$support" "Voice effects not reaching a call" "support page voice effects fix"
assert_contains "$support_search" "Showing" "support search results"
assert_contains "$support_search" "driver" "support search query"
assert_contains "$support_search" "Virtual mic not appearing" "support search filtered fixes"
assert_contains "$support_search" "How does the virtual microphone work?" "support search filtered FAQ"
assert_not_matches "$support_search" "Microphone permission denied" "support search filtered results"
assert_contains "$support_duplicate_search" "Showing" "support duplicate search results"
assert_contains "$support_duplicate_search" "duplicate" "support duplicate search query"
assert_contains "$support_duplicate_search" "Duplicated sound or variant looks wrong" "support duplicate search filtered fixes"
assert_contains "$support_duplicate_search" "Duplicate Sound" "support duplicate search filtered steps"
assert_contains "$support_plan_search" "Showing" "support Free plan search results"
assert_contains "$support_plan_search" "free" "support Free plan search query"
assert_contains "$support_plan_search" "Free plan limit or Pro access looks wrong" "support Free plan search filtered fixes"
assert_contains "$support_plan_search" "Is there a free plan?" "support Free plan search filtered FAQ"
assert_contains "$support_folders_search" "Showing" "support folders search results"
assert_contains "$support_folders_search" "folders" "support folders search query"
assert_contains "$support_folders_search" "Folders not showing the right sounds" "support folders search filtered fixes"
assert_contains "$support_folders_search" "Move to Folder" "support folders search filtered steps"
assert_contains "$support_library_search" "Showing" "support library search results"
assert_contains "$support_library_search" "library" "support library search query"
assert_contains "$support_library_search" "Pro library search or import not working" "support library search filtered fixes"
assert_contains "$support_library_search" "Add to Library" "support library search filtered steps"
assert_contains "$support_trim_search" "Showing" "support trim search results"
assert_contains "$support_trim_search" "trim" "support trim search query"
assert_contains "$support_trim_search" "Trim or volume changes sound wrong" "support trim search filtered fixes"
assert_contains "$support_trim_search" "Trim Audio" "support trim search filtered steps"
assert_contains "$support_monitoring_search" "Showing" "support monitoring search results"
assert_contains "$support_monitoring_search" "monitoring" "support monitoring search query"
assert_contains "$support_monitoring_search" "Monitoring or preview not audible" "support monitoring search filtered fixes"
assert_contains "$support_monitoring_search" "Preview / Monitor Output" "support monitoring search filtered steps"
assert_contains "$support_voice_search" "Showing" "support voice search results"
assert_contains "$support_voice_search" "voice" "support voice search query"
assert_contains "$support_voice_search" "Voice effects not reaching a call" "support voice search filtered fixes"
assert_contains "$support_voice_search" "Does SoundDeck upload or record my audio?" "support voice search filtered FAQ"
assert_contains "$contact" "Route the request to the right inbox" "contact page"
assert_contains "$contact" "ContactPage" "contact page structured data"
assert_contains "$contact" "Setup Support" "contact page"
assert_contains "$contact" "Security Reports" "contact page"
assert_contains "$contact" "Privacy Questions" "contact page"
assert_contains "$contact" "Terms Questions" "contact page"
assert_contains "$contact" "Press" "contact page"
assert_contains "$og_headers" "content-type: image/png" "Open Graph image headers"

info "Checking prefilled contact email links"
assert_contains "$home" "mailto:support@sounddeck.app?subject=SoundDeck+Support+Request" "homepage support mailto"
assert_contains "$home" "Driver+status%3A" "homepage support mailto body"
assert_contains "$home" "Microphone+permission%3A" "homepage support mailto body"
assert_contains "$support" "mailto:support@sounddeck.app?subject=SoundDeck+Support+Request" "support page mailto"
assert_contains "$support" "SoundDeck+version%3A" "support page mailto body"
assert_contains "$contact" "mailto:support@sounddeck.app?subject=SoundDeck+Support+Request" "contact page support mailto"
assert_contains "$contact" "mailto:support@sounddeck.app?subject=SoundDeck+Security+Report" "contact page security mailto"
assert_contains "$contact" "mailto:support@sounddeck.app?subject=SoundDeck+Privacy+Question" "contact page privacy mailto"
assert_contains "$contact" "mailto:support@sounddeck.app?subject=SoundDeck+Terms+Question" "contact page terms mailto"
assert_contains "$contact" "mailto:press@sounddeck.app?subject=SoundDeck+Press+Inquiry" "contact page press mailto"
assert_contains "$privacy" "mailto:support@sounddeck.app?subject=SoundDeck+Privacy+Question" "privacy page mailto"
assert_contains "$privacy" "Privacy+question%3A" "privacy page mailto body"
assert_contains "$terms" "mailto:support@sounddeck.app?subject=SoundDeck+Terms+Question" "terms page mailto"
assert_contains "$terms" "Purchase+or+subscription+context%3A" "terms page mailto body"
assert_contains "$security" "mailto:support@sounddeck.app?subject=SoundDeck+Security+Report" "security page mailto"
assert_contains "$security" "Reproduction+steps%3A" "security page mailto body"
assert_contains "$press" "mailto:press@sounddeck.app?subject=SoundDeck+Press+Inquiry" "press page mailto"
assert_contains "$press" "Requested+assets+or+questions%3A" "press page mailto body"
assert_contains "$privacy" "Read Pro library guide" "privacy page Pro library link"
assert_contains "$privacy" "/docs/pro-library" "privacy page Pro library link"

info "Checking HTTP security headers"
assert_header_contains "$home_headers" "content-security-policy:" "homepage"
assert_header_contains "$home_headers" "default-src 'self'" "homepage CSP"
assert_header_contains "$home_headers" "frame-ancestors 'none'" "homepage CSP"
assert_header_contains "$home_headers" "referrer-policy: strict-origin-when-cross-origin" "homepage"
assert_header_contains "$home_headers" "strict-transport-security: max-age=31536000; includeSubDomains" "homepage"
assert_header_contains "$home_headers" "x-content-type-options: nosniff" "homepage"
assert_header_contains "$home_headers" "x-frame-options: DENY" "homepage"
assert_header_contains "$home_headers" "permissions-policy: camera=(), microphone=(), geolocation=(), payment=(), usb=()" "homepage"

if [[ -n "${NEXT_PUBLIC_DOWNLOAD_URL:-}" ]]; then
  info "Checking configured download URL rendering"
  assert_contains "$home" "$NEXT_PUBLIC_DOWNLOAD_URL" "homepage configured download URL"
  assert_contains "$download" "$NEXT_PUBLIC_DOWNLOAD_URL" "download page configured download URL"
  assert_contains "$pricing_page" "$NEXT_PUBLIC_DOWNLOAD_URL" "pricing page configured download URL"
  assert_not_matches "$download" "NEXT_PUBLIC_DOWNLOAD_URL" "download page configured download URL"
fi

if [[ -n "${NEXT_PUBLIC_CHECKOUT_URL:-}" ]]; then
  info "Checking configured checkout URL rendering"
  assert_contains "$home" "$NEXT_PUBLIC_CHECKOUT_URL" "homepage configured checkout URL"
  assert_contains "$pricing_page" "$NEXT_PUBLIC_CHECKOUT_URL" "pricing page configured checkout URL"
fi

info "Checking source placeholder regressions"
if rg -n "placeholder|App Screenshot|Loved by|500\\+|lemonsqueezy|HeroBackground|Math\\.random" app components lib public; then
  fail "Source placeholder regression found"
fi

info "Checking environment-driven schema wiring"
for component in components/Hero.tsx components/CTA.tsx components/SiteHeader.tsx; do
  rg -q "href=\\{siteConfig\\.downloadUrl\\}" "$component" \
    || fail "$component primary download CTA must use NEXT_PUBLIC_DOWNLOAD_URL via siteConfig.downloadUrl"
done
site_header_download_count="$(rg -c "href=\\{siteConfig\\.downloadUrl\\}" components/SiteHeader.tsx)"
[[ "$site_header_download_count" -ge 2 ]] \
  || fail "SiteHeader must expose configured download URLs in desktop and mobile navigation"
site_header_checkout_count="$(rg -c "href=\\{siteConfig\\.checkoutUrl\\}" components/SiteHeader.tsx)"
[[ "$site_header_checkout_count" -ge 2 ]] \
  || fail "SiteHeader must expose configured checkout URLs in desktop and mobile navigation"
rg -q "Upgrade to Pro" components/SiteHeader.tsx \
  || fail "Mobile navigation must include an Upgrade to Pro CTA"
if rg -n 'href="/download"' components/Hero.tsx components/CTA.tsx components/SiteHeader.tsx; then
  fail "Primary download CTAs must not hardcode /download"
fi
rg -q "selectedFolder" components/ProductMockup.tsx \
  || fail "Product mockup folder controls must track selected state"
rg -q "aria-pressed=\\{item === selectedFolder\\}" components/ProductMockup.tsx \
  || fail "Product mockup folder controls must expose selected state"
rg -q "aria-pressed=\\{active === pad\\.label\\}" components/ProductMockup.tsx \
  || fail "Product mockup sound pads must expose active state"
rg -q "onClick=\\{\\(\\) => setActive\\(\"\"\\)\\}" components/ProductMockup.tsx \
  || fail "Product mockup Stop All control must clear the active sound"
rg -q "No SFX armed" components/ProductMockup.tsx \
  || fail "Product mockup route preview must show a stopped state"
rg -q "productFeatures\\.map" app/features/page.tsx \
  || fail "Features page must render shared product feature content"
rg -q "trustItems\\.map" app/features/page.tsx \
  || fail "Features page must render shared trust content"
rg -q "CollectionPage" app/features/page.tsx \
  || fail "Features page must expose CollectionPage structured data"
rg -q "ItemList" app/features/page.tsx \
  || fail "Features page must expose ItemList structured data"
rg -q 'href="/features"' components/Features.tsx \
  || fail "Homepage feature section must link to the features page"
rg -q 'href: "/features"' components/SiteHeader.tsx \
  || fail "Primary navigation must link to the features page"
rg -q 'href="/features"' components/Footer.tsx \
  || fail "Footer must link to the features page"
rg -q '"/features"' app/sitemap.ts \
  || fail "Sitemap must include the features page"
rg -q "https://sounddeck.app/features" public/llms.txt \
  || fail "llms.txt must include the features page"
rg -q "workflow:" lib/content.ts \
  || fail "Landing use-case content must include workflow guidance"
rg -q "bestFor:" lib/content.ts \
  || fail "Landing use-case content must include best-fit guidance"
rg -q "setup:" lib/content.ts \
  || fail "Landing use-case content must include setup guidance"
rg -q "useCases\\.map" app/use-cases/page.tsx \
  || fail "Use cases page must render shared use-case content"
rg -q "CollectionPage" app/use-cases/page.tsx \
  || fail "Use cases page must expose CollectionPage structured data"
rg -q "ItemList" app/use-cases/page.tsx \
  || fail "Use cases page must expose ItemList structured data"
rg -q "supportMailtoLink" app/use-cases/page.tsx \
  || fail "Use cases page must link to prefilled support"
rg -q 'href="/use-cases"' components/Testimonials.tsx \
  || fail "Homepage use-case section must link to the use-cases page"
rg -q "section-actions" app/globals.css \
  || fail "Homepage section action styling must support the use-cases CTA"
rg -q 'href: "/use-cases"' components/SiteHeader.tsx \
  || fail "Primary navigation must link to the use-cases page"
rg -q 'href="/use-cases"' components/Footer.tsx \
  || fail "Footer must link to the use-cases page"
rg -q '"/use-cases"' app/sitemap.ts \
  || fail "Sitemap must include the use-cases page"
rg -q "https://sounddeck.app/use-cases" public/llms.txt \
  || fail "llms.txt must include the use-cases page"
rg -q "export const compatibilityDetails" lib/content.ts \
  || fail "Landing content must expose detailed compatibility data"
rg -q "compatibilityDetails\\.map" app/compatibility/page.tsx \
  || fail "Compatibility page must render app setup notes from shared data"
rg -q "CollectionPage" app/compatibility/page.tsx \
  || fail "Compatibility page must expose CollectionPage structured data"
rg -q "ItemList" app/compatibility/page.tsx \
  || fail "Compatibility page must expose ItemList structured data"
rg -q "supportMailtoLink" app/compatibility/page.tsx \
  || fail "Compatibility page must link to prefilled support"
rg -q 'href="/compatibility"' components/Screenshots.tsx \
  || fail "Homepage compatibility section must link to app setup notes"
rg -q 'href: "/compatibility"' components/SiteHeader.tsx \
  || fail "Primary navigation must link to the compatibility page"
rg -q 'href="/compatibility"' components/Footer.tsx \
  || fail "Footer must link to the compatibility page"
rg -q '"/compatibility"' app/sitemap.ts \
  || fail "Sitemap must include the compatibility page"
rg -q "https://sounddeck.app/compatibility" public/llms.txt \
  || fail "llms.txt must include the compatibility page"
rg -q "export const appGuides" lib/content.ts \
  || fail "Landing content must expose shared app setup guide data"
rg -q "setupSteps:" lib/content.ts \
  || fail "App setup guides must include setup step content"
rg -q "troubleshooting:" lib/content.ts \
  || fail "App setup guides must include troubleshooting content"
rg -q "appGuides\\.map" app/guides/page.tsx \
  || fail "App guide hub must render shared app guide data"
rg -q "CollectionPage" app/guides/page.tsx \
  || fail "App guide hub must expose CollectionPage structured data"
rg -q "ItemList" app/guides/page.tsx \
  || fail "App guide hub must expose ItemList structured data"
rg -q "generateStaticParams" 'app/guides/[slug]/page.tsx' \
  || fail "App guide detail pages must statically generate known guide routes"
rg -q "dynamicParams = false" 'app/guides/[slug]/page.tsx' \
  || fail "App guide detail pages must reject unknown guide slugs"
rg -q "Article" 'app/guides/[slug]/page.tsx' \
  || fail "App guide detail pages must expose Article structured data"
rg -q "HowTo" 'app/guides/[slug]/page.tsx' \
  || fail "App guide detail pages must expose HowTo structured data"
rg -q "HowToStep" 'app/guides/[slug]/page.tsx' \
  || fail "App guide detail pages must expose HowToStep structured data"
rg -q "supportMailtoLink" app/guides/page.tsx 'app/guides/[slug]/page.tsx' \
  || fail "App guide pages must link to prefilled support"
rg -q "guideByName" app/compatibility/page.tsx \
  || fail "Compatibility page must link supported apps to dedicated app setup guides"
rg -q 'href="/guides"' app/docs/page.tsx components/Footer.tsx \
  || fail "Docs page and footer must link to the app setup guide hub"
rg -q "appGuides" app/sitemap.ts \
  || fail "Sitemap must include app setup guide detail pages from shared data"
rg -q "https://sounddeck.app/guides/zoom" public/llms.txt \
  || fail "llms.txt must include app setup guide detail pages"
rg -q '`/guides/zoom`' README.md \
  || fail "Landing README public page list must include app setup guide detail pages"
rg -q "export const comparisonDetails" lib/content.ts \
  || fail "Landing content must expose detailed comparison data"
rg -q "comparisonDetails\\.map" app/compare/page.tsx \
  || fail "Compare page must render shared comparison details"
rg -q "comparisonRows\\.map" app/compare/page.tsx \
  || fail "Compare page must render the shared comparison table"
rg -q "CollectionPage" app/compare/page.tsx \
  || fail "Compare page must expose CollectionPage structured data"
rg -q "ItemList" app/compare/page.tsx \
  || fail "Compare page must expose ItemList structured data"
rg -q "supportMailtoLink" app/compare/page.tsx \
  || fail "Compare page must link to prefilled support"
rg -q 'href="/compare"' components/Screenshots.tsx \
  || fail "Homepage comparison section must link to the compare page"
rg -q 'href: "/compare"' components/SiteHeader.tsx \
  || fail "Primary navigation must link to the compare page"
rg -q 'href="/compare"' components/Footer.tsx \
  || fail "Footer must link to the compare page"
rg -q '"/compare"' app/sitemap.ts \
  || fail "Sitemap must include the compare page"
rg -q "https://sounddeck.app/compare" public/llms.txt \
  || fail "llms.txt must include the compare page"
rg -q "export const freePlanFeatures" lib/content.ts \
  || fail "Landing content must expose shared Free plan features"
rg -q "export const proPlanFeatures" lib/content.ts \
  || fail "Landing content must expose shared Pro plan features"
rg -q "export const pricingFaqs" lib/content.ts \
  || fail "Landing content must expose shared pricing FAQs"
rg -q "freePlanFeatures, proPlanFeatures" components/Pricing.tsx \
  || fail "Homepage pricing section must use shared pricing feature lists"
rg -q "pricingFaqs" app/pricing/page.tsx \
  || fail "Pricing page must render shared pricing FAQs"
rg -q "Product" app/pricing/page.tsx \
  || fail "Pricing page must expose Product structured data"
rg -q "FAQPage" app/pricing/page.tsx \
  || fail "Pricing page must expose FAQPage structured data"
rg -q "absoluteUrl\\(siteConfig\\.downloadUrl\\)" app/pricing/page.tsx \
  || fail "Pricing page Free offer must use the configured download URL"
rg -q "siteConfig\\.checkoutUrl" app/pricing/page.tsx \
  || fail "Pricing page Pro offer and CTA must use the configured checkout URL"
rg -q 'href="/pricing"' components/Hero.tsx components/Pricing.tsx \
  || fail "Homepage hero/pricing CTAs must link to the pricing page"
rg -q 'href: "/pricing"' components/SiteHeader.tsx \
  || fail "Primary navigation must link to the pricing page"
rg -q 'href="/pricing"' components/Footer.tsx \
  || fail "Footer must link to the pricing page"
rg -q '"/pricing"' app/sitemap.ts \
  || fail "Sitemap must include the pricing page"
rg -q "https://sounddeck.app/pricing" public/llms.txt \
  || fail "llms.txt must include the pricing page"
rg -q "export const systemRequirements" lib/content.ts \
  || fail "Landing content must expose shared system requirements"
rg -q "export const systemReadinessChecks" lib/content.ts \
  || fail "Landing content must expose shared system readiness checks"
rg -q "export const systemRequirementFaqs" lib/content.ts \
  || fail "Landing content must expose shared system requirement FAQs"
rg -q "systemRequirements\\.map" app/system-requirements/page.tsx \
  || fail "System requirements page must render shared requirements"
rg -q "systemReadinessChecks\\.map" app/system-requirements/page.tsx \
  || fail "System requirements page must render shared readiness checks"
rg -q "systemRequirementFaqs\\.map" app/system-requirements/page.tsx \
  || fail "System requirements page must render shared FAQ content"
rg -q "CollectionPage" app/system-requirements/page.tsx \
  || fail "System requirements page must expose CollectionPage structured data"
rg -q "ItemList" app/system-requirements/page.tsx \
  || fail "System requirements page must expose ItemList structured data"
rg -q "FAQPage" app/system-requirements/page.tsx \
  || fail "System requirements page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/system-requirements/page.tsx \
  || fail "System requirements page must link to prefilled support"
rg -q 'href="/system-requirements"' app/download/page.tsx \
  || fail "Download page must link to the system requirements page"
rg -q 'href="/system-requirements"' components/Footer.tsx \
  || fail "Footer must link to the system requirements page"
rg -q '"/system-requirements"' app/sitemap.ts \
  || fail "Sitemap must include the system requirements page"
rg -q "https://sounddeck.app/system-requirements" public/llms.txt \
  || fail "llms.txt must include the system requirements page"
rg -q '`/system-requirements`' README.md \
  || fail "Landing README public page list must include the system requirements page"
rg -q "export const audioDriverSteps" lib/content.ts \
  || fail "Landing content must expose shared audio driver steps"
rg -q "export const audioDriverChecks" lib/content.ts \
  || fail "Landing content must expose shared audio driver checks"
rg -q "export const audioDriverFaqs" lib/content.ts \
  || fail "Landing content must expose shared audio driver FAQs"
rg -q "audioDriverSteps\\.map" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must render shared driver steps"
rg -q "audioDriverChecks\\.map" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must render shared driver checks"
rg -q "audioDriverFaqs\\.map" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must render shared FAQ content"
rg -q "CollectionPage" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must expose ItemList structured data"
rg -q "HowTo" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must expose HowTo structured data"
rg -q "HowToStep" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/audio-driver/page.tsx \
  || fail "Audio driver page must link to prefilled support"
rg -q 'href="/docs/audio-driver"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the audio driver guide"
rg -q 'href="/docs/audio-driver"' app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must link to the audio driver guide"
rg -q 'href="/docs/audio-driver"' app/support/page.tsx \
  || fail "Support page must link to the audio driver guide"
rg -q 'href="/docs/audio-driver"' components/Footer.tsx \
  || fail "Footer must link to the audio driver guide"
rg -q '"/docs/audio-driver"' app/sitemap.ts \
  || fail "Sitemap must include the audio driver guide"
rg -q "https://sounddeck.app/docs/audio-driver" public/llms.txt \
  || fail "llms.txt must include the audio driver guide"
rg -q '`/docs/audio-driver`' README.md \
  || fail "Landing README public page list must include the audio driver guide"
rg -q "export const importSoundSteps" lib/content.ts \
  || fail "Landing content must expose shared import sound steps"
rg -q "export const importSoundChecks" lib/content.ts \
  || fail "Landing content must expose shared import sound checks"
rg -q "export const importSoundFaqs" lib/content.ts \
  || fail "Landing content must expose shared import sound FAQs"
rg -q "importSoundSteps\\.map" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must render shared import steps"
rg -q "importSoundChecks\\.map" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must render shared import checks"
rg -q "importSoundFaqs\\.map" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must render shared FAQ content"
rg -q "CollectionPage" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must expose ItemList structured data"
rg -q "HowTo" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must expose HowTo structured data"
rg -q "HowToStep" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must link to prefilled support"
rg -q "Duplicate a safe variant" lib/content.ts \
  || fail "Import sound guidance must document Duplicate Sound variants"
rg -q "Can I duplicate a sound before editing it" lib/content.ts \
  || fail "Import sound FAQs must explain Duplicate Sound"
rg -q 'href="/docs/import-sounds"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the import sounds guide"
rg -q 'href="/docs/import-sounds"' app/support/page.tsx \
  || fail "Support page must link to the import sounds guide"
rg -q 'href="/docs/import-sounds"' components/Footer.tsx \
  || fail "Footer must link to the import sounds guide"
rg -q '"/docs/import-sounds"' app/sitemap.ts \
  || fail "Sitemap must include the import sounds guide"
rg -q "https://sounddeck.app/docs/import-sounds" public/llms.txt \
  || fail "llms.txt must include the import sounds guide"
rg -q '`/docs/import-sounds`' README.md \
  || fail "Landing README public page list must include the import sounds guide"
rg -q "export const freePlanSteps" lib/content.ts \
  || fail "Landing content must expose shared Free plan steps"
rg -q "export const freePlanChecks" lib/content.ts \
  || fail "Landing content must expose shared Free plan checks"
rg -q "export const freePlanFaqs" lib/content.ts \
  || fail "Landing content must expose shared Free plan FAQs"
rg -q "freePlanSteps\\.map" app/docs/free-plan/page.tsx \
  || fail "Free plan page must render shared Free plan steps"
rg -q "freePlanChecks\\.map" app/docs/free-plan/page.tsx \
  || fail "Free plan page must render shared Free plan checks"
rg -q "freePlanFaqs\\.map" app/docs/free-plan/page.tsx \
  || fail "Free plan page must render shared FAQ content"
rg -q "CollectionPage" app/docs/free-plan/page.tsx \
  || fail "Free plan page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/free-plan/page.tsx \
  || fail "Free plan page must expose ItemList structured data"
rg -q "HowTo" app/docs/free-plan/page.tsx \
  || fail "Free plan page must expose HowTo structured data"
rg -q "HowToStep" app/docs/free-plan/page.tsx \
  || fail "Free plan page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/free-plan/page.tsx \
  || fail "Free plan page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/free-plan/page.tsx \
  || fail "Free plan page must link to prefilled support"
rg -q 'href="/docs/free-plan"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the Free plan guide"
rg -q 'href="/docs/free-plan"' app/pricing/page.tsx \
  || fail "Pricing page must link to the Free plan guide"
rg -q 'href="/docs/free-plan"' app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must link to the Free plan guide"
rg -q 'href="/docs/free-plan"' app/docs/pro-library/page.tsx \
  || fail "Pro library page must link to the Free plan guide"
rg -q 'href="/docs/free-plan"' app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must link to the Free plan guide"
rg -q 'href="/docs/free-plan"' app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must link to the Free plan guide"
rg -q 'href="/docs/free-plan"' app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must link to the Free plan guide"
rg -q 'href="/docs/free-plan"' app/support/page.tsx \
  || fail "Support page must link to the Free plan guide"
rg -q 'href="/docs/free-plan"' components/Footer.tsx \
  || fail "Footer must link to the Free plan guide"
rg -q '"/docs/free-plan"' app/sitemap.ts \
  || fail "Sitemap must include the Free plan guide"
rg -q "https://sounddeck.app/docs/free-plan" public/llms.txt \
  || fail "llms.txt must include the Free plan guide"
rg -q '`/docs/free-plan`' README.md \
  || fail "Landing README public page list must include the Free plan guide"
rg -q "Free plan limit or Pro access looks wrong" lib/content.ts \
  || fail "Support topics must include Free plan troubleshooting"
rg -q "Restore Purchases" lib/content.ts public/llms.txt app/docs/free-plan/page.tsx \
  || fail "Free plan content must explain restore purchases"
rg -q "export const folderOrganizationSteps" lib/content.ts \
  || fail "Landing content must expose shared folder organization steps"
rg -q "export const folderOrganizationChecks" lib/content.ts \
  || fail "Landing content must expose shared folder organization checks"
rg -q "export const folderOrganizationFaqs" lib/content.ts \
  || fail "Landing content must expose shared folder organization FAQs"
rg -q "folderOrganizationSteps\\.map" app/docs/folders/page.tsx \
  || fail "Folders page must render shared folder organization steps"
rg -q "folderOrganizationChecks\\.map" app/docs/folders/page.tsx \
  || fail "Folders page must render shared folder organization checks"
rg -q "folderOrganizationFaqs\\.map" app/docs/folders/page.tsx \
  || fail "Folders page must render shared FAQ content"
rg -q "CollectionPage" app/docs/folders/page.tsx \
  || fail "Folders page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/folders/page.tsx \
  || fail "Folders page must expose ItemList structured data"
rg -q "HowTo" app/docs/folders/page.tsx \
  || fail "Folders page must expose HowTo structured data"
rg -q "HowToStep" app/docs/folders/page.tsx \
  || fail "Folders page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/folders/page.tsx \
  || fail "Folders page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/folders/page.tsx \
  || fail "Folders page must link to prefilled support"
rg -q 'href="/docs/folders"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the folders guide"
rg -q 'href="/docs/folders"' app/features/page.tsx \
  || fail "Features page must link to the folders guide"
rg -q 'href="/docs/folders"' app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must link to the folders guide"
rg -q 'href="/docs/folders"' app/docs/pro-library/page.tsx \
  || fail "Pro library page must link to the folders guide"
rg -q 'href="/docs/folders"' app/support/page.tsx \
  || fail "Support page must link to the folders guide"
rg -q 'href="/docs/folders"' components/Footer.tsx \
  || fail "Footer must link to the folders guide"
rg -q '"/docs/folders"' app/sitemap.ts \
  || fail "Sitemap must include the folders guide"
rg -q "https://sounddeck.app/docs/folders" public/llms.txt \
  || fail "llms.txt must include the folders guide"
rg -q '`/docs/folders`' README.md \
  || fail "Landing README public page list must include the folders guide"
rg -q "Folders not showing the right sounds" lib/content.ts \
  || fail "Support topics must include folder troubleshooting"
rg -q "export const proLibrarySteps" lib/content.ts \
  || fail "Landing content must expose shared Pro library steps"
rg -q "export const proLibraryChecks" lib/content.ts \
  || fail "Landing content must expose shared Pro library checks"
rg -q "export const proLibraryFaqs" lib/content.ts \
  || fail "Landing content must expose shared Pro library FAQs"
rg -q "proLibrarySteps\\.map" app/docs/pro-library/page.tsx \
  || fail "Pro library page must render shared Pro library steps"
rg -q "proLibraryChecks\\.map" app/docs/pro-library/page.tsx \
  || fail "Pro library page must render shared Pro library checks"
rg -q "proLibraryFaqs\\.map" app/docs/pro-library/page.tsx \
  || fail "Pro library page must render shared FAQ content"
rg -q "CollectionPage" app/docs/pro-library/page.tsx \
  || fail "Pro library page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/pro-library/page.tsx \
  || fail "Pro library page must expose ItemList structured data"
rg -q "HowTo" app/docs/pro-library/page.tsx \
  || fail "Pro library page must expose HowTo structured data"
rg -q "HowToStep" app/docs/pro-library/page.tsx \
  || fail "Pro library page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/pro-library/page.tsx \
  || fail "Pro library page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/pro-library/page.tsx \
  || fail "Pro library page must link to prefilled support"
rg -q 'href="/docs/pro-library"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the Pro library guide"
rg -q 'href="/docs/pro-library"' app/features/page.tsx \
  || fail "Features page must link to the Pro library guide"
rg -q 'href="/docs/pro-library"' app/pricing/page.tsx \
  || fail "Pricing page must link to the Pro library guide"
rg -q 'href="/docs/pro-library"' app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must link to the Pro library guide"
rg -q 'href="/docs/pro-library"' app/privacy/page.tsx \
  || fail "Privacy page must link to the Pro library guide"
rg -q 'href="/docs/pro-library"' app/support/page.tsx \
  || fail "Support page must link to the Pro library guide"
rg -q 'href="/docs/pro-library"' components/Footer.tsx \
  || fail "Footer must link to the Pro library guide"
rg -q '"/docs/pro-library"' app/sitemap.ts \
  || fail "Sitemap must include the Pro library guide"
rg -q "https://sounddeck.app/docs/pro-library" public/llms.txt \
  || fail "llms.txt must include the Pro library guide"
rg -q '`/docs/pro-library`' README.md \
  || fail "Landing README public page list must include the Pro library guide"
rg -q "Pro library search or import not working" lib/content.ts \
  || fail "Support topics must include Pro library troubleshooting"
rg -q "export const trimVolumeSteps" lib/content.ts \
  || fail "Landing content must expose shared trim volume steps"
rg -q "export const trimVolumeChecks" lib/content.ts \
  || fail "Landing content must expose shared trim volume checks"
rg -q "export const trimVolumeFaqs" lib/content.ts \
  || fail "Landing content must expose shared trim volume FAQs"
rg -q "trimVolumeSteps\\.map" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must render shared trim volume steps"
rg -q "trimVolumeChecks\\.map" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must render shared trim volume checks"
rg -q "trimVolumeFaqs\\.map" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must render shared FAQ content"
rg -q "Duplicate before risky edits" lib/content.ts \
  || fail "Trim volume guidance must document Duplicate Sound variants"
rg -q "Should I duplicate before trimming" lib/content.ts \
  || fail "Trim volume FAQs must explain duplicating before trimming"
rg -q "CollectionPage" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must expose ItemList structured data"
rg -q "HowTo" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must expose HowTo structured data"
rg -q "HowToStep" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/trim-volume/page.tsx \
  || fail "Trim volume page must link to prefilled support"
rg -q 'href="/docs/trim-volume"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the trim volume guide"
rg -q 'href="/docs/trim-volume"' app/features/page.tsx \
  || fail "Features page must link to the trim volume guide"
rg -q 'href="/docs/trim-volume"' app/pricing/page.tsx \
  || fail "Pricing page must link to the trim volume guide"
rg -q 'href="/docs/trim-volume"' app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must link to the trim volume guide"
rg -q 'href="/docs/trim-volume"' app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must link to the trim volume guide"
rg -q 'href="/docs/trim-volume"' app/support/page.tsx \
  || fail "Support page must link to the trim volume guide"
rg -q 'href="/docs/trim-volume"' components/Footer.tsx \
  || fail "Footer must link to the trim volume guide"
rg -q '"/docs/trim-volume"' app/sitemap.ts \
  || fail "Sitemap must include the trim volume guide"
rg -q "https://sounddeck.app/docs/trim-volume" public/llms.txt \
  || fail "llms.txt must include the trim volume guide"
rg -q '`/docs/trim-volume`' README.md \
  || fail "Landing README public page list must include the trim volume guide"
rg -q "Trim or volume changes sound wrong" lib/content.ts \
  || fail "Support topics must include trim volume troubleshooting"
rg -q "Duplicated sound or variant looks wrong" lib/content.ts \
  || fail "Support topics must include duplicate sound troubleshooting"
rg -q "export const monitoringPreviewSteps" lib/content.ts \
  || fail "Landing content must expose shared monitoring preview steps"
rg -q "export const monitoringPreviewChecks" lib/content.ts \
  || fail "Landing content must expose shared monitoring preview checks"
rg -q "export const monitoringPreviewFaqs" lib/content.ts \
  || fail "Landing content must expose shared monitoring preview FAQs"
rg -q "monitoringPreviewSteps\\.map" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must render shared monitoring steps"
rg -q "monitoringPreviewChecks\\.map" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must render shared monitoring checks"
rg -q "monitoringPreviewFaqs\\.map" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must render shared FAQ content"
rg -q "CollectionPage" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must expose ItemList structured data"
rg -q "HowTo" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must expose HowTo structured data"
rg -q "HowToStep" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/monitoring-preview/page.tsx \
  || fail "Monitoring preview page must link to prefilled support"
rg -q 'href="/docs/monitoring-preview"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the monitoring preview guide"
rg -q 'href="/docs/monitoring-preview"' app/features/page.tsx \
  || fail "Features page must link to the monitoring preview guide"
rg -q 'href="/docs/monitoring-preview"' app/docs/import-sounds/page.tsx \
  || fail "Import sounds page must link to the monitoring preview guide"
rg -q 'href="/docs/monitoring-preview"' app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must link to the monitoring preview guide"
rg -q 'href="/docs/monitoring-preview"' app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must link to the monitoring preview guide"
rg -q 'href="/docs/monitoring-preview"' app/support/page.tsx \
  || fail "Support page must link to the monitoring preview guide"
rg -q 'href="/docs/monitoring-preview"' components/Footer.tsx \
  || fail "Footer must link to the monitoring preview guide"
rg -q '"/docs/monitoring-preview"' app/sitemap.ts \
  || fail "Sitemap must include the monitoring preview guide"
rg -q "https://sounddeck.app/docs/monitoring-preview" public/llms.txt \
  || fail "llms.txt must include the monitoring preview guide"
rg -q '`/docs/monitoring-preview`' README.md \
  || fail "Landing README public page list must include the monitoring preview guide"
rg -q "Monitoring or preview not audible" lib/content.ts \
  || fail "Support topics must include monitoring preview troubleshooting"
rg -q "export const voiceEffectsSteps" lib/content.ts \
  || fail "Landing content must expose shared voice effects steps"
rg -q "export const voiceEffectsChecks" lib/content.ts \
  || fail "Landing content must expose shared voice effects checks"
rg -q "export const voiceEffectsFaqs" lib/content.ts \
  || fail "Landing content must expose shared voice effects FAQs"
rg -q "voiceEffectsSteps\\.map" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must render shared voice effects steps"
rg -q "voiceEffectsChecks\\.map" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must render shared voice effects checks"
rg -q "voiceEffectsFaqs\\.map" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must render shared FAQ content"
rg -q "CollectionPage" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must expose ItemList structured data"
rg -q "HowTo" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must expose HowTo structured data"
rg -q "HowToStep" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/voice-effects/page.tsx \
  || fail "Voice effects page must link to prefilled support"
rg -q 'href="/docs/voice-effects"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the voice effects guide"
rg -q 'href="/docs/voice-effects"' app/features/page.tsx \
  || fail "Features page must link to the voice effects guide"
rg -q 'href="/docs/voice-effects"' app/pricing/page.tsx \
  || fail "Pricing page must link to the voice effects guide"
rg -q 'href="/docs/voice-effects"' app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must link to the voice effects guide"
rg -q 'href="/docs/voice-effects"' app/support/page.tsx \
  || fail "Support page must link to the voice effects guide"
rg -q 'href="/docs/voice-effects"' components/Footer.tsx \
  || fail "Footer must link to the voice effects guide"
rg -q '"/docs/voice-effects"' app/sitemap.ts \
  || fail "Sitemap must include the voice effects guide"
rg -q "https://sounddeck.app/docs/voice-effects" public/llms.txt \
  || fail "llms.txt must include the voice effects guide"
rg -q '`/docs/voice-effects`' README.md \
  || fail "Landing README public page list must include the voice effects guide"
rg -q "Voice effects not reaching a call" lib/content.ts \
  || fail "Support topics must include voice effects troubleshooting"
rg -q "export const microphonePermissionSteps" lib/content.ts \
  || fail "Landing content must expose shared microphone permission steps"
rg -q "export const microphonePermissionChecks" lib/content.ts \
  || fail "Landing content must expose shared microphone permission checks"
rg -q "export const microphonePermissionFaqs" lib/content.ts \
  || fail "Landing content must expose shared microphone permission FAQs"
rg -q "microphonePermissionSteps\\.map" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must render shared permission steps"
rg -q "microphonePermissionChecks\\.map" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must render shared permission checks"
rg -q "microphonePermissionFaqs\\.map" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must render shared FAQ content"
rg -q "CollectionPage" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must expose ItemList structured data"
rg -q "HowTo" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must expose HowTo structured data"
rg -q "HowToStep" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/microphone-permission/page.tsx \
  || fail "Microphone permission page must link to prefilled support"
rg -q 'href="/docs/microphone-permission"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the microphone permission guide"
rg -q 'href="/docs/microphone-permission"' app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must link to the microphone permission guide"
rg -q 'href="/docs/microphone-permission"' app/support/page.tsx \
  || fail "Support page must link to the microphone permission guide"
rg -q 'href="/docs/microphone-permission"' components/Footer.tsx \
  || fail "Footer must link to the microphone permission guide"
rg -q '"/docs/microphone-permission"' app/sitemap.ts \
  || fail "Sitemap must include the microphone permission guide"
rg -q "https://sounddeck.app/docs/microphone-permission" public/llms.txt \
  || fail "llms.txt must include the microphone permission guide"
rg -q '`/docs/microphone-permission`' README.md \
  || fail "Landing README public page list must include the microphone permission guide"
rg -q "export const virtualMicrophoneFlow" lib/content.ts \
  || fail "Landing content must expose shared virtual microphone flow"
rg -q "export const virtualMicrophoneChecks" lib/content.ts \
  || fail "Landing content must expose shared virtual microphone checks"
rg -q "export const virtualMicrophoneFaqs" lib/content.ts \
  || fail "Landing content must expose shared virtual microphone FAQs"
rg -q "virtualMicrophoneFlow\\.map" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must render shared route flow"
rg -q "virtualMicrophoneChecks\\.map" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must render shared route checks"
rg -q "virtualMicrophoneFaqs\\.map" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must render shared FAQ content"
rg -q "CollectionPage" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must expose ItemList structured data"
rg -q "HowTo" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must expose HowTo structured data"
rg -q "HowToStep" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/virtual-microphone/page.tsx \
  || fail "Virtual microphone page must link to prefilled support"
rg -q 'href="/docs/virtual-microphone"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the virtual microphone guide"
rg -q 'href="/docs/virtual-microphone"' app/features/page.tsx \
  || fail "Features page must link to the virtual microphone guide"
rg -q 'href="/docs/virtual-microphone"' app/compatibility/page.tsx \
  || fail "Compatibility page must link to the virtual microphone guide"
rg -q 'href="/docs/virtual-microphone"' components/Footer.tsx \
  || fail "Footer must link to the virtual microphone guide"
rg -q '"/docs/virtual-microphone"' app/sitemap.ts \
  || fail "Sitemap must include the virtual microphone guide"
rg -q "https://sounddeck.app/docs/virtual-microphone" public/llms.txt \
  || fail "llms.txt must include the virtual microphone guide"
rg -q '`/docs/virtual-microphone`' README.md \
  || fail "Landing README public page list must include the virtual microphone guide"
rg -q "export const uninstallSteps" lib/content.ts \
  || fail "Landing content must expose shared uninstall steps"
rg -q "export const uninstallVerificationChecks" lib/content.ts \
  || fail "Landing content must expose shared uninstall verification checks"
rg -q "export const uninstallFaqs" lib/content.ts \
  || fail "Landing content must expose shared uninstall FAQs"
rg -q "uninstallSteps\\.map" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must render shared uninstall steps"
rg -q "uninstallVerificationChecks\\.map" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must render shared verification checks"
rg -q "uninstallFaqs\\.map" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must render shared FAQ content"
rg -q "CollectionPage" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must expose ItemList structured data"
rg -q "HowTo" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must expose HowTo structured data"
rg -q "HowToStep" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must expose HowToStep structured data"
rg -q "FAQPage" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/docs/uninstall/page.tsx \
  || fail "Uninstall page must link to prefilled support"
rg -q 'href="/docs/uninstall"' app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must link to the uninstall guide"
rg -q 'href="/docs/uninstall"' components/Footer.tsx \
  || fail "Footer must link to the uninstall guide"
rg -q '"/docs/uninstall"' app/sitemap.ts \
  || fail "Sitemap must include the uninstall guide"
rg -q "https://sounddeck.app/docs/uninstall" public/llms.txt \
  || fail "llms.txt must include the uninstall guide"
rg -q '`/docs/uninstall`' README.md \
  || fail "Landing README public page list must include the uninstall guide"
rg -q "export const docsGuides" lib/content.ts \
  || fail "Landing content must expose shared docs guide metadata"
rg -q "docsGuides\\.map" app/docs/page.tsx \
  || fail "Docs page must render shared docs guide metadata"
rg -q "CollectionPage" app/docs/page.tsx \
  || fail "Docs page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/page.tsx \
  || fail "Docs page must expose ItemList structured data"
rg -q "supportMailtoLink" app/docs/page.tsx \
  || fail "Docs page must link to prefilled support"
rg -q 'href: "/docs"' components/SiteHeader.tsx \
  || fail "Primary navigation must link to the docs hub"
rg -q 'href="/docs"' components/Footer.tsx \
  || fail "Footer must link to the docs hub"
rg -q '"/docs"' app/sitemap.ts \
  || fail "Sitemap must include the docs hub"
rg -q "https://sounddeck.app/docs" public/llms.txt \
  || fail "llms.txt must include the docs hub"
rg -q '`/docs`' README.md \
  || fail "Landing README public page list must include the docs hub"
rg -q "export const supportTopics" lib/content.ts \
  || fail "Landing content must expose shared support troubleshooting topics"
rg -q "steps:" lib/content.ts \
  || fail "Shared support troubleshooting topics must include step lists"
rg -q "supportTopics" app/support/page.tsx \
  || fail "Support page must render shared support troubleshooting topics"
rg -q "\\.\\.\\.topic\\.steps" app/support/page.tsx \
  || fail "Support page search must include troubleshooting step text"
rg -q "supportTopics\\.map" app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must render shared support topics"
rg -q "CollectionPage" app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must expose ItemList structured data"
rg -q "HowTo" app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must expose HowTo structured data"
rg -q "HowToStep" app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must expose HowToStep structured data"
rg -q "supportMailtoLink" app/docs/troubleshooting/page.tsx \
  || fail "Troubleshooting page must link to prefilled support"
rg -q 'href="/docs/troubleshooting"' app/support/page.tsx \
  || fail "Support page must link to the troubleshooting guide"
rg -q 'href="/docs/troubleshooting"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the troubleshooting guide"
rg -q 'href="/docs/troubleshooting"' components/Footer.tsx \
  || fail "Footer must link to the troubleshooting guide"
rg -q '"/docs/troubleshooting"' app/sitemap.ts \
  || fail "Sitemap must include the troubleshooting guide"
rg -q "https://sounddeck.app/docs/troubleshooting" public/llms.txt \
  || fail "llms.txt must include the troubleshooting guide"
rg -q "export const hotkeyActions" lib/content.ts \
  || fail "Landing content must expose shared hotkey actions"
rg -q "export const hotkeyConflictChecks" lib/content.ts \
  || fail "Landing content must expose shared hotkey conflict checks"
rg -q "hotkeyActions\\.map" app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must render shared hotkey actions"
rg -q "hotkeyConflictChecks\\.map" app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must render shared conflict checks"
rg -q "CollectionPage" app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must expose CollectionPage structured data"
rg -q "ItemList" app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must expose ItemList structured data"
rg -q "HowTo" app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must expose HowTo structured data"
rg -q "HowToStep" app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must expose HowToStep structured data"
rg -q "supportMailtoLink" app/docs/hotkeys/page.tsx \
  || fail "Hotkeys page must link to prefilled support"
rg -q 'href="/docs/hotkeys"' app/docs/getting-started/page.tsx \
  || fail "Getting started page must link to the hotkeys guide"
rg -q 'href="/docs/hotkeys"' app/features/page.tsx \
  || fail "Features page must link to the hotkeys guide"
rg -q 'href="/docs/hotkeys"' app/pricing/page.tsx \
  || fail "Pricing page must link to the hotkeys guide"
rg -q 'href="/docs/hotkeys"' components/Footer.tsx \
  || fail "Footer must link to the hotkeys guide"
rg -q '"/docs/hotkeys"' app/sitemap.ts \
  || fail "Sitemap must include the hotkeys guide"
rg -q "https://sounddeck.app/docs/hotkeys" public/llms.txt \
  || fail "llms.txt must include the hotkeys guide"
rg -q "faqs\\.map" app/faq/page.tsx \
  || fail "FAQ page must render shared FAQ content"
rg -q "FAQPage" app/faq/page.tsx \
  || fail "FAQ page must expose FAQPage structured data"
rg -q "supportMailtoLink" app/faq/page.tsx \
  || fail "FAQ page must link to prefilled support"
rg -q 'href="/faq"' components/FAQ.tsx \
  || fail "Homepage FAQ section must link to the FAQ page"
rg -q 'href="/faq"' components/Footer.tsx \
  || fail "Footer must link to the FAQ page"
rg -q '"/faq"' app/sitemap.ts \
  || fail "Sitemap must include the FAQ page"
rg -q "https://sounddeck.app/faq" public/llms.txt \
  || fail "llms.txt must include the FAQ page"
rg -q "searchParams" app/support/page.tsx \
  || fail "Support page must fulfill WebSite SearchAction query parameters"
rg -q "role=\"search\"" app/support/page.tsx \
  || fail "Support page must expose an accessible search form"
rg -q "filteredTopics" app/support/page.tsx \
  || fail "Support page must filter common fixes for search queries"
rg -q "filteredFaqs" app/support/page.tsx \
  || fail "Support page must filter FAQs for search queries"
rg -q "export function mailtoLink" lib/site.ts \
  || fail "Landing site config must expose a reusable mailto helper"
rg -q "new URLSearchParams" lib/site.ts \
  || fail "Landing mailto helper must encode mail subjects and bodies"
for helper in \
  "supportMailtoLink" \
  "privacyMailtoLink" \
  "termsMailtoLink" \
  "securityDisclosureMailtoLink" \
  "pressMailtoLink"; do
  rg -q "export function ${helper}" lib/site.ts \
    || fail "Landing site config must expose ${helper}"
done
rg -q "href=\\{supportMailtoLink\\(\\)\\}" components/CTA.tsx \
  || fail "CTA support link must use the prefilled support mailto helper"
rg -q "href=\\{supportMailtoLink\\(\\)\\}" components/Footer.tsx \
  || fail "Footer support link must use the prefilled support mailto helper"
rg -q "href=\\{supportMailtoLink\\(\\)\\}" app/support/page.tsx \
  || fail "Support page links must use the prefilled support mailto helper"
rg -q "href=\\{privacyMailtoLink\\(\\)\\}" app/privacy/page.tsx \
  || fail "Privacy page contact link must use the prefilled privacy mailto helper"
rg -q "href=\\{termsMailtoLink\\(\\)\\}" app/terms/page.tsx \
  || fail "Terms page contact link must use the prefilled terms mailto helper"
rg -q "href=\\{securityDisclosureMailtoLink\\(\\)\\}" app/security/page.tsx \
  || fail "Security page disclosure link must use the prefilled disclosure mailto helper"
rg -q "href=\\{pressMailtoLink\\(\\)\\}" app/press/page.tsx \
  || fail "Press page contact link must use the prefilled press mailto helper"
rg -q "ContactPage" app/contact/page.tsx \
  || fail "Contact page must expose ContactPage structured data"
for helper in \
  "supportMailtoLink" \
  "privacyMailtoLink" \
  "termsMailtoLink" \
  "securityDisclosureMailtoLink" \
  "pressMailtoLink"; do
  rg -q "$helper" app/contact/page.tsx \
    || fail "Contact page must use ${helper}"
done
rg -q 'href: "/contact"' components/SiteHeader.tsx \
  || fail "Primary navigation must link to the contact page"
rg -q 'href="/contact"' components/Footer.tsx \
  || fail "Footer must link to the contact page"
rg -q '"/contact"' app/sitemap.ts \
  || fail "Sitemap must include the contact page"
if rg -n 'href=\{`mailto:\$\{siteConfig\.(supportEmail|pressEmail)\}`\}' app components; then
  fail "Landing contact links must not use bare mailto hrefs"
fi
rg -q 'rel="search"' app/layout.tsx \
  || fail "Root layout must advertise the OpenSearch descriptor"
rg -q 'href="/opensearch.xml"' app/layout.tsx \
  || fail "Root layout must link to the OpenSearch descriptor"
rg -q "application/opensearchdescription\\+xml" app/opensearch.xml/route.ts app/layout.tsx \
  || fail "OpenSearch descriptor route and discovery link must use the OpenSearch content type"
rg -q "absoluteUrl\\(\"/support\"\\).*q=\\{searchTerms\\}" app/opensearch.xml/route.ts \
  || fail "OpenSearch descriptor must target the support search route"
rg -q "siteConfig\\.supportEmail" app/opensearch.xml/route.ts \
  || fail "OpenSearch descriptor must include the configured support contact"
rg -q 'manifest: "/manifest.webmanifest"' app/layout.tsx \
  || fail "Root metadata must advertise the web app manifest"
rg -q "export const viewport: Viewport" app/layout.tsx \
  || fail "Root layout must export viewport metadata"
rg -q 'themeColor: "#f6f1e8"' app/layout.tsx \
  || fail "Viewport metadata must set the launch theme color"
rg -q 'apple: "/apple-touch-icon.png"' app/layout.tsx \
  || fail "Root metadata must include an Apple touch icon"
rg -q "MetadataRoute\\.Manifest" app/manifest.ts \
  || fail "Manifest route must use Next MetadataRoute.Manifest"
rg -q "start_url: absoluteUrl\\(\"/\"\\)" app/manifest.ts \
  || fail "Manifest start_url must use the normalized absolute URL helper"
rg -q 'display: "standalone"' app/manifest.ts \
  || fail "Manifest must request standalone display"
rg -q 'categories: \["music", "productivity", "utilities"\]' app/manifest.ts \
  || fail "Manifest must include product categories"
rg -q 'src: absoluteUrl\("/icon-192.png"\)' app/manifest.ts \
  || fail "Manifest must include the 192px PNG icon"
rg -q 'sizes: "192x192"' app/manifest.ts \
  || fail "Manifest must label the 192px PNG icon"
rg -q 'src: absoluteUrl\("/icon-512.png"\)' app/manifest.ts \
  || fail "Manifest must include the 512px PNG icon"
rg -q 'sizes: "512x512"' app/manifest.ts \
  || fail "Manifest must label the 512px PNG icon"
if rg -n 'src: absoluteUrl\("/favicon.ico"\)' app/manifest.ts; then
  fail "Manifest install icons must not fall back to favicon.ico"
fi
rg -q "export function releaseAnchor" lib/content.ts \
  || fail "Changelog page and RSS feed must share stable release anchors"
rg -q "id=\\{releaseAnchor\\(release\\.version\\)\\}" app/changelog/page.tsx \
  || fail "Changelog release articles must expose feed-linked anchors"
rg -q "application/rss\\+xml" app/feed.xml/route.ts app/layout.tsx \
  || fail "Landing must expose an application/rss+xml feed and discovery link"
rg -q "const items = changelog" app/feed.xml/route.ts \
  || fail "RSS feed must be generated from the shared changelog content"
rg -q "href=\"\\$\\{escapeXml\\(absoluteUrl\\(\"/feed\\.xml\"\\)\\)\\}\"" app/feed.xml/route.ts \
  || fail "RSS feed must include an atom self link"
rg -q 'href="/feed.xml"' components/Footer.tsx \
  || fail "Footer must link to the RSS feed"
rg -q 'Contact: mailto:\$\{siteConfig\.supportEmail\}' app/.well-known/security.txt/route.ts \
  || fail "security.txt must use siteConfig.supportEmail for contact"
rg -q 'Canonical: \$\{absoluteUrl\("/\.well-known/security\.txt"\)\}' app/.well-known/security.txt/route.ts \
  || fail "security.txt must use absoluteUrl for its canonical URL"
rg -q 'Policy: \$\{absoluteUrl\("/security"\)\}' app/.well-known/security.txt/route.ts \
  || fail "security.txt must point to the public security policy page"
rg -q '"Content-Type": "text/plain; charset=utf-8"' app/.well-known/security.txt/route.ts \
  || fail "security.txt route must render as text/plain"
rg -q 'href="/\.well-known/security\.txt"' components/Footer.tsx \
  || fail "Footer must link to security.txt"
rg -q "async headers\\(\\)" next.config.ts \
  || fail "Next config must define production response headers"
for header in \
  "Content-Security-Policy" \
  "Referrer-Policy" \
  "Strict-Transport-Security" \
  "X-Content-Type-Options" \
  "X-Frame-Options" \
  "Permissions-Policy"; do
  rg -q "$header" next.config.ts \
    || fail "Next config must include $header"
done
rg -q "frame-ancestors 'none'" next.config.ts \
  || fail "CSP must block framing"
rg -q "microphone=\\(\\)" next.config.ts \
  || fail "Permissions-Policy must deny browser microphone access on the marketing site"
rg -q "function normalizeSiteUrl" lib/site.ts \
  || fail "Landing site config must normalize NEXT_PUBLIC_SITE_URL once"
rg -q "export const siteHost" lib/site.ts \
  || fail "Landing site config must expose a parsed site host for robots.txt"
rg -q "host: siteHost" app/robots.ts \
  || fail "robots.txt must use a host name instead of a scheme-qualified URL"
rg -q '\$\{absoluteUrl\("/support"\)\}\?q=\{search_term_string\}' app/page.tsx \
  || fail "WebSite SearchAction target must be built from absoluteUrl(\"/support\")"
if rg -n '\$\{siteConfig\.url\}/support' app/page.tsx; then
  fail "WebSite SearchAction target must not concatenate raw siteConfig.url"
fi
rg -q "downloadUrl: absoluteUrl\\(siteConfig\\.downloadUrl\\)" app/page.tsx \
  || fail "SoftwareApplication schema must use NEXT_PUBLIC_DOWNLOAD_URL via siteConfig.downloadUrl"
schema_download_url_count="$(rg -c "absoluteUrl\\(siteConfig\\.downloadUrl\\)" app/page.tsx)"
[[ "$schema_download_url_count" -ge 2 ]] \
  || fail "SoftwareApplication schema downloadUrl and Free offer URL must both use siteConfig.downloadUrl"
if rg -n "downloadUrl: absoluteUrl\\(\"/download\"\\)" app/page.tsx; then
  fail "SoftwareApplication schema must not hardcode /download as the artifact URL"
fi
if rg -n 'url: absoluteUrl\("/download"\)' app/page.tsx; then
  fail "SoundDeck Free offer schema must not hardcode /download as the artifact URL"
fi

info "Checking landing version metadata"
app_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/SoundDeckApp/Info.plist")"
assert_contains "$home" "$app_version" "homepage SoftwareApplication softwareVersion"
rg -q "currentVersion: \"$app_version\"" lib/site.ts \
  || fail "landing siteConfig.currentVersion must match app CFBundleShortVersionString $app_version"
rg -q "version: \"$app_version\"" lib/content.ts \
  || fail "landing changelog version must match app CFBundleShortVersionString $app_version"

printf '\nLanding verification passed.\n'
