#!/bin/bash
# ==========================================
# INFINITE LABS AIO CMD - Docker Manager
# ==========================================
GRAY='\033[1;30m'
WHITE='\033[1;37m'
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m'

function install_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "\Installing Docker... \"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
    else
        echo -e "\Docker is already installed.\"
    fi
}

function show_info() {
    echo -e "\n\--- System & Docker Info ---\"
    echo -e "\Docker Version:\ \Not installed"
    echo -e "\n\Active Containers:\"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"
    echo -ne "\n\Press Enter to return...\"
    read
}

# Add reference features (create/uninstall)
function uninstall_container() {
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    echo -ne "\n  Enter CONTAINERNAME to remove: "
    read TARGET_CONTAINER
    if [ -n "\" ]; then
        docker rm -f "\" 2>/dev/null
    fi
}

while true; do
    echo -e "\n\--- DOCKER MANAGER ---\"
    echo -e "  1) Check/Install Docker"
    echo -e "  2) Info"
    echo -e "  3) Uninstall Container"
    echo -e "  0) Exit"
    read -p "  Select: " CHOICE
    case \ in
        1) install_docker ;;
        2) show_info ;;
        3) uninstall_container ;;
        0) break ;;
        *) echo "Invalid." ;;
    esac
done
