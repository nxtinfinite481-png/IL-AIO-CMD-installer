#!/usr/bin/env bash

set -Eeuo pipefail

readonly CONFIG_FILE="/etc/pufferpanel/config.json"
readonly REPOSITORY_SCRIPT_URL="https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh"
readonly LEGACY_PUFFERPANEL_VERSION="2.6.3"
readonly MODERN_PUFFERPANEL_VERSION="3.0.9"
readonly MODERN_MIN_GLIBC_VERSION="2.34"

RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
CYAN='\033[38;5;51m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
WHITE='\033[38;5;255m'
NC='\033[0m'

info() {
    printf '  %b➜%b %s\n' "$CYAN" "$NC" "$1"
}

ok() {
    printf '  %b✔%b %s\n' "$GREEN" "$NC" "$1"
}

fail() {
    printf '  %b✘%b %s\n' "$RED" "$NC" "$1" >&2
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        fail "Run the PufferPanel installer as root."
        exit 1
    fi
}

require_supported_os() {
    if [[ ! -r /etc/os-release ]]; then
        fail "Cannot determine the operating system."
        exit 1
    fi

    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}" in
        ubuntu|debian) ;;
        *)
            fail "PufferPanel installation supports Ubuntu and Debian in this module."
            exit 1
            ;;
    esac
}

detect_architecture() {
    local architecture
    architecture="$(dpkg --print-architecture 2>/dev/null || true)"
    architecture="${architecture:-$(uname -m)}"

    case "$architecture" in
        amd64|x86_64)
            printf '%s' "amd64"
            ;;
        *)
            fail "This installer supports amd64 only; detected architecture: $architecture."
            return 1
            ;;
    esac
}

detect_glibc_version() {
    local version
    version="$(getconf GNU_LIBC_VERSION 2>/dev/null | awk '{print $2}')"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
        version="$(ldd --version 2>/dev/null | sed -n '1s/.* //p')"
    fi

    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
        fail "Cannot determine the installed GLIBC version."
        return 1
    fi

    printf '%s' "$version"
}

version_at_least() {
    local current="$1"
    local minimum="$2"
    [[ "$(printf '%s\n%s\n' "$current" "$minimum" | sort -V | head -n 1)" == "$minimum" ]]
}

select_pufferpanel_version() {
    local glibc_version="$1"
    if version_at_least "$glibc_version" "$MODERN_MIN_GLIBC_VERSION"; then
        printf '%s' "$MODERN_PUFFERPANEL_VERSION"
    else
        printf '%s' "$LEGACY_PUFFERPANEL_VERSION"
    fi
}

recover_partial_installation() {
    local package_status
    package_status="$(dpkg-query -W -f='${db:Status-Status}' pufferpanel 2>/dev/null || true)"

    case "$package_status" in
        installed|unpacked|half-configured|half-installed|triggers-awaited|triggers-pending|config-files)
            info "Removing the existing partial PufferPanel installation before retrying."
            if command -v systemctl >/dev/null 2>&1; then
                systemctl disable --now pufferpanel 2>/dev/null || true
            fi
            if ! apt-get purge -y pufferpanel \
                && ! dpkg --purge --force-remove-reinstreq pufferpanel; then
                fail "Could not remove the partial PufferPanel installation safely."
                return 1
            fi
            ;;
    esac
}

verify_package_available() {
    local version="$1"
    local available_versions
    available_versions="$(apt-cache madison pufferpanel 2>/dev/null || true)"

    if ! grep -Fq "| ${version} |" <<<"$available_versions"; then
        fail "PufferPanel ${version} is not available from the configured repository."
        fail "Refusing to fall back to an unpinned or incompatible package."
        return 1
    fi
}

verify_pufferpanel_installation() {
    local version_output
    local service_status

    if ! command -v pufferpanel >/dev/null 2>&1; then
        fail "PufferPanel binary was not installed."
        return 1
    fi

    if ! version_output="$(pufferpanel --version 2>&1)"; then
        fail "PufferPanel failed its startup/version check."
        printf '%s\n' "$version_output" >&2
        return 1
    fi

    if grep -Eiq 'GLIBC_[0-9.]+|not found' <<<"$version_output"; then
        fail "PufferPanel reported a GLIBC/runtime error."
        printf '%s\n' "$version_output" >&2
        return 1
    fi
    info "PufferPanel version check: ${version_output//$'\n'/ }"

    if ! command -v systemctl >/dev/null 2>&1; then
        fail "systemctl is not available; cannot verify the PufferPanel service."
        return 1
    fi

    if ! service_status="$(systemctl show -p LoadState --value pufferpanel 2>&1)"; then
        fail "Could not query the PufferPanel systemd service."
        printf '%s\n' "$service_status" >&2
        return 1
    fi

    if [[ "$service_status" != "loaded" ]]; then
        fail "The PufferPanel systemd service does not exist."
        return 1
    fi

    service_status="$(systemctl --no-pager --full status pufferpanel 2>&1 || true)"
    if grep -Eiq 'GLIBC_[0-9.]+|not found' <<<"$service_status"; then
        fail "The PufferPanel service reported a GLIBC/runtime error."
        printf '%s\n' "$service_status" >&2
        return 1
    fi
}

validate_port() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] && ((port >= 1024 && port <= 65535))
}

set_panel_port() {
    local port="$1"
    validate_port "$port" || {
        fail "Port must be a number from 1024 through 65535."
        return 1
    }

    [[ -f "$CONFIG_FILE" ]] || {
        fail "PufferPanel configuration was not created at $CONFIG_FILE."
        return 1
    }

    python3 - "$CONFIG_FILE" "$port" <<'PY'
import json
import os
import pathlib
import stat
import sys
import tempfile

config_path = pathlib.Path(sys.argv[1])
port = int(sys.argv[2])

with config_path.open("r", encoding="utf-8") as handle:
    config = json.load(handle)

if not isinstance(config, dict):
    raise SystemExit("PufferPanel config must contain a JSON object")

host = f"0.0.0.0:{port}"
web = config.get("web")
if isinstance(web, dict):
    web["host"] = host
elif "host" in config:
    config["host"] = host
else:
    config["web"] = {"host": host}

mode = stat.S_IMODE(config_path.stat().st_mode)
with tempfile.NamedTemporaryFile(
    "w", encoding="utf-8", dir=config_path.parent, delete=False
) as handle:
    json.dump(config, handle, indent=2)
    handle.write("\n")
    temporary_path = pathlib.Path(handle.name)

os.chmod(temporary_path, mode)
os.replace(temporary_path, config_path)
PY
}

install_repository() {
    local repository_script
    repository_script="$(mktemp)"
    trap 'rm -f -- "$repository_script"' RETURN

    # This is the official packagecloud repository bootstrap used by the
    # legacy PufferPanel installation method. Keep it temporary and local;
    # never pipe an unreviewed remote response directly into a shell.
    curl --fail --silent --show-error --location "$REPOSITORY_SCRIPT_URL" -o "$repository_script"
    chmod 0700 "$repository_script"
    if ! grep -qF "packagecloud.io" "$repository_script"; then
        fail "The downloaded repository bootstrap did not pass validation."
        return 1
    fi
    bash "$repository_script"
}

create_admin() {
    printf '\n  %bCreate the first PufferPanel administrator now.%b\n' "$PURPLE" "$NC"
    printf '  The official command will ask for the username, password, email, and admin confirmation.\n'
    read -r -p "  Create administrator now? [Y/n]: " answer
    if [[ ! "$answer" =~ ^[Nn]$ ]]; then
        pufferpanel user add
    fi
}

main() {
    require_root
    require_supported_os

    local architecture
    local glibc_version
    local pufferpanel_version
    architecture="$(detect_architecture)"
    glibc_version="$(detect_glibc_version)"
    pufferpanel_version="$(select_pufferpanel_version "$glibc_version")"

    printf '%b\n' "${PURPLE}==============================================${NC}"
    printf '%b\n' "${CYAN}       INFINITE LABS PUFFERPANEL SETUP       ${NC}"
    printf '%b\n\n' "${PURPLE}==============================================${NC}"
    info "Detected ${PRETTY_NAME:-${ID} ${VERSION_ID:-unknown}}, ${architecture}, GLIBC ${glibc_version}."
    if [[ "$pufferpanel_version" == "$LEGACY_PUFFERPANEL_VERSION" ]]; then
        info "GLIBC is below ${MODERN_MIN_GLIBC_VERSION}; selecting legacy-compatible PufferPanel ${pufferpanel_version}."
    else
        info "GLIBC meets the ${MODERN_PUFFERPANEL_VERSION} requirement; selecting PufferPanel ${pufferpanel_version}."
    fi

    info "Installing repository prerequisites."
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg python3 git wget

    recover_partial_installation

    info "Configuring the official PufferPanel package repository."
    install_repository
    apt-get update -y

    verify_package_available "$pufferpanel_version"
    info "Installing PufferPanel ${pufferpanel_version}."
    apt-get install -y "pufferpanel=${pufferpanel_version}"

    if [[ -f "$CONFIG_FILE" ]]; then
        local port
        read -r -p "  Web port [8080]: " port
        port="${port:-8080}"
        set_panel_port "$port"
        ok "PufferPanel web port set to $port."
    else
        fail "PufferPanel installed without its expected configuration file."
        exit 1
    fi

    create_admin
    systemctl enable --now pufferpanel
    verify_pufferpanel_installation
    ok "PufferPanel is enabled and running."
    printf '\n  Open the panel at http://SERVER_IP:%s\n' "${port:-8080}"
}

main "$@"