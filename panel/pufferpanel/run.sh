#!/bin/bash
# ==========================================
# INFINITE LABS AIO CMD - PufferPanel Installer
# ==========================================
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ \ -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

function install_pufferpanel() {
    echo -e "\Starting PufferPanel Installation... \"
    
    # Official Repository Setup (Safely)
    curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash
    
    # Installation
    apt-get update
    apt-get install -y pufferpanel
    
    # Start/Enable service
    systemctl enable pufferpanel
    systemctl start pufferpanel
    echo -e "\PufferPanel service installed and started. \"
}

function configure_port() {
    read -p "Enter PufferPanel port (default 8080): " port
    port=\
    # Safely update JSON config (simplified for now, ideally using jq)
    if [[ -f /etc/pufferpanel/config.json ]]; then
        sed -i 's/"host": "0.0.0.0:8080"/"host": "0.0.0.0:'\'"/' /etc/pufferpanel/config.json
        systemctl restart pufferpanel
        echo -e "\Port updated to \. \"
    fi
}

function create_admin() {
    read -p "Admin Username: " adminUser
    read -rsp "Admin Password: " adminPass
    echo ""
    read -p "Admin Email: " adminEmail
    
    if command -v pufferpanel &> /dev/null; then
        pufferpanel user add --name "\" --password "\" --email "\" --admin
        echo -e "\Admin user created. \"
    else
        echo -e "\PufferPanel CLI not found. \"
    fi
}

while true; do
    echo -e "\n\--- PufferPanel Manager ---\"
    echo "1. Install PufferPanel"
    echo "2. Configure Port"
    echo "3. Create Admin User"
    echo "4. Service Status"
    echo "0. Exit"
    read -p "Select: " choice
    case \ in
        1) install_pufferpanel ;;
        2) configure_port ;;
        3) create_admin ;;
        4) systemctl status pufferpanel ;;
        0) break ;;
        *) echo "Invalid." ;;
    esac
done
