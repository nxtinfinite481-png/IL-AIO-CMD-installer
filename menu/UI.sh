#!/usr/bin/env bash

# ===========================================================
# INFINITE LABS AIO CMD
# Build. Create. Scale.
# ===========================================================

# --- COLORS (REFERENCE PALETTE) ---
B_BLUE='\033[1;38;5;33m'
B_CYAN='\033[1;38;5;51m'
B_PURPLE='\033[1;38;5;141m'
B_GREEN='\033[1;38;5;82m'
B_RED='\033[1;38;5;196m'
GOLD='\033[38;5;220m'
W='\033[1;38;5;255m'
G='\033[0;38;5;244m'
BG_SHADE='\033[48;5;236m'
NC='\033[0m'

readonly BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

get_metrics() {
    CPU=$(top -bn1 2>/dev/null | awk -F'[,:% ]+' '/Cpu\(s\)/ {print int($3+$5); found=1} END {if (!found) print "??"}')
    RAM=$(free 2>/dev/null | awk '/^Mem:/ {printf "%.0f", $3*100/$2; found=1} END {if (!found) print "??"}')
    UPT=$(uptime -p 2>/dev/null | sed 's/^up //' || echo "Unknown")
    DISK=$(df -h / 2>/dev/null | awk 'NR==2 {print $5; found=1} END {if (!found) print "??"}')
    CURRENT_HOST=$(hostname 2>/dev/null || echo "unknown")
}

run_module() {
    local relative_path="$1"
    local module_path="${BASE_DIR}/${relative_path}"

    if [[ ! -f "$module_path" ]]; then
        echo -e "\n ${B_RED}✘ Module unavailable:${NC} ${relative_path}"
        sleep 1
        return 1
    fi

    bash "$module_path"
}

render_ui() {
    clear 2>/dev/null || true
    get_metrics

    echo -e " ${B_BLUE}${NC}${BG_SHADE}${W} Host ${CURRENT_HOST} ${NC}${B_BLUE}${NC}  ${B_PURPLE}${NC}${BG_SHADE}${W} Uptime ${UPT} ${NC}${B_PURPLE}${NC}"
    echo -e " ${B_GREEN}${NC}${BG_SHADE}${W} Disk ${DISK} ${NC}${B_GREEN}${NC}  ${B_CYAN}${NC}${BG_SHADE}${W} CPU ${CPU}%  RAM ${RAM}% ${NC}${B_CYAN}${NC}"
    echo
    echo -e "${B_CYAN}   ██╗███╗   ██╗███████╗██╗███╗   ██╗██╗████████╗███████╗${NC}"
    echo -e "${B_CYAN}   ██║████╗  ██║██╔════╝██║████╗  ██║██║╚══██╔══╝██╔════╝${NC}"
    echo -e "${B_PURPLE}   ██║██╔██╗ ██║█████╗  ██║██╔██╗ ██║██║   ██║   █████╗  ${NC}"
    echo -e "${B_PURPLE}   ██║██║╚██╗██║██╔══╝  ██║██║╚██╗██║██║   ██║   ██╔══╝  ${NC}"
    echo -e "${GOLD}   ██║██║ ╚████║██║     ██║██║ ╚████║██║   ██║   ███████╗${NC}"
    echo -e "${GOLD}   ╚═╝╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚══════╝${NC}"
    echo -e "                    ${G}INFINITE LABS AIO CMD${NC}"
    echo -e "                    ${G}Build. Create. Scale.${NC}"
    echo -e " ${G}────────────────────────────────────────────────────────────────────────${NC}"
    echo -e " ${W}◉ SYSTEM STATUS${NC}"
    printf "   ${G}CPU:${NC} ${B_CYAN}%3s%%${NC}   ${G}RAM:${NC} ${B_PURPLE}%3s%%${NC}   ${G}Network:${NC} ${B_GREEN}● READY${NC}\n" "$CPU" "$RAM"
    echo
    echo -e " ${B_CYAN} CORE SERVICES${NC}"
    echo -e " ${G}├─${NC} ${W}[1]${NC} VPS / VM Setup       ${G}├─${NC} ${W}[4]${NC} Toolbox"
    echo -e " ${G}├─${NC} ${W}[2]${NC} Panels               ${G}├─${NC} ${W}[5]${NC} Blueprint Themes"
    echo -e " ${G}└─${NC} ${W}[3]${NC} Wings / Node         ${G}└─${NC} ${W}[6]${NC} Extras"
    echo
    echo -e " ${B_PURPLE} MAINTENANCE${NC}"
    echo -e " ${G}└─${NC} ${B_RED}[0]${NC} Exit"
    echo -e " ${G}────────────────────────────────────────────────────────────────────────${NC}"
    echo -ne " ${B_CYAN}➜${NC} ${W}Enter Option${NC} ${G}(0-6):${NC} "
}

while true; do
    render_ui
    read -r opt

    case "$opt" in
        1) run_module "setup vm/menu.sh" ;;
        2) run_module "panel/1.sh" ;;
        3) run_module "wings/run.sh" ;;
        4) run_module "toolbox/run.sh" ;;
        5) run_module "thame/run.sh" ;;
        6) run_module "Extras/run.sh" ;;
        0|exit|quit)
            echo -e "\n ${B_RED}● DISCONNECTED${NC}  Goodbye, INFINITE LABS."
            exit 0
            ;;
        *)
            echo -e "\n ${B_RED}✘ Invalid Option! Please try again.${NC}"
            sleep 0.8
            ;;
    esac
done