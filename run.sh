#!/bin/bash
# ==========================================================
# INFINITE LABS AIO CMD - Public Bootstrap Launcher
# ==========================================================

INSTALL_DIR="/tmp/infinite-labs-aio"

# Bootstrap Logic: Ensure we have the local repository
if [ ! -d "${INSTALL_DIR}/.git" ]; then
    echo -e "\033[1;36m[i] Initializing workspace in ${INSTALL_DIR}...\033[0m"
    mkdir -p "${INSTALL_DIR}"
    cd "${INSTALL_DIR}" || exit 1
    git clone -q https://github.com/nxtinfinite481-png/IL-AIO-CMD-installer.git .
else
    cd "${INSTALL_DIR}" || exit 1
    git pull -q origin main
fi

BASE_DIR="${INSTALL_DIR}"

# Launch the actual UI/Menu entry point
if [ -f "${BASE_DIR}/menu/UI.sh" ]; then
    bash "${BASE_DIR}/menu/UI.sh"
else
    echo -e "\033[0;31m[!] UI entry point not found at ${BASE_DIR}/menu/UI.sh\033[0m"
    exit 1
fi
