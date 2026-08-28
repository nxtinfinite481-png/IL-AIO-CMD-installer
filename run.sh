#!/bin/bash
source ./ui.sh

while true; do
    render_header
    render_status
    
    echo -e "DEPLOYMENT & SERVICES"
    echo " [1] VPS           [2] Panel           [3] Wings / Node"
    echo " [4] Toolbox       [5] Themes          [6] System"
    echo " [7] Container     [8] Docker          [9] Extras"
    echo ""
    echo -e "PANEL MANAGEMENT"
    echo " [10] Pterodactyl  [11] PufferPanel   [12] Convoy"
    echo " [13] Jexactyl     [14] Mythical      [15] Paymenter"
    echo " [16] Pteroca      [17] Reviactyl     [18] WHMC"
    echo ""
    echo -e "OTHER TOOLS"
    echo " [19] Setup VM     [20] Blueprint / Thame"
    echo ""
    echo -e " [0] Exit"
    echo ""
    read -p " ➜ Select an option: " choice

    case \ in
        1) bash panel/pterodactyl/vps/run.sh ;;
        2) bash panel/menu.sh ;;
        3) bash wings/run.sh ;;
        4) bash toolbox/run.sh ;;
        5) bash thame/thames.sh ;;
        6) echo "System Module..." ;;
        7) echo "Container Module..." ;;
        8) bash Extras/docker.sh ;;
        9) bash Extras/run.sh ;;
        10) bash panel/pterodactyl/run.sh ;;
        11) bash panel/pufferpanel/run.sh ;;
        12) echo "Convoy..." ;;
        13) echo "Jexactyl..." ;;
        14) echo "Mythical..." ;;
        15) echo "Paymenter..." ;;
        16) echo "Pteroca..." ;;
        17) echo "Reviactyl..." ;;
        18) echo "WHMC..." ;;
        19) bash 'setup vm/menu.sh' ;;
        20) bash thame/extension.sh ;;
        0) exit 0 ;;
        *) echo -e "✘ Invalid option."; sleep 1 ;;
    esac
done
