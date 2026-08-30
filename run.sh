#!/usr/bin/env bash

# INFINITE LABS AIO CMD public bootstrap launcher.
# It is safe to invoke from any working directory, including via:
# bash <(curl -sSL https://raw.githubusercontent.com/nxtinfinite481-png/IL-AIO-CMD-installer/main/run.sh)

set -Eeuo pipefail

readonly REPOSITORY_URL="https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer.git"
readonly WORKSPACE="/tmp/infinite-labs-aio"

if ! command -v git >/dev/null 2>&1; then
    printf 'Git is required to download the latest INFINITE LABS project.\n' >&2
    exit 1
fi

rm -rf -- "$WORKSPACE"
mkdir -p "$WORKSPACE"

git clone --depth 1 --single-branch --branch main "$REPOSITORY_URL" "$WORKSPACE"

if [[ ! -r "$WORKSPACE/menu/UI.sh" ]]; then
    printf 'Main UI is unavailable in %s\n' "$WORKSPACE" >&2
    exit 1
fi

exec bash "$WORKSPACE/menu/UI.sh" "$@"