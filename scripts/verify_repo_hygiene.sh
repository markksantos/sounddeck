#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf '[repo-hygiene] %s\n' "$1" >&2
  exit 1
}

info() {
  printf '[repo-hygiene] %s\n' "$1"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing command: $1"
}

cd "$ROOT_DIR"

require_command git
require_command rg
require_command find

info "Checking tracked generated files"
tracked_junk="$(git ls-files | rg '(^|/)\\.DS_Store$|(^|/)Thumbs\\.db$|(^|/)\\.env($|\\.)|(^|/)dist/|(^|/)build/|(^|/)DerivedData/' || true)"
if [[ -n "$tracked_junk" ]]; then
  printf '%s\n' "$tracked_junk" >&2
  fail "Tracked generated/secret files found"
fi

info "Checking source tree metadata files"
source_junk="$(find . \
  \( -path './.git' -o -path './build' -o -path './dist' -o -path './landing/.next' -o -path './landing/node_modules' -o -path './.build' -o -path './.swiftpm' \) -prune \
  -o \( -name .DS_Store -o -name Thumbs.db \) -type f -print)"
if [[ -n "$source_junk" ]]; then
  printf '%s\n' "$source_junk" >&2
  fail "Source tree metadata files found"
fi

info "Checking secret env files"
env_files="$(find . \
  \( -path './.git' -o -path './landing/node_modules' -o -path './landing/.next' \) -prune \
  -o \( -name '.env' -o -name '.env.local' -o -name '.env.production' -o -name '.env.development' -o -name '.env.*.local' \) -type f -print)"
if [[ -n "$env_files" ]]; then
  printf '%s\n' "$env_files" >&2
  fail "Local env files found in source tree"
fi

printf '\nRepo hygiene verification passed.\n'
