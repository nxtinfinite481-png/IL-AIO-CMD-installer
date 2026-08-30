#!/usr/bin/env bash

# INFINITE LABS AIO CMD public bootstrap launcher.
# It is safe to invoke from any working directory, including via:
# bash <(curl -sSL https://raw.githubusercontent.com/nxtinfinite481-png/IL-AIO-CMD-installer/main/run.sh)

set -Eeuo pipefail

readonly ARCHIVE_URL="https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer/archive/refs/heads/main.zip"
readonly WORKSPACE="/tmp/infinite-labs-aio"
readonly ARCHIVE_PATH="$WORKSPACE/project-main.zip"
readonly EXTRACT_DIR="$WORKSPACE/extracted"

rm -rf -- "$WORKSPACE"
mkdir -p "$EXTRACT_DIR"

if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to download the latest INFINITE LABS project.\n' >&2
    exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
    printf 'unzip is required to extract the latest INFINITE LABS project.\n' >&2
    exit 1
fi

if ! curl --fail --silent --show-error --location --retry 3 --connect-timeout 15 \
    "$ARCHIVE_URL" --output "$ARCHIVE_PATH"; then
    printf 'Failed to download the latest INFINITE LABS project.\n' >&2
    exit 1
fi

if [[ ! -s "$ARCHIVE_PATH" ]]; then
    printf 'The downloaded project archive is empty.\n' >&2
    exit 1
fi

if ! unzip -q "$ARCHIVE_PATH" -d "$EXTRACT_DIR"; then
    printf 'Failed to extract the latest INFINITE LABS project.\n' >&2
    exit 1
fi

rm -f -- "$ARCHIVE_PATH"

mapfile -t UI_PATHS < <(find "$EXTRACT_DIR" -type f -path '*/menu/UI.sh' -print)

if (( ${#UI_PATHS[@]} != 1 )); then
    printf 'Could not locate a unique menu/UI.sh in the downloaded project.\n' >&2
    exit 1
fi

BASE_DIR="$(dirname "$(dirname "${UI_PATHS[0]}")")"

if [[ ! -r "$BASE_DIR/menu/UI.sh" ]]; then
    printf 'Main UI is unavailable in the downloaded project.\n' >&2
    exit 1
fi

exec bash "$BASE_DIR/menu/UI.sh" "$@"