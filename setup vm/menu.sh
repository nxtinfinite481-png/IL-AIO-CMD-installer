#!/usr/bin/env bash

# --- VPS / VM MENU ---
R="\e[31m"; G="\e[32m"; Y="\e[33m"; B="\e[34m"; C="\e[36m"; M="\e[35m"; W="\e[37m"; N="\e[0m"
readonly BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

print_header() {
    clear 2>/dev/null || true
    echo -e "\n${C}╔════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${W}             I N F I N I T E   L A B S          ${C}║${N}"
    echo -e "${C}║${W}                  VPS / VM MENU                 ${C}║${N}"
    echo -e "${C}╚════════════════════════════════════════════════╝${N}\n"
}

print_option() {
    local num="$1"
    local text="$2"
    local color="$3"
    echo -e "  ${color}[$num]${N} ${W}${text}${N}"
}

pause() {
    echo
    read -r -p "Press Enter to return..."
}

run_vm_module() {
    local relative_path="$1"
    local module_path="${BASE_DIR}/${relative_path}"
    if [[ ! -f "$module_path" ]]; then
        echo -e "${R}Module unavailable: ${relative_path}${N}"
        pause
        return 1
    fi
    bash "$module_path"
    pause
}

while true; do
    print_header
    print_option "1" "Run VM 1 (KVM)" "$Y"
    print_option "2" "Run VM 2 (no KVM)" "$B"
    print_option "3" "Run VM 3 (complete setup)" "$B"
    print_option "4" "Back" "$R"
    echo -e "\n${M}════════════════════════════════════════════════${N}"
    echo -ne "${W}Select Option → ${N}"
    read -r op

    case "$op" in
        1) run_vm_module "setup vm/vm-1.sh" ;;
        2) run_vm_module "setup vm/vm-2.sh" ;;
        3) run_vm_module "setup vm/vm-3.sh" ;;
        4) clear 2>/dev/null || true; exit 0 ;;
        *) echo -e "\n${R}Invalid Option! Please try again.${N}"; sleep 1 ;;
    esac
done