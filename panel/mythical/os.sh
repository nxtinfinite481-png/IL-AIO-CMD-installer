#!/bin/bash

set -e
readonly BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "🧠 Detecting OS..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ OS detect nahi hua"
    exit 1
fi

echo "📌 OS Detected: $OS"

# Auto run based on OS
if [[ "$OS" == "ubuntu" ]]; then
    echo "🚀 Running Ubuntu installer..."
    bash "$BASE_DIR/panel/mythical/Ubuntu.sh"

elif [[ "$OS" == "debian" ]]; then
    echo "🚀 Running Debian installer..."
    bash "$BASE_DIR/panel/mythical/Debian.sh"
else
    echo "❌ Unsupported OS: $OS"
    exit 1
fi

echo "✅ Done! System ready."
