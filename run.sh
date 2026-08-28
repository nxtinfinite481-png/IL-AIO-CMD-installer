#!/bin/bash
# ==========================================================
# INFINITE LABS AIO CMD - Public Launcher
# ==========================================================

# ANSI Colors
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# Bootstrap Logic
INSTALL_DIR="/tmp/infinite-labs-aio"
echo -e "\[i] Initializing workspace in \... \"

if [ ! -d "\/.git" ]; then
    mkdir -p "\"
    cd "\" || exit 1
    git clone -q https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer.git .
else
    cd "\" || exit 1
fi

BASE_DIR="\"

# Load UI
if [ -f "\/menu/UI.sh" ]; then
    source "\/menu/UI.sh"
else
    echo -e "\UI module not found at \/menu/UI.sh"
    exit 1
fi

# Main Loop
while true; do
    render_ui
    echo " 1) VPS / VPS EGG"
    echo " 2) Panel Manager"
    echo " 3) Wings Manager"
    echo " 4) Blueprint Extensions"
    echo " 5) Themes"
    echo " 6) Docker Manager"
    echo " 7) Toolbox"
    echo " 8) Extras"
    echo " 9) Setup VM"
    echo " 0) Exit"
    echo -e ""
    read -p " ➜ Select [0-9]: " choice

    case "\" in
        1) bash "\/panel/pterodactyl/vps/run.sh" ;;
        2) bash "\/panel/menu.sh" ;;
        3) bash "\/wings/run.sh" ;;
        4) bash "\/thame/extension.sh" ;;
        5) bash "\/thame/thames.sh" ;;
        6) bash "\/Extras/docker.sh" ;;
        7) bash "\/toolbox/run.sh" ;;
        8) bash "\/Extras/run.sh" ;;
        9) bash "\/setup vm/menu.sh" ;;
        0) exit 0 ;;
        *) echo -e "\✘ Invalid option."; sleep 1 ;;
    esac
    read -p " Press enter to continue..."
done
