#!/usr/bin/env bash

set -Eeuo pipefail

readonly CONFIG_FILE="/etc/pufferpanel/config.json"
readonly INSTALLER="${BASH_SOURCE[0]%/*}/install.sh"
readonly SERVICE_OVERRIDE_DIR="/etc/systemd/system/pufferpanel.service.d"
readonly SERVICE_OVERRIDE_FILE="$SERVICE_OVERRIDE_DIR/10-infinite-labs-legacy.conf"
readonly REPOSITORY_SOURCE="/etc/apt/sources.list.d/pufferpanel_pufferpanel.list"
readonly REPOSITORY_KEYRING="/etc/apt/keyrings/pufferpanel_pufferpanel-archive-keyring.gpg"
readonly LEGACY_REPOSITORY_KEY="/etc/apt/trusted.gpg.d/pufferpanel_pufferpanel.gpg"

RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
CYAN='\033[38;5;51m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
WHITE='\033[38;5;255m'
NC='\033[0m'

pause() {
    printf '\n  Press Enter to return to the panel manager...'
    read -r
}

status_msg() {
    local type="$1"
    local message="$2"
    case "$type" in
        OK)   printf '  [%b✔%b] %s\n' "$GREEN" "$NC" "$message" ;;
        ERR)  printf '  [%b✘%b] %s\n' "$RED" "$NC" "$message" ;;
        INFO) printf '  [%b➜%b] %s\n' "$CYAN" "$NC" "$message" ;;
        WAIT) printf '  [%b…%b] %s\n' "$PURPLE" "$NC" "$message" ;;
    esac
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        status_msg ERR "Run the PufferPanel manager as root."
        exit 1
    fi
}

installed() {
    command -v pufferpanel >/dev/null 2>&1 && [[ -f "$CONFIG_FILE" ]]
}

service_action() {
    local action="$1"
    local verb
    case "$action" in
        start) verb="Starting" ;;
        stop) verb="Stopping" ;;
        restart) verb="Restarting" ;;
        *) verb="${action^}ing" ;;
    esac

    if ! installed; then
        status_msg ERR "PufferPanel is not installed."
        return 1
    fi

    status_msg WAIT "$verb PufferPanel service..."
    if systemctl "$action" pufferpanel; then
        status_msg OK "PufferPanel service ${action} completed."
    else
        status_msg ERR "PufferPanel service ${action} failed."
        return 1
    fi
}

show_service_status() {
    if ! command -v systemctl >/dev/null 2>&1; then
        status_msg ERR "systemctl is not available on this host."
        return 1
    fi

    if systemctl is-active --quiet pufferpanel; then
        status_msg OK "PufferPanel is active."
    else
        status_msg ERR "PufferPanel is not active."
    fi

    systemctl --no-pager --full status pufferpanel || true
}

show_configured_port() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        printf '%s' "not configured"
        return
    fi

    python3 - "$CONFIG_FILE" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)

web = config.get("web")
host = web.get("host") if isinstance(web, dict) else config.get("host")
print(host or "not configured")
PY
}

set_panel_port() {
    local port="$1"
    if ! [[ "$port" =~ ^[0-9]+$ ]] || ((port < 1024 || port > 65535)); then
        status_msg ERR "Port must be a number from 1024 through 65535."
        return 1
    fi

    python3 - "$CONFIG_FILE" "$port" <<'PY'
import json
import os
import pathlib
import stat
import sys
import tempfile

config_path = pathlib.Path(sys.argv[1])
port = int(sys.argv[2])

if not config_path.is_file():
    raise SystemExit(f"Missing PufferPanel config: {config_path}")

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

configure_panel() {
    if ! installed; then
        status_msg ERR "Install PufferPanel before configuring it."
        return 1
    fi

    local current_port
    current_port="$(show_configured_port)"
    printf '  Current listener: %s\n' "$current_port"
    local port
    read -r -p "  New web port [8080]: " port
    port="${port:-8080}"

    if set_panel_port "$port"; then
        status_msg OK "PufferPanel web port set to $port."
        read -r -p "  Restart PufferPanel now? [Y/n]: " answer
        if [[ ! "$answer" =~ ^[Nn]$ ]]; then
            service_action restart
        fi
    else
        status_msg ERR "PufferPanel port was not changed."
        return 1
    fi
}

create_admin() {
    if ! installed; then
        status_msg ERR "Install PufferPanel before creating an administrator."
        return 1
    fi

    status_msg INFO "Starting the official interactive administrator creation command."
    printf '  It will prompt for credentials and admin confirmation without storing them in this script.\n'
    pufferpanel user add
}

uninstall_panel() {
    printf '\n  %bThis removes the PufferPanel package and its module configuration.%b\n' "$PURPLE" "$NC"
    printf '  It does not remove sudo, system binaries, or unrelated data.\n'

    local answer
    read -r -p "  Uninstall PufferPanel? [y/N]: " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        status_msg INFO "PufferPanel uninstall cancelled."
        return 0
    fi

    status_msg INFO "Stopping PufferPanel service..."
    systemctl disable --now pufferpanel 2>/dev/null || true

    status_msg INFO "Uninstalling the PufferPanel package..."
    if ! apt-get purge -y pufferpanel; then
        status_msg ERR "PufferPanel package removal failed."
        return 1
    fi

    if [[ -d "/etc/pufferpanel" ]]; then
        status_msg INFO "Removing PufferPanel configuration..."
        rm -rf -- "/etc/pufferpanel"
    fi

    rm -f -- "$SERVICE_OVERRIDE_FILE"
    rmdir --ignore-fail-on-non-empty "$SERVICE_OVERRIDE_DIR" 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true
    rm -f -- "$REPOSITORY_SOURCE" "$REPOSITORY_KEYRING" "$LEGACY_REPOSITORY_KEY"
    status_msg OK "PufferPanel has been uninstalled."
}

draw_menu() {
    clear 2>/dev/null || true
    printf '%b\n' "${PURPLE}┌──────────────────────────────────────────────────────────┐${NC}"
    printf '%b\n' "${PURPLE}│${NC}  ${CYAN}◈  INFINITE LABS PUFFERPANEL MANAGER${NC}               ${PURPLE}│${NC}"
    printf '%b\n' "${PURPLE}└──────────────────────────────────────────────────────────┘${NC}"
    printf '  %bStatus:%b %s\n' "$GRAY" "$NC" "$(if installed; then echo -e "${GREEN}INSTALLED${NC}"; else echo -e "${RED}NOT INSTALLED${NC}"; fi)"
    printf '  %bListener:%b %s\n' "$GRAY" "$NC" "$(show_configured_port)"
    printf '%b\n\n' "${GRAY}────────────────────────────────────────────────────────────${NC}"
    printf '  %b[1]%b Install PufferPanel\n' "$CYAN" "$WHITE"
    printf '  %b[2]%b Configure web port\n' "$CYAN" "$WHITE"
    printf '  %b[3]%b Create administrator\n' "$CYAN" "$WHITE"
    printf '  %b[4]%b Restart service\n' "$CYAN" "$WHITE"
    printf '  %b[5]%b Start service\n' "$CYAN" "$WHITE"
    printf '  %b[6]%b Stop service\n' "$CYAN" "$WHITE"
    printf '  %b[7]%b Service status\n' "$CYAN" "$WHITE"
    printf '  %b[8]%b Uninstall PufferPanel\n' "$CYAN" "$WHITE"
    printf '  %b[0]%b Back\n\n' "$RED" "$WHITE"
}

main() {
    require_root

    while true; do
        draw_menu
        read -r -p "  ➜ Select option [0-8]: " choice
        case "$choice" in
            1)
                bash "$INSTALLER"
                pause
                ;;
            2)
                configure_panel
                pause
                ;;
            3)
                create_admin
                pause
                ;;
            4)
                service_action restart
                pause
                ;;
            5)
                service_action start
                pause
                ;;
            6)
                service_action stop
                pause
                ;;
            7)
                show_service_status
                pause
                ;;
            8)
                uninstall_panel
                pause
                ;;
            0)
                exit 0
                ;;
            *)
                status_msg ERR "Invalid selection."
                sleep 1
                ;;
        esac
    done
}

main "$@"