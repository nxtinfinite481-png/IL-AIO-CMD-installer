#!/usr/bin/env bash

# --- CONFIG & REFERENCE PALETTE ---
CYAN='\033[38;5;51m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
WHITE='\033[38;5;255m'
GREEN='\033[38;5;82m'
RED='\033[38;5;196m'
GOLD='\033[38;5;220m'
NC='\033[0m'

readonly BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

pause() {
    echo
    read -r -p "  Press Enter to return to panels..."
}

run_panel() {
    local relative_path="$1"
    local module_path="${BASE_DIR}/${relative_path}"

    if [[ ! -f "$module_path" ]]; then
        echo -e "  ${RED}✘ Module unavailable:${NC} ${relative_path}"
        pause
        return 1
    fi

    bash "$module_path"
    pause
}

get_metrics() {
    UPT=$(uptime -p 2>/dev/null | sed 's/up //' || echo "Unknown")
    LOAD=$(uptime 2>/dev/null | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs || echo "Unknown")
}

show_header() {
    get_metrics
    clear 2>/dev/null || true
    echo -e "${PURPLE}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}│${NC}  ${CYAN}◈  INFINITE LABS PANEL MANAGER${NC} ${GRAY}:: ${NC}${GRAY}$(date +"%H:%M")${NC}  ${PURPLE}│${NC}"
    echo -e "${PURPLE}└──────────────────────────────────────────────────────────┘${NC}"
    echo -e "  ${CYAN}SYSTEM STATUS${NC}"
    echo -e "  ${GRAY}├─ Uptime :${NC} ${WHITE}$UPT${NC}"
    echo -e "  ${GRAY}└─ Load   :${NC} ${WHITE}$LOAD${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────${NC}"
}

panel_menu() {
    while true; do
        show_header
        echo -e "  ${GOLD}  AVAILABLE PANEL MODULES${NC}"
        echo -e "  ${GRAY}┌──────────────────────────┬──────────────────────────┐${NC}"
        echo -e "  ${GRAY}│${NC} ${PURPLE}[1]${NC} Pterodactyl          ${GRAY}│${NC} ${PURPLE}[5]${NC}  Convoy installer    ${GRAY}│${NC}"
        echo -e "  ${GRAY}│${NC} ${PURPLE}[2]${NC} Reviactyl             ${GRAY}│${NC} ${PURPLE}[6]${NC}  Jexactyl installer  ${GRAY}│${NC}"
        echo -e "  ${GRAY}│${NC} ${PURPLE}[3]${NC} Paymenter             ${GRAY}│${NC} ${PURPLE}[7]${NC}  PteroCA installer   ${GRAY}│${NC}"
        echo -e "  ${GRAY}│${NC} ${PURPLE}[4]${NC} MythicalDash          ${GRAY}│${NC} ${PURPLE}[8]${NC}  WHMC installer      ${GRAY}│${NC}"
        echo -e "  ${GRAY}│${NC} ${RED}[0]${NC} Back                 ${GRAY}│${NC}                          │${NC}"
        echo -e "  ${GRAY}└──────────────────────────┴──────────────────────────┘${NC}"
        echo
        echo -ne "  ${CYAN}λ${NC} ${WHITE}Select Module [0-8]:${NC} "
        read -r choice

        case "$choice" in
            1) echo -e "  ${CYAN}➜ Executing Pterodactyl routine...${NC}"; run_panel "panel/pterodactyl/run.sh" ;;
            2) echo -e "  ${CYAN}➜ Executing Reviactyl routine...${NC}"; run_panel "panel/reviactyl/run.sh" ;;
            3) echo -e "  ${CYAN}➜ Executing Paymenter routine...${NC}"; run_panel "panel/paymenter/run.sh" ;;
            4) echo -e "  ${CYAN}➜ Executing MythicalDash routine...${NC}"; run_panel "panel/mythical/run.sh" ;;
            5) echo -e "  ${CYAN}➜ Executing Convoy installer...${NC}"; run_panel "panel/Convoy/install.sh" ;;
            6) echo -e "  ${CYAN}➜ Executing Jexactyl installer...${NC}"; run_panel "panel/Jexactyl/install.sh" ;;
            7) echo -e "  ${CYAN}➜ Executing PteroCA installer...${NC}"; run_panel "panel/pteroca/install.sh" ;;
            8) echo -e "  ${CYAN}➜ Executing WHMC installer...${NC}"; run_panel "panel/whmc/install.sh" ;;
            0) echo -e "\n  ${RED}Returning to the main console.${NC}"; exit 0 ;;
            *) echo -e "  ${RED}⚠ Invalid Selection${NC}"; sleep 1 ;;
        esac
    done
}

panel_menu