#!/bin/bash

# ==================================================
#  SERVER UTILITY MENU | v3.0 (Dashboard UI)
# ==================================================

# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
GRAY='\033[1;30m'
NC='\033[0m'
readonly BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# --- HELPER FUNCTIONS ---
pause() {
    echo ""
    read -n 1 -s -r -p "Press any key to continue..."
    echo ""
}

run_tool() {
    local relative_path="$1"
    local tool_path="${BASE_DIR}/${relative_path}"
    if [[ ! -f "$tool_path" ]]; then
        echo -e "${RED}Tool unavailable: ${relative_path}${NC}"
        pause
        return 1
    fi
    bash "$tool_path"
    pause
}

# --- HEADER UI ---
draw_header() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   ${PURPLE}⚡ SERVER CONTROL PANEL ⚡${NC}                           ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"

    USER=$(whoami)
    HOST=$(hostname)

    RAM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    CPU=$(uptime | awk -F'load average:' '{ print $2 }')
    IP=$(curl -s ifconfig.me 2>/dev/null)

    printf "${CYAN}║${NC} ${GREEN}User:${NC} %-10s ${GREEN}Host:${NC} %-20s ${CYAN}║${NC}\n" "$USER" "$HOST"
    printf "${CYAN}║${NC} ${YELLOW}RAM:${NC} %-15s ${YELLOW}CPU:${NC} %-20s ${CYAN}║${NC}\n" "$RAM" "$CPU"
    printf "${CYAN}║${NC} ${BLUE}IP:${NC} %-48s ${CYAN}║${NC}\n" "${IP:-Unavailable}"

    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ===================== TOOLS MENU =====================
tools_menu() {
    while true; do
        clear

        draw_header

        # -- SECTION 1 --
        echo -e "${BLUE}  [ ACCESS & NETWORK ]${NC}"
        echo -e "  ${GREEN}1)${NC} Root Access         ${GRAY}:: Enable Root/Sudo${NC}"
        echo -e "  ${GREEN}2)${NC} Tailscale           ${GRAY}:: Mesh VPN Setup${NC}"
        echo -e "  ${GREEN}3)${NC} Zerotier            ${GRAY}:: Wifi VPN Setup${NC}"
        echo -e "  ${GREEN}4)${NC} Cloudflare DNS      ${GRAY}:: Tunnel & DNS${NC}"
        echo ""

        # -- SECTION 2 --
        echo -e "${YELLOW}  [ SYSTEM OPERATIONS ]${NC}"
        echo -e "  ${GREEN}5)${NC} System Info         ${GRAY}:: Specs & Status${NC}"
        echo -e "  ${GREEN}6)${NC} Port Forward        ${GRAY}:: TCP/UDP${NC}"
        echo ""

        # -- SECTION 3 --
        echo -e "${PURPLE}  [ GUI & TERMINAL ]${NC}"
        echo -e "  ${GREEN}7)${NC} Web Terminal        ${GRAY}:: Browser Shell${NC}"
        echo ""

        # -- FOOTER --
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
        echo -e "  ${RED}0) ↩ Back / Exit${NC}"
        echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"

        # -- INPUT --
        echo ""
        echo -e "${GRAY}────────────────────────────────────────────────────────────${NC}"
        echo -ne "${GREEN}➜ ${CYAN}Select Tool ${GRAY}[0-9]${CYAN} » ${NC}"
        read t

        case "$t" in
            1)
                echo -e "\n${YELLOW}⚙ Running Root Access Script...${NC}"
                run_tool "toolbox/root.sh" ;;

            2)
                echo -e "\n${YELLOW}⚙ Running Tailscale Installer...${NC}"
                run_tool "toolbox/tailscale.sh" ;;

            3)
                echo -e "\n${YELLOW}⚙ Running Zerotier Installer...${NC}"
                run_tool "toolbox/zerotier.sh" ;;

            4)
                echo -e "\n${YELLOW}⚙ Running Cloudflare Script...${NC}"
                run_tool "toolbox/cloudflare.sh" ;;

            5)
                echo -e "\n${YELLOW}⚙ Fetching System Info...${NC}"
                run_tool "toolbox/info.sh" ;;

            6)
                echo -e "\n${YELLOW}⚙ Running Port Forward Tool...${NC}"
                run_tool "toolbox/localtonet.sh" ;;

            7)
                echo -e "\n${YELLOW}⚙ Installing Web Terminal...${NC}"
                run_tool "toolbox/terminal.sh" ;;

            0)
                clear
                echo -e "${GREEN}Goodbye 👋${NC}"
                exit ;;

            *)
                echo -e "${RED}Invalid Option${NC}"
                sleep 1 ;;
        esac
    done
}

# --- RUN ---
tools_menu
