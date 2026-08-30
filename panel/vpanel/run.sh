#!/usr/bin/env bash

set -Eeuo pipefail

readonly VPANEL_REPOSITORY="https://github.com/nobita329/vpanel-pro.git"
readonly VPANEL_DIRECTORY="/opt/vpanel-pro"

RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
CYAN='\033[38;5;51m'
NC='\033[0m'

status_msg() {
    local type="$1"
    local message="$2"

    case "$type" in
        OK)   printf '  [%b✔%b] %s\n' "$GREEN" "$NC" "$message" ;;
        ERR)  printf '  [%b✘%b] %s\n' "$RED" "$NC" "$message" ;;
        INFO) printf '  [%b➜%b] %s\n' "$CYAN" "$NC" "$message" ;;
    esac
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        status_msg ERR "Run the vPanel installer as root."
        return 1
    fi
}

prepare_source() {
    if [[ -e "$VPANEL_DIRECTORY" && ! -d "$VPANEL_DIRECTORY" ]]; then
        status_msg ERR "Cannot use $VPANEL_DIRECTORY because it is not a directory."
        return 1
    fi

    if [[ -d "$VPANEL_DIRECTORY/.git" ]]; then
        status_msg INFO "Using the existing vPanel source at $VPANEL_DIRECTORY."
    else
        if [[ -d "$VPANEL_DIRECTORY" ]]; then
            status_msg ERR "$VPANEL_DIRECTORY exists but is not a vPanel git checkout."
            return 1
        fi

        status_msg INFO "Cloning vPanel from $VPANEL_REPOSITORY..."
        git clone "$VPANEL_REPOSITORY" "$VPANEL_DIRECTORY"
    fi

    if [[ ! -f "$VPANEL_DIRECTORY/install.sh" ]]; then
        status_msg ERR "The vPanel installer was not found in $VPANEL_DIRECTORY."
        return 1
    fi
}

main() {
    require_root
    prepare_source

    cd "$VPANEL_DIRECTORY"
    status_msg INFO "Starting the vPanel installer."
    status_msg INFO "The installer will request administrator credentials interactively."
    bash install.sh
}

main "$@"