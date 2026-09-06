#!/usr/bin/env bash
#
# scripts/verify_release_secrets.sh
#
# SECURITY FIX (audit follow-up): the in-app runtime assertions in
# ssl_pinning_interceptor.dart and app_constants.dart catch a
# misconfigured release build the FIRST TIME IT RUNS — but by then the
# artifact has already been built, signed, and possibly uploaded to a
# store or distributed to devices. This script is a pre-build /
# pre-publish CI gate that fails the PIPELINE instead, before an
# artifact with placeholder pinning fingerprints or a non-HTTPS API URL
# ever leaves CI.
#
# Usage (wire into your release job BEFORE the `flutter build` step):
#   ./scripts/verify_release_secrets.sh \
#     --base-url "$API_BASE_URL" \
#     --leaf "$PINNED_FINGERPRINT_LEAF" \
#     --backup "$PINNED_FINGERPRINT_BACKUP"
#
# Exits non-zero (fails CI) if:
#   - base URL is missing or not https://
#   - either fingerprint is missing, empty, or still contains the word
#     PLACEHOLDER (covers copy-pasted-but-unedited values too)
#   - either fingerprint doesn't look like a SHA-256 hex fingerprint
#     (64 hex chars, optionally colon-separated)

set -euo pipefail

BASE_URL=""
LEAF=""
BACKUP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-url) BASE_URL="$2"; shift 2 ;;
    --leaf) LEAF="$2"; shift 2 ;;
    --backup) BACKUP="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

fail=0

echo "== Release secrets / config verification =="

# --- 1. Base URL must be set and HTTPS ---------------------------------
if [[ -z "$BASE_URL" ]]; then
  echo "FAIL: API_BASE_URL is not set."
  fail=1
elif [[ "$BASE_URL" != https://* ]]; then
  echo "FAIL: API_BASE_URL ('$BASE_URL') is not HTTPS."
  fail=1
else
  echo "OK:   API_BASE_URL is HTTPS."
fi

# --- 2. Fingerprints must be present, non-placeholder, and SHA-256-shaped
check_fingerprint() {
  local name="$1"
  local value="$2"

  if [[ -z "$value" ]]; then
    echo "FAIL: $name is not set."
    fail=1
    return
  fi

  if [[ "$value" == *PLACEHOLDER* ]]; then
    echo "FAIL: $name still contains the literal word PLACEHOLDER."
    fail=1
    return
  fi

  # Strip colons, check it's 64 hex chars (SHA-256).
  local stripped
  stripped=$(echo "$value" | tr -d ':')
  if ! [[ "$stripped" =~ ^[A-Fa-f0-9]{64}$ ]]; then
    echo "FAIL: $name does not look like a SHA-256 fingerprint (expected 64 hex chars, got: '$value')."
    fail=1
    return
  fi

  echo "OK:   $name looks like a valid SHA-256 fingerprint."
}

check_fingerprint "PINNED_FINGERPRINT_LEAF" "$LEAF"
check_fingerprint "PINNED_FINGERPRINT_BACKUP" "$BACKUP"

if [[ "$LEAF" == "$BACKUP" && -n "$LEAF" ]]; then
  echo "FAIL: leaf and backup fingerprints are identical. Pin two distinct certs (leaf + intermediate/backup) so cert rotation doesn't brick the whole fleet."
  fail=1
fi

echo "============================================"

if [[ "$fail" -ne 0 ]]; then
  echo "Release verification FAILED. Refusing to build. See failures above."
  exit 1
fi

echo "Release verification passed."
