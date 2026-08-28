#!/bin/bash
# ==========================================================
# INFINITE LABS AIO CMD - Main Entry
# ==========================================================

source ./menu/UI.sh

while true; do
    render_ui
    echo "1. Pterodactyl Panel"
    echo "2. Wings Manager"
    echo "3. Blueprint Extensions"
    echo "4. Themes"
    echo "5. Toolbox"
    echo "6. Extras"
    echo "8. Docker Manager"
    echo "7. Exit"
    echo -e ""
    read -p "Select an option [1-8]: " choice

    case \ in
        1) bash panel/pterodactyl/run.sh ;;
        2) echo "Wings Manager..." ;;
        3) bash thame/extension.sh ;;
        4) bash thame/thames.sh ;;
        5) echo "Toolbox..." ;;
        6) bash Extras/run.sh ;;
        8) bash Extras/docker.sh ;;
        7) bash "setup vm/menu.sh"
        9) exit 0 ;;
        *) echo "Invalid option." ;;
    esac
    read -p "Press enter to continue..."
done




