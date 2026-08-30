#!/usr/bin/env bash

set -Eeuo pipefail

readonly CONFIG_FILE="/etc/pufferpanel/config.json"
readonly KEYRING_FILE="/etc/apt/keyrings/pufferpanel.gpg"
readonly SOURCES_FILE="/etc/apt/sources.list.d/pufferpanel.sources"
readonly KEY_URL="https://packagecloud.io/pufferpanel/pufferpanel/gpgkey"

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
    local temporary_key
    temporary_key="$(mktemp)"
    trap 'rm -f -- "$temporary_key"' RETURN

    install -d -m 0755 /etc/apt/keyrings
    curl --fail --silent --show-error --location "$KEY_URL" -o "$temporary_key"
    gpg --batch --dearmor --yes --output "$KEYRING_FILE" "$temporary_key"
    chmod 0644 "$KEYRING_FILE"

    cat > "$SOURCES_FILE" <<'EOF'
X-Repolib-Name: PufferPanel
Types: deb
URIs: https://packagecloud.io/pufferpanel/pufferpanel/any/
Suites: any
Components: main
Signed-By: /etc/apt/keyrings/pufferpanel.gpg
EOF
    chmod 0644 "$SOURCES_FILE"
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

    printf '%b\n' "${PURPLE}==============================================${NC}"
    printf '%b\n' "${CYAN}       INFINITE LABS PUFFERPANEL SETUP       ${NC}"
    printf '%b\n\n' "${PURPLE}==============================================${NC}"

    info "Installing repository prerequisites."
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg apt-transport-https python3

    info "Configuring the official PufferPanel package repository."
    install_repository
    apt-get update -y

    info "Installing PufferPanel."
    apt-get install -y pufferpanel

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
    ok "PufferPanel is enabled and running."
    printf '\n  Open the panel at http://SERVER_IP:%s\n' "${port:-8080}"
}

main "$@"