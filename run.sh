#!/usr/bin/env bash

# INFINITE LABS AIO CMD public bootstrap launcher.
# It is safe to invoke from any working directory, including via:
# bash <(curl -sSL https://raw.githubusercontent.com/nxtinfinite481-png/IL-AIO-CMD-installer/main/run.sh)

set -Eeuo pipefail

readonly PROJECT_NAME="infinite-labs-aio"
readonly REPOSITORY_URL="${IL_AIO_REPOSITORY_URL:-https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer.git}"
readonly ARCHIVE_URL="${IL_AIO_ARCHIVE_URL:-https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer/archive/refs/heads/main.tar.gz}"
readonly WORKSPACE="${IL_AIO_WORKSPACE:-${TMPDIR:-/tmp}/${PROJECT_NAME}}"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

is_project_dir() {
    [[ -f "$1/menu/UI.sh" && -d "$1/panel" && -d "$1/thame" ]]
}

download_project() {
    local destination="$1"
    local staging_dir="${destination}.download.$$"

    if [[ -e "$staging_dir" ]]; then
        printf 'Refusing to overwrite existing staging directory: %s\n' "$staging_dir" >&2
        return 1
    fi

    trap 'rm -rf -- "$staging_dir"' RETURN
    mkdir -p "$staging_dir"

    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 "$REPOSITORY_URL" "$staging_dir/repository"
        if is_project_dir "$staging_dir/repository"; then
            mv -- "$staging_dir/repository" "$destination"
            return 0
        fi
    else
        local archive_file="$staging_dir/project.tar.gz"
        curl --fail --silent --show-error --location "$ARCHIVE_URL" -o "$archive_file"
        tar -xzf "$archive_file" -C "$staging_dir"
        local extracted_dir
        extracted_dir="$(find "$staging_dir" -mindepth 1 -maxdepth 1 -type d -print -quit)"
        if [[ -n "$extracted_dir" ]] && is_project_dir "$extracted_dir"; then
            mv -- "$extracted_dir" "$destination"
            return 0
        fi
    fi

    printf 'The downloaded project is missing its expected files.\n' >&2
    return 1
}

if is_project_dir "$script_dir"; then
    base_dir="$script_dir"
elif is_project_dir "$WORKSPACE"; then
    base_dir="$WORKSPACE"
else
    if [[ -e "$WORKSPACE" ]]; then
        printf 'Refusing to use incomplete existing workspace: %s\n' "$WORKSPACE" >&2
        exit 1
    fi
    download_project "$WORKSPACE" || exit 1
    base_dir="$WORKSPACE"
fi

if [[ ! -r "$base_dir/menu/UI.sh" ]]; then
    printf 'Main UI is unavailable in %s\n' "$base_dir" >&2
    exit 1
fi

exec bash "$base_dir/menu/UI.sh" "$@"