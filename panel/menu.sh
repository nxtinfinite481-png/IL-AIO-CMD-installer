#!/bin/bash
# ==========================================
# INFINITE LABS AIO CMD - Panel Manager
# ==========================================
while true; do
    echo "1. Pterodactyl"
    echo "2. PufferPanel"
    echo "0. Back"
    read -p "Select panel: " choice
    case \ in
        1) bash panel/pterodactyl/run.sh ;;
        2) bash panel/pufferpanel/run.sh ;;
        0) break ;;
    esac
done
