#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Google Antigravity para Termux — Menú Principal
#  Autor: @maka0024 (kuromi04)
#  GitHub: https://github.com/kuromi04/termux-antigravity
#
#  Ejecutar desde Termux: ./antigravity.sh
# ============================================================

# ── Colores ──────────────────────────────────────────────────
RESET='\e[0m'
BOLD='\e[1m'
GRAY='\e[90m'
WHITE='\e[97m'
RED='\e[91m'
GREEN='\e[92m'
YELLOW='\e[93m'
MAGENTA='\e[95m'
CYAN='\e[96m'

# ── Rutas ────────────────────────────────────────────────────
DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
ANTIGRAVITY_BIN="$DEBIAN_ROOT/Apps/IDE/Antigravity/bin/antigravity"
ANTIGRAVITY_DIR="$DEBIAN_ROOT/Apps/IDE/Antigravity"
CONFIG_DIR="$DEBIAN_ROOT/home/devroom/.antigravity"
ANTIGRAVITY_DL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz"

# ── Utilidades ───────────────────────────────────────────────
print_line()      { echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
print_line_thin() { echo -e "${GRAY}  ─────────────────────────────────────────────────${RESET}"; }
check_installed() { [ -f "$ANTIGRAVITY_BIN" ]; }

# ── Banner ───────────────────────────────────────────────────
show_banner() {
    clear
    echo ""
    echo -e "${CYAN}${BOLD}  ╔═══════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}  ║                                               ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║   ${WHITE}🌌  Google Antigravity IDE${CYAN}                  ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║   ${GRAY}Termux · Debian · Android · ARM64${CYAN}          ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║                                               ║${RESET}"
    echo -e "${CYAN}${BOLD}  ╠═══════════════════════════════════════════════╣${RESET}"
    echo -e "${CYAN}${BOLD}  ║  ${MAGENTA}Autor  ${RESET}${BOLD}@maka0024 · kuromi04${CYAN}                 ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║  ${MAGENTA}GitHub ${RESET}${BOLD}kuromi04/termux-antigravity${CYAN}          ║${RESET}"
    if check_installed; then
        echo -e "${CYAN}${BOLD}  ║  ${GREEN}Estado ${RESET}${GREEN}${BOLD}● Instalado${CYAN}                          ║${RESET}"
    else
        echo -e "${CYAN}${BOLD}  ║  ${RED}Estado ${RESET}${RED}${BOLD}○ No instalado${CYAN}                       ║${RESET}"
    fi
    echo -e "${CYAN}${BOLD}  ╚═══════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ── 1. Iniciar ───────────────────────────────────────────────
action_start() {
    show_banner
    print_line
    echo -e "  ${GREEN}${BOLD}  ▶  Iniciando Google Antigravity...${RESET}"
    print_line
    echo ""
    # Inyectar startantigravity.sh en .profile de devroom
    sed -i "/startantigravity.sh/d" \
        "${DEBIAN_ROOT}/home/devroom/.profile" 2>/dev/null || true
    echo '/Apps/IDE/Antigravity/startantigravity.sh' \
        >> "${DEBIAN_ROOT}/home/devroom/.profile"
    echo -e "  ${GRAY}  · Entrando a Debian como devroom...${RESET}"
    sleep 1
    proot-distro login debian --user devroom
    clear
}

# ── 2. Actualizar ────────────────────────────────────────────
action_update() {
    show_banner
    print_line
    echo -e "  ${YELLOW}${BOLD}  ↻  Actualizando Google Antigravity...${RESET}"
    print_line
    echo ""
    echo -e "  ${GRAY}  · Guardando configuración y scripts...${RESET}"
    cp -r "$CONFIG_DIR"                        /tmp/ag_config_bak  2>/dev/null || true
    cp "$ANTIGRAVITY_DIR/antigravity.sh"       /tmp/ag_launch.sh   2>/dev/null || true
    cp "$ANTIGRAVITY_DIR/startantigravity.sh"  /tmp/ag_start.sh    2>/dev/null || true
    cp "$ANTIGRAVITY_DIR/uninstall.sh"         /tmp/ag_uninstall.sh 2>/dev/null || true

    echo -e "  ${GRAY}  · Descargando nueva versión (~300 MB)...${RESET}"
    cd "$DEBIAN_ROOT/Apps/IDE" || exit 1
    if aria2c -x 4 -o Antigravity_new.tar.gz "$ANTIGRAVITY_DL"; then
        echo -e "  ${GRAY}  · Reemplazando binario...${RESET}"
        rm -rf Antigravity
        mkdir -p Antigravity
        tar -xzf Antigravity_new.tar.gz -C Antigravity --strip-components=1
        rm -f Antigravity_new.tar.gz
        chmod +x Antigravity/bin/antigravity
        # Restaurar scripts y configuración
        cp /tmp/ag_launch.sh    "$ANTIGRAVITY_DIR/antigravity.sh"      2>/dev/null || true
        cp /tmp/ag_start.sh     "$ANTIGRAVITY_DIR/startantigravity.sh" 2>/dev/null || true
        cp /tmp/ag_uninstall.sh "$ANTIGRAVITY_DIR/uninstall.sh"        2>/dev/null || true
        cp -r /tmp/ag_config_bak "$CONFIG_DIR"                         2>/dev/null || true
        rm -f /tmp/ag_*.sh
        rm -rf /tmp/ag_config_bak
        echo ""
        print_line
        echo -e "  ${GREEN}${BOLD}  ✓  Antigravity actualizado correctamente.${RESET}"
    else
        echo -e "  ${RED}${BOLD}  ✗  Error al descargar. Verifica tu conexión.${RESET}"
        rm -f "$DEBIAN_ROOT/Apps/IDE/Antigravity_new.tar.gz"
    fi
    print_line
    echo ""
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"
    read -r -n 1
}

# ── 3. Detener y limpiar ─────────────────────────────────────
action_stop() {
    show_banner
    print_line
    echo -e "  ${YELLOW}${BOLD}  ■  Detener y limpiar sesión${RESET}"
    print_line
    echo ""
    echo -e "  ${WHITE}  ¿Qué deseas limpiar?${RESET}"
    echo ""
    echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}Solo detener procesos${RESET}"
    echo -e "  ${CYAN}${BOLD}  2  ${RESET}${WHITE}Detener + limpiar logs${RESET}"
    echo -e "  ${CYAN}${BOLD}  3  ${RESET}${WHITE}Detener + limpiar logs + caché${RESET}"
    echo -e "  ${GRAY}  0  Cancelar${RESET}"
    echo ""
    print_line
    echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"
    read -r -n 1 stop_opt
    echo ""

    case "$stop_opt" in
        1|2|3)
            echo -e "  ${GRAY}  · Deteniendo procesos...${RESET}"
            pkill -f "antigravity"              2>/dev/null || true
            pkill -f "fluxbox"                  2>/dev/null || true
            pkill -f "thunar"                   2>/dev/null || true
            pkill -f "termux-x11"               2>/dev/null || true
            pkill -f "pulseaudio"               2>/dev/null || true
            pkill -f "proot-distro login debian" 2>/dev/null || true
            echo -e "  ${GREEN}  ✓ Procesos detenidos.${RESET}"
            ;;
    esac

    if [ "$stop_opt" = "2" ] || [ "$stop_opt" = "3" ]; then
        echo -e "  ${GRAY}  · Limpiando logs...${RESET}"
        rm -f "${DEBIAN_ROOT}/home/devroom/.antigravity/logs/"*.log 2>/dev/null || true
        rm -f "${DEBIAN_ROOT}/tmp/"*.log                            2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Logs eliminados.${RESET}"
    fi

    if [ "$stop_opt" = "3" ]; then
        echo -e "  ${GRAY}  · Limpiando caché...${RESET}"
        rm -rf "${DEBIAN_ROOT}/home/devroom/.cache/google-antigravity"        2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.config/google-antigravity/Cache" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/tmp/antigravity"*                              2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Caché eliminada.${RESET}"
    fi

    [ "$stop_opt" = "0" ] && return

    echo ""
    print_line
    echo -e "  ${GREEN}${BOLD}  ✓  Sesión detenida y limpiada.${RESET}"
    print_line
    echo ""
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"
    read -r -n 1
}

# ── 4. Terminal Debian ───────────────────────────────────────
action_terminal() {
    show_banner
    print_line
    echo -e "  ${CYAN}${BOLD}  ⚙  Abriendo terminal de Debian...${RESET}"
    print_line
    echo ""
    echo -e "  ${GRAY}  Escribe 'exit' para volver al menú.${RESET}"
    echo ""
    sleep 1
    proot-distro login debian
    clear
}

# ── 5. Desinstalar ───────────────────────────────────────────
action_uninstall() {
    show_banner
    print_line
    echo -e "  ${RED}${BOLD}  ✕  Desinstalar Google Antigravity${RESET}"
    print_line
    echo ""
    echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}Desinstalar y CONSERVAR datos de usuario${RESET}"
    echo -e "  ${RED}${BOLD}  2  ${RESET}${WHITE}Desinstalar y ELIMINAR todo${RESET}"
    echo -e "  ${GRAY}  0  Cancelar${RESET}"
    echo ""
    print_line
    echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"
    read -r -n 1 unsopt
    echo ""

    [ "$unsopt" = "0" ] && return
    if [ "$unsopt" != "1" ] && [ "$unsopt" != "2" ]; then
        echo -e "  ${YELLOW}  Opción no válida.${RESET}"; sleep 1; return
    fi

    echo -e "  ${RED}${BOLD}  ⚠  Esta acción no se puede deshacer.${RESET}"
    echo -ne "  ${WHITE}  ¿Confirmas? (s/N): ${RESET}"
    read -r -n 1 confirm
    echo ""
    if [ "$confirm" != "s" ] && [ "$confirm" != "S" ]; then
        echo -e "  ${GRAY}  Cancelado.${RESET}"; sleep 1; return
    fi

    echo -e "  ${GRAY}  · Deteniendo procesos...${RESET}"
    pkill -f "antigravity"               2>/dev/null || true
    pkill -f "fluxbox"                   2>/dev/null || true
    pkill -f "thunar"                    2>/dev/null || true
    pkill -f "termux-x11"                2>/dev/null || true
    pkill -f "proot-distro login debian" 2>/dev/null || true

    echo -e "  ${GRAY}  · Eliminando binario y scripts...${RESET}"
    rm -rf "$ANTIGRAVITY_DIR"                                  2>/dev/null || true
    rm -f  "$HOME/antigravity.sh"                              2>/dev/null || true
    rm -f  "${DEBIAN_ROOT}/root/antigravity.sh"                2>/dev/null || true
    rm -f  "${DEBIAN_ROOT}/home/devroom/antigravity.sh"        2>/dev/null || true
    sed -i "/startantigravity.sh/d" \
        "${DEBIAN_ROOT}/home/devroom/.profile"                 2>/dev/null || true
    echo -e "  ${GREEN}  ✓ Binario y scripts eliminados.${RESET}"

    if [ "$unsopt" = "2" ]; then
        echo -e "  ${GRAY}  · Eliminando datos, logs y caché...${RESET}"
        rm -rf "$CONFIG_DIR"                                                   2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.cache/google-antigravity"         2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.config/google-antigravity"        2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/tmp/antigravity"*                               2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Datos, logs y caché eliminados.${RESET}"
    fi

    echo ""
    print_line
    echo -e "  ${GREEN}${BOLD}  ✓  Antigravity desinstalado correctamente.${RESET}"
    print_line
    echo ""
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"
    read -r -n 1
}

# ── Loop principal ───────────────────────────────────────────
while true; do
    show_banner
    print_line
    echo -e "  ${BOLD}${WHITE}  MENÚ PRINCIPAL${RESET}"
    print_line_thin
    echo ""

    if check_installed; then
        echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}▶  Iniciar Antigravity${RESET}"
        echo -e "  ${CYAN}${BOLD}  2  ${RESET}${WHITE}↻  Actualizar Antigravity${RESET}"
        echo -e "  ${CYAN}${BOLD}  3  ${RESET}${WHITE}■  Detener y limpiar sesión${RESET}"
        echo -e "  ${CYAN}${BOLD}  4  ${RESET}${WHITE}⚙  Abrir Debian (terminal)${RESET}"
        echo -e "  ${RED}${BOLD}  5  ${RESET}${WHITE}✕  Desinstalar Antigravity${RESET}"
    else
        echo -e "  ${YELLOW}${BOLD}  ⚠  Antigravity no está instalado.${RESET}"
        echo ""
        echo -e "  ${GRAY}  Ejecuta el instalador:${RESET}"
        echo ""
        echo -e "  ${WHITE}  curl -H 'Cache-Control: no-cache' -o installantigravity.sh \\${RESET}"
        echo -e "  ${WHITE}  https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/installantigravity.sh \\${RESET}"
        echo -e "  ${WHITE}  && chmod +rwx installantigravity.sh \\${RESET}"
        echo -e "  ${WHITE}  && ./installantigravity.sh && rm installantigravity.sh && clear${RESET}"
    fi

    echo ""
    print_line_thin
    echo -e "  ${GRAY}  0  Salir${RESET}"
    print_line
    echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"
    read -r -n 1 opt
    echo ""

    if check_installed; then
        case "$opt" in
            1) action_start     ;;
            2) action_update    ;;
            3) action_stop      ;;
            4) action_terminal  ;;
            5) action_uninstall ;;
            0) clear; echo -e "\n  ${CYAN}${BOLD}  ¡Hasta luego! 👋${RESET}\n"; exit 0 ;;
            *) echo -e "  ${YELLOW}  Opción no válida.${RESET}"; sleep 1 ;;
        esac
    else
        case "$opt" in
            0) clear; echo -e "\n  ${CYAN}${BOLD}  ¡Hasta luego! 👋${RESET}\n"; exit 0 ;;
            *) echo -e "  ${YELLOW}  Ejecuta primero el instalador.${RESET}"; sleep 1 ;;
        esac
    fi
done
