#!/usr/bin/env bash

# --- EXTRAS MENU ---
RED="\e[31m"; GREEN="\e[32m"; CYAN="\e[36m"; GRAY="\e[90m"; NC="\e[0m"
readonly BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

pause() {
    read -r -p "Press Enter to continue..."
}

run_extra() {
    local relative_path="$1"
    local module_path="${BASE_DIR}/${relative_path}"
    if [[ ! -f "$module_path" ]]; then
        echo -e "${RED}Module unavailable: ${relative_path}${NC}"
        pause
        return 1
    fi
    bash "$module_path"
    pause
}

while true; do
    clear 2>/dev/null || true
    echo -e "${GRAY}────────────── INFINITE LABS EXTRAS ──────────────${NC}"
    echo -e "${CYAN} 1) Cockpit"
    echo -e " 2) CasaOS"
    echo -e " 3) 1Panel installer"
    echo -e " 4) LXC/LXD helper"
echo -e " 5) Docker"
echo -e " 6) LVM helper"
echo -e " 7) Back${NC}"
    echo -e "${GRAY}──────────────────────────────────────────────────${NC}"
    read -r -p "Select → " choice

    case "$choice" in
        1) run_extra "Extras/Cockpit.sh" ;;
        2) run_extra "Extras/casaos.sh" ;;
        3) run_extra "Extras/cpanel.sh" ;;
        4) echo -e "${CYAN}Adding the current user to the LXD group...${NC}"; sudo usermod -aG lxd "$(id -un)"; pause ;;
        5) run_extra "Extras/docker.sh" ;;
        6) run_extra "Extras/lvm.sh" ;;
        7) clear 2>/dev/null || true; exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}"; pause ;;
    esac
done