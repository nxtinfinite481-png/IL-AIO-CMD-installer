#!/bin/bash
# ==========================================================
# INFINITE LABS AIO CMD - Public Launcher & Bootstrap
# ==========================================================

# 1. Setup Base Directory
if [[ "\" == *"/dev/fd/"* ]] || [[ ! -f "run.sh" ]]; then
    # Running from pipe or outside project directory - bootstrap required
    INSTALL_DIR="/tmp/infinite-labs-aio"
    echo -e "\033[1;36m[i] Initializing workspace in \...\033[0m"
    mkdir -p "\"
    cd "\" || exit 1
    
    # Clone or download if not present
    if [[ ! -d ".git" ]]; then
        git clone -q https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer.git .
    fi
    BASE_DIR="\"
else
    # Running from existing clone
    BASE_DIR="\E:\PROJECTS\IL AIO CMD"
fi

# 2. Load UI
source "\/menu/UI.sh"

# 3. Main Loop
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

    case \ in
        1) bash "\/panel/pterodactyl/vps/run.sh" ;;
        2) bash "\/panel/menu.sh" ;;
        3) bash "\/wings/run.sh" ;;
        4) bash "\/thame/extension.sh" ;;
        5) bash "\/thame/thames.sh" ;;
        6) bash "\/Extras/docker.sh" ;;
        7) bash "\/toolbox/run.sh" ;;
        8) bash "\/Extras/run.sh" ;;
        9) bash "\/setup vm/menu.sh" ;;
        0) echo "Exiting..."; exit 0 ;;
        *) echo -e "\033[1;31m✘ Invalid option.\033[0m"; sleep 1 ;;
    esac
    read -p " Press enter to continue..."
done
