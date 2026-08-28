#!/bin/bash
# ==========================================================
# INFINITE LABS AIO CMD - Professional Dashboard
# ==========================================================

# Colors
CYAN='\033[1;36m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
WHITE='\033[1;37m'
GRAY='\033[1;30m'
NC='\033[0m'

render_ui() {
    clear
    # System Status
    CPU=\
    MEM=\
    UPTIME=\
    
    echo -e "==============================================================="
    echo -e "                 INFINITE LABS AIO CMD"
    echo -e "                    Build. Create. Scale."
    echo -e "==============================================================="
    echo -e "SYSTEM STATUS:"
    echo -e " CPU: \% | RAM: \% | Uptime: \"
    echo -e "==============================================================="
}
