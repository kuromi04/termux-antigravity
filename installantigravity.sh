#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Google Antigravity para Termux — Instalador
#  Autor: @maka0024 (kuromi04)
#  GitHub: https://github.com/kuromi04/termux-antigravity
#
#  Uso (un solo comando):
#    curl -H 'Cache-Control: no-cache' -o installantigravity.sh \
#      https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/installantigravity.sh \
#    && chmod +rwx installantigravity.sh \
#    && ./installantigravity.sh \
#    && rm installantigravity.sh \
#    && clear
# ============================================================

# ── PASO 0: Permisos de almacenamiento ──────────────────────
clear
echo -e "\e[1;37m[i] Verificando permisos de almacenamiento...\e[0m"

# Comprobación real con ls, no con variable vacía
if ! ls /sdcard/ &>/dev/null 2>&1; then
    echo -e "\e[1;37m[!] Debes conceder acceso al almacenamiento.\e[0m"
    termux-setup-storage
    # Esperar a que el usuario conceda el permiso
    echo -e "\e[1;37m[i] Continuando en 5 segundos...\e[0m"
    sleep 5
    # Segunda verificación
    if ! ls /sdcard/ &>/dev/null 2>&1; then
        echo -e "\e[1;33m[!] Sin acceso al almacenamiento. Continuando de todas formas.\e[0m"
    fi
fi

# ── PASO 1: Aviso ────────────────────────────────────────────
clear
echo -e "\e[1;37m[!] ¡Aviso importante, no lo ignores!\e[0m"
echo -e "\e[1;37m-\e[0m"
echo -e "\e[1;37mAsegúrate de tener al menos 4 GB de espacio libre.\e[0m"
echo -e "\e[1;37mNo ejecutes otros comandos durante la instalación.\e[0m"
echo -e "\e[1;37mSi quieres cancelar presiona Ctrl + C ahora.\e[0m"
echo -e "\e[1;37m\e[0m"
echo -e "\e[1;37mContinúa en 60 segundos o presiona cualquier tecla para empezar ya.\e[0m"
if read -r -t 60 -n 1 _; then
    echo "Continuando..."
else
    echo "60 segundos transcurridos, continuando..."
fi

# ── PASO 2: Paquetes base en Termux ─────────────────────────
clear
echo -e '\e[1;37m[i] Instalando paquetes en Termux...\e[0m'
apt update -y
yes y | apt upgrade -y
apt install x11-repo -y
apt install proot-distro aria2 termux-x11-nightly -y

# ── PASO 3: Instalar Debian ──────────────────────────────────
clear
echo -e '\e[1;37m[i] Instalando Debian...\e[0m'
proot-distro install debian

# ── PASO 4: Descargar binario de Antigravity ─────────────────
clear
echo -e '\e[1;37m[i] Descargando Google Antigravity (~300 MB)...\e[0m'

DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
mkdir -p "$DEBIAN_ROOT/Apps/IDE"
cd "$DEBIAN_ROOT/Apps/IDE" || exit 1

aria2c -x 4 -o Antigravity.tar.gz \
    "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz"

# ── PASO 5: Extraer e instalar ───────────────────────────────
clear
echo -e '\e[1;37m[i] Instalando Google Antigravity...\e[0m'
tar -xvzf Antigravity.tar.gz
rm -f Antigravity.tar.gz
cd Antigravity || exit 1
chmod +x bin/antigravity

# Script interno: lanza X11 + fluxbox + thunar + Antigravity
# Se ejecuta desde dentro de Debian al elegir "Iniciar"
cat > antigravity.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity && \
termux-x11 -xstartup "bash -c 'fluxbox & thunar & /Apps/IDE/Antigravity/bin/antigravity --no-sandbox && sleep infinity'"
EOF
chmod +x antigravity.sh

# Menú interactivo dentro de Debian (devroom)
cat > startantigravity.sh << 'EOF'
#!/bin/bash
sed -i "/startantigravity.sh/d" "$HOME/.profile" 2>/dev/null
clear
echo -e "\e[1;37m--------------------\e[0m"
echo -e "\e[1;37m¿Qué quieres hacer con Google Antigravity?\e[0m"
echo -e "\e[1;37m--------------------\e[0m"
echo -e "\e[1;37m1. Iniciar Antigravity\e[0m"
echo -e "\e[1;37m2. Desinstalar\e[0m"
echo -e "\e[1;37mOtro. Salir y usar Debian\e[0m"
echo -e "\e[1;37m--------------------\e[0m"
read -r -n 1 option
case "$option" in
    '1')
        clear
        echo -e "\e[1;37m[i] Iniciando Google Antigravity...\e[0m"
        /Apps/IDE/Antigravity/antigravity.sh
        /Apps/IDE/Antigravity/startantigravity.sh
        ;;
    '2')
        /Apps/IDE/Antigravity/uninstall.sh
        ;;
    *)
        clear
        ;;
esac
clear
EOF
chmod +x startantigravity.sh

# Desinstalador interno de Debian
cat > uninstall.sh << 'EOF'
#!/bin/bash
echo -e "\e[1;37m--------------------\e[0m"
echo -e "\e[1;37m¿Desinstalar Google Antigravity?\e[0m"
echo -e "\e[1;37m--------------------\e[0m"
echo -e "\e[1;37m1. Desinstalar y CONSERVAR datos del usuario.\e[0m"
echo -e "\e[1;37m2. Desinstalar y ELIMINAR todos los datos.\e[0m"
echo -e "\e[1;37mOtro. Cancelar\e[0m"
echo -e "\e[1;37m--------------------\e[0m"
read -r -n 1 option
case "$option" in
    '1')
        clear
        echo -e "\e[1;37m[i] Desinstalando Antigravity...\e[0m"
        sed -i "/startantigravity.sh/d" "$HOME/.profile" 2>/dev/null
        rm -f "$HOME/antigravity.sh"
        sudo rm -f /root/antigravity.sh /data/data/com.termux/files/home/antigravity.sh
        sudo rm -rf /Apps/IDE/Antigravity
        clear
        echo -e "\e[1;37m[i] Antigravity desinstalado (datos conservados).\e[0m"
        ;;
    '2')
        clear
        echo -e "\e[1;37m[i] Desinstalando Antigravity...\e[0m"
        sed -i "/startantigravity.sh/d" "$HOME/.profile" 2>/dev/null
        rm -rf "$HOME/antigravity.sh" "$HOME/.antigravity"
        sudo rm -f /root/antigravity.sh /root/.antigravity \
                   /data/data/com.termux/files/home/antigravity.sh
        sudo rm -rf /Apps/IDE/Antigravity
        clear
        echo -e "\e[1;37m[i] Antigravity desinstalado (datos eliminados).\e[0m"
        ;;
    *)
        clear
        echo -e "\e[1;37mCancelando...\e[0m"
        ;;
esac
clear
EOF
chmod +x uninstall.sh

# ── PASO 6: Estructura interna de Debian ─────────────────────
clear
echo -e '\e[1;37m[i] Configurando entorno de Debian...\e[0m'

mkdir -p "$DEBIAN_ROOT/home/devroom"

# Script que se auto-ejecuta en el PRIMER login de Debian.
# Instala paquetes y crea el usuario devroom.
cat > "$DEBIAN_ROOT/etc/profile.d/installantigravity.sh" << 'INSTALL2'
#!/bin/bash
# Desactivarse para no volver a ejecutarse
chmod -x /etc/profile.d/installantigravity.sh
clear
echo -e '\e[1;37m[i] Instalando paquetes dentro de Debian...\e[0m'
apt update -y
apt upgrade -y
apt install -y sudo xterm thunar fluxbox aria2 firefox-esr \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 \
    libcairo2 libcurl3-gnutls libcurl4 libdbus-1-3 libexpat1 \
    libgbm1 libglib2.0-0 libgtk-3-0 libgtk-4-1 libnspr4 libnss3 \
    libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 \
    libxext6 libxfixes3 libxkbcommon0 libxkbfile1 libxrandr2 xdg-utils
useradd -m devroom 2>/dev/null || true
passwd -d devroom
usermod -s /bin/bash devroom
echo 'devroom ALL=(ALL) ALL' | tee /etc/sudoers.d/devroom
chmod 440 /etc/sudoers.d/devroom
rm -f /etc/profile.d/installantigravity.sh
clear
echo -e '\e[1;37m[i] ¡Debian configurado! Escribe "exit" para continuar.\e[0m'
INSTALL2
chmod +x "$DEBIAN_ROOT/etc/profile.d/installantigravity.sh"

# Script para root en Debian: cambia a devroom con autorun
cat > "$DEBIAN_ROOT/root/antigravity.sh" << 'EOF'
#!/bin/bash
sed -i "/startantigravity.sh/d" /home/devroom/.profile 2>/dev/null
echo "/Apps/IDE/Antigravity/startantigravity.sh" >> /home/devroom/.profile
clear
su - devroom
clear
EOF
chmod +x "$DEBIAN_ROOT/root/antigravity.sh"

# Script para devroom en Debian
cat > "$DEBIAN_ROOT/home/devroom/antigravity.sh" << 'EOF'
#!/bin/bash
/Apps/IDE/Antigravity/startantigravity.sh
EOF
chmod +x "$DEBIAN_ROOT/home/devroom/antigravity.sh"

# ── PASO 7: Instalar menú principal en HOME de Termux ────────
# Este es el archivo antigravity.sh del repositorio.
# Se copia aquí para que esté disponible inmediatamente.
clear
echo -e '\e[1;37m[i] Instalando menú principal...\e[0m'

# Descargar el menú directamente desde el repositorio
aria2c -o "$HOME/antigravity.sh" \
    "https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/antigravity.sh" \
    2>/dev/null

# Si falla la descarga, crearlo embebido como respaldo
if [ ! -f "$HOME/antigravity.sh" ] || [ ! -s "$HOME/antigravity.sh" ]; then
    echo -e '\e[1;33m[!] Descarga del menú falló, usando versión embebida.\e[0m'
    cat > "$HOME/antigravity.sh" << 'MENUEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Menú básico de respaldo — actualiza con: ./antigravity.sh opción 2
DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
ANTIGRAVITY_BIN="$DEBIAN_ROOT/Apps/IDE/Antigravity/bin/antigravity"
ANTIGRAVITY_DIR="$DEBIAN_ROOT/Apps/IDE/Antigravity"
CONFIG_DIR="$DEBIAN_ROOT/home/devroom/.antigravity"
ANTIGRAVITY_DL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz"
RESET='\e[0m'; BOLD='\e[1m'; GRAY='\e[90m'; WHITE='\e[97m'
RED='\e[91m'; GREEN='\e[92m'; YELLOW='\e[93m'; MAGENTA='\e[95m'; CYAN='\e[96m'
print_line()      { echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
print_line_thin() { echo -e "${GRAY}  ─────────────────────────────────────────────────${RESET}"; }
check_installed() { [ -f "$ANTIGRAVITY_BIN" ]; }
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
action_start() {
    show_banner; print_line
    echo -e "  ${GREEN}${BOLD}  ▶  Iniciando Google Antigravity...${RESET}"; print_line; echo ""
    sed -i "/startantigravity.sh/d" "${DEBIAN_ROOT}/home/devroom/.profile" 2>/dev/null || true
    echo '/Apps/IDE/Antigravity/startantigravity.sh' >> "${DEBIAN_ROOT}/home/devroom/.profile"
    echo -e "  ${GRAY}  · Entrando a Debian como devroom...${RESET}"; sleep 1
    proot-distro login debian --user devroom; clear
}
action_update() {
    show_banner; print_line
    echo -e "  ${YELLOW}${BOLD}  ↻  Actualizando Antigravity...${RESET}"; print_line; echo ""
    cp -r "$CONFIG_DIR" /tmp/ag_config_bak 2>/dev/null || true
    cp "$ANTIGRAVITY_DIR/antigravity.sh"      /tmp/ag_s.sh   2>/dev/null || true
    cp "$ANTIGRAVITY_DIR/startantigravity.sh" /tmp/ag_st.sh  2>/dev/null || true
    cp "$ANTIGRAVITY_DIR/uninstall.sh"        /tmp/ag_un.sh  2>/dev/null || true
    echo -e "  ${GRAY}  · Descargando (~300 MB)...${RESET}"
    cd "$DEBIAN_ROOT/Apps/IDE" || exit 1
    if aria2c -x 4 -o Antigravity_new.tar.gz "$ANTIGRAVITY_DL"; then
        rm -rf Antigravity; mkdir -p Antigravity
        tar -xzf Antigravity_new.tar.gz -C Antigravity --strip-components=1
        rm -f Antigravity_new.tar.gz; chmod +x Antigravity/bin/antigravity
        cp /tmp/ag_s.sh  "$ANTIGRAVITY_DIR/antigravity.sh"      2>/dev/null || true
        cp /tmp/ag_st.sh "$ANTIGRAVITY_DIR/startantigravity.sh" 2>/dev/null || true
        cp /tmp/ag_un.sh "$ANTIGRAVITY_DIR/uninstall.sh"        2>/dev/null || true
        cp -r /tmp/ag_config_bak "$CONFIG_DIR" 2>/dev/null || true
        rm -f /tmp/ag_*.sh; rm -rf /tmp/ag_config_bak
        echo ""; print_line
        echo -e "  ${GREEN}${BOLD}  ✓  Actualizado correctamente.${RESET}"
    else
        echo -e "  ${RED}${BOLD}  ✗  Error al descargar.${RESET}"
        rm -f "$DEBIAN_ROOT/Apps/IDE/Antigravity_new.tar.gz"
    fi
    print_line; echo ""
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"; read -r -n 1
}
action_stop() {
    show_banner; print_line
    echo -e "  ${YELLOW}${BOLD}  ■  Detener y limpiar sesión${RESET}"; print_line; echo ""
    echo -e "  ${WHITE}  ¿Qué deseas limpiar?${RESET}"; echo ""
    echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}Solo detener procesos${RESET}"
    echo -e "  ${CYAN}${BOLD}  2  ${RESET}${WHITE}Detener + limpiar logs${RESET}"
    echo -e "  ${CYAN}${BOLD}  3  ${RESET}${WHITE}Detener + limpiar logs + caché${RESET}"
    echo -e "  ${GRAY}  0  Cancelar${RESET}"; echo ""; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"; read -r -n 1 stop_opt; echo ""
    case "$stop_opt" in
        1|2|3)
            echo -e "  ${GRAY}  · Deteniendo procesos...${RESET}"
            pkill -f "antigravity" 2>/dev/null || true
            pkill -f "fluxbox"     2>/dev/null || true
            pkill -f "thunar"      2>/dev/null || true
            pkill -f "termux-x11"  2>/dev/null || true
            pkill -f "pulseaudio"  2>/dev/null || true
            pkill -f "proot-distro login debian" 2>/dev/null || true
            echo -e "  ${GREEN}  ✓ Procesos detenidos.${RESET}" ;;
    esac
    if [ "$stop_opt" = "2" ] || [ "$stop_opt" = "3" ]; then
        echo -e "  ${GRAY}  · Limpiando logs...${RESET}"
        rm -f "${DEBIAN_ROOT}/home/devroom/.antigravity/logs/"*.log 2>/dev/null || true
        rm -f "${DEBIAN_ROOT}/tmp/"*.log 2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Logs eliminados.${RESET}"
    fi
    if [ "$stop_opt" = "3" ]; then
        echo -e "  ${GRAY}  · Limpiando caché...${RESET}"
        rm -rf "${DEBIAN_ROOT}/home/devroom/.cache/google-antigravity" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.config/google-antigravity/Cache" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/tmp/antigravity"* 2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Caché eliminada.${RESET}"
    fi
    [ "$stop_opt" = "0" ] && return
    echo ""; print_line
    echo -e "  ${GREEN}${BOLD}  ✓  Sesión detenida y limpiada.${RESET}"; print_line; echo ""
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"; read -r -n 1
}
action_terminal() {
    show_banner; print_line
    echo -e "  ${CYAN}${BOLD}  ⚙  Abriendo terminal de Debian...${RESET}"; print_line; echo ""
    echo -e "  ${GRAY}  Escribe 'exit' para volver al menú.${RESET}"; echo ""; sleep 1
    proot-distro login debian; clear
}
action_uninstall() {
    show_banner; print_line
    echo -e "  ${RED}${BOLD}  ✕  Desinstalar Google Antigravity${RESET}"; print_line; echo ""
    echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}Desinstalar y CONSERVAR datos${RESET}"
    echo -e "  ${RED}${BOLD}  2  ${RESET}${WHITE}Desinstalar y ELIMINAR todo${RESET}"
    echo -e "  ${GRAY}  0  Cancelar${RESET}"; echo ""; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"; read -r -n 1 unsopt; echo ""
    [ "$unsopt" = "0" ] && return
    if [ "$unsopt" != "1" ] && [ "$unsopt" != "2" ]; then
        echo -e "  ${YELLOW}  Opción no válida.${RESET}"; sleep 1; return
    fi
    echo -e "  ${RED}${BOLD}  ⚠  Esta acción no se puede deshacer.${RESET}"
    echo -ne "  ${WHITE}  ¿Confirmas? (s/N): ${RESET}"; read -r -n 1 confirm; echo ""
    if [ "$confirm" != "s" ] && [ "$confirm" != "S" ]; then
        echo -e "  ${GRAY}  Cancelado.${RESET}"; sleep 1; return
    fi
    echo -e "  ${GRAY}  · Deteniendo procesos...${RESET}"
    pkill -f "antigravity" 2>/dev/null || true
    pkill -f "fluxbox"     2>/dev/null || true
    pkill -f "thunar"      2>/dev/null || true
    pkill -f "termux-x11"  2>/dev/null || true
    pkill -f "proot-distro login debian" 2>/dev/null || true
    echo -e "  ${GRAY}  · Eliminando binario y scripts...${RESET}"
    rm -rf "$ANTIGRAVITY_DIR" 2>/dev/null || true
    rm -f "$HOME/antigravity.sh" 2>/dev/null || true
    rm -f "${DEBIAN_ROOT}/root/antigravity.sh" 2>/dev/null || true
    rm -f "${DEBIAN_ROOT}/home/devroom/antigravity.sh" 2>/dev/null || true
    sed -i "/startantigravity.sh/d" "${DEBIAN_ROOT}/home/devroom/.profile" 2>/dev/null || true
    echo -e "  ${GREEN}  ✓ Eliminado.${RESET}"
    if [ "$unsopt" = "2" ]; then
        echo -e "  ${GRAY}  · Eliminando datos, logs y caché...${RESET}"
        rm -rf "$CONFIG_DIR" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.cache/google-antigravity" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.config/google-antigravity" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/tmp/antigravity"* 2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Datos eliminados.${RESET}"
    fi
    echo ""; print_line
    echo -e "  ${GREEN}${BOLD}  ✓  Antigravity desinstalado.${RESET}"; print_line; echo ""
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"; read -r -n 1
}
while true; do
    show_banner; print_line
    echo -e "  ${BOLD}${WHITE}  MENÚ PRINCIPAL${RESET}"; print_line_thin; echo ""
    if check_installed; then
        echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}▶  Iniciar Antigravity${RESET}"
        echo -e "  ${CYAN}${BOLD}  2  ${RESET}${WHITE}↻  Actualizar Antigravity${RESET}"
        echo -e "  ${CYAN}${BOLD}  3  ${RESET}${WHITE}■  Detener y limpiar sesión${RESET}"
        echo -e "  ${CYAN}${BOLD}  4  ${RESET}${WHITE}⚙  Abrir Debian (terminal)${RESET}"
        echo -e "  ${RED}${BOLD}  5  ${RESET}${WHITE}✕  Desinstalar Antigravity${RESET}"
    else
        echo -e "  ${YELLOW}${BOLD}  ⚠  Antigravity no está instalado.${RESET}"; echo ""
        echo -e "  ${GRAY}  Vuelve a ejecutar el instalador.${RESET}"
    fi
    echo ""; print_line_thin
    echo -e "  ${GRAY}  0  Salir${RESET}"; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"; read -r -n 1 opt; echo ""
    if check_installed; then
        case "$opt" in
            1) action_start ;;     2) action_update ;;
            3) action_stop ;;      4) action_terminal ;;
            5) action_uninstall ;; 0) clear; echo -e "\n  ${CYAN}${BOLD}  ¡Hasta luego! 👋${RESET}\n"; exit 0 ;;
            *) echo -e "  ${YELLOW}  Opción no válida.${RESET}"; sleep 1 ;;
        esac
    else
        case "$opt" in
            0) clear; echo -e "\n  ${CYAN}${BOLD}  ¡Hasta luego! 👋${RESET}\n"; exit 0 ;;
            *) echo -e "  ${YELLOW}  Ejecuta primero el instalador.${RESET}"; sleep 1 ;;
        esac
    fi
done
MENUEOF
fi

# Dar permisos de ejecución al menú
chmod +x "$HOME/antigravity.sh"

# ── PASO 8: Primer login en Debian → ejecuta install2 ────────
clear
echo -e '\e[1;37m[i] Configurando Debian (primera vez)...\e[0m'
echo -e '\e[1;37m    Escribe "exit" cuando termine para continuar.\e[0m'
sleep 2
proot-distro login debian

# ── PASO 9: Fin — mostrar resumen y lanzar menú ──────────────
clear
echo -e "\e[1;37m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;32m  ✓  ¡Instalación completada!\e[0m"
echo -e "\e[1;37m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo ""
echo -e "\e[1;37m  Abriendo el menú principal...\e[0m"
echo ""
sleep 2

# Lanzar el menú automáticamente
exec bash "$HOME/antigravity.sh"
