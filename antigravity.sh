#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Language Detection
CONFIG_FILE="$HOME/.antigravity_config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    if [[ "${LANG:-}" =~ "es" ]]; then
        LANG_ES=true
    else
        LANG_ES=false
    fi
    echo "LANG_ES=$LANG_ES" > "$CONFIG_FILE"
fi

C_ACCENT='\e[38;2;168;85;247m'
C_INFO='\e[38;2;56;189;248m'
C_SUCCESS='\e[38;2;52;211;153m'
C_WARN='\e[38;2;251;191;36m'
C_ERROR='\e[38;2;239;68;68m'
C_BORDER='\e[38;2;99;102;241m'
C_NC='\e[0m'

toggle_lang() {
    if [ "$LANG_ES" = true ]; then
        LANG_ES=false
    else
        LANG_ES=true
    fi
    echo "LANG_ES=$LANG_ES" > "$CONFIG_FILE"
}

show_menu() {
    clear
    echo -e "${C_ACCENT}"
    echo -e "   █████╗ ███╗   ██╗████████╗██╗"
    echo -e "  ██╔══██╗████╗  ██║╚══██╔══╝██║"
    echo -e "  ███████║██╔██╗ ██║   ██║   ██║"
    echo -e "  ██╔══██║██║╚██╗██║   ██║   ██║"
    echo -e "  ██║  ██║██║ ╚████║   ██║   ██║"
    echo -e "  ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝"
    echo -e "        Termux Antigravity      ${C_NC}"
    echo -e "${C_BORDER}╭───────────────────────────────────────────╮${C_NC}"
    if [ "$LANG_ES" = true ]; then
        echo -e "${C_BORDER}│${C_NC}  ${C_INFO}1) 🚀 Iniciar Antigravity${C_NC}               ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_INFO}2) 🔄 Reinstalar / Actualizar${C_NC}           ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_INFO}3) 🧹 Detener y limpiar sesión${C_NC}          ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_INFO}4) 🗑️  Desinstalar${C_NC}                       ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_WARN}5) 🌐 Cambiar Idioma (To English)${C_NC}        ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_ERROR}0) ❌ Salir${C_NC}                             ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}╰───────────────────────────────────────────╯${C_NC}"
        echo -n -e "${C_SUCCESS}➜  Selecciona una opción [0-5]: ${C_NC}"
    else
        echo -e "${C_BORDER}│${C_NC}  ${C_INFO}1) 🚀 Start Antigravity${C_NC}                 ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_INFO}2) 🔄 Re-run Installer / Update${C_NC}         ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_INFO}3) 🧹 Stop and clean session${C_NC}            ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_INFO}4) 🗑️  Uninstall${C_NC}                         ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_WARN}5) 🌐 Toggle Language (A Español)${C_NC}       ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}│${C_NC}  ${C_ERROR}0) ❌ Exit${C_NC}                              ${C_BORDER}│${C_NC}"
        echo -e "${C_BORDER}╰───────────────────────────────────────────╯${C_NC}"
        echo -n -e "${C_SUCCESS}➜  Please select an option [0-5]: ${C_NC}"
    fi
}

start_ag() {
    if [ "$LANG_ES" = true ]; then
        echo -e "${C_SUCCESS}🚀 Iniciando Antigravity...${C_NC}"
        bash "$HOME/Projects/termux-antigravity/start-gui.sh" > "$HOME/.antigravity_gui.log" 2>&1 &
        echo -e "${C_SUCCESS}✅ Iniciado en segundo plano. Logs en ~/.antigravity_gui.log${C_NC}"
    else
        echo -e "${C_SUCCESS}🚀 Starting Antigravity...${C_NC}"
        bash "$HOME/Projects/termux-antigravity/start-gui.sh" > "$HOME/.antigravity_gui.log" 2>&1 &
        echo -e "${C_SUCCESS}✅ Started in background. Logs are saved to ~/.antigravity_gui.log${C_NC}"
    fi
    sleep 2
}

install_ag() {
    if [ "$LANG_ES" = true ]; then
        echo -e "${C_WARN}🔄 Ejecutando Instalador...${C_NC}"
    else
        echo -e "${C_WARN}🔄 Running Installer...${C_NC}"
    fi
    bash "$HOME/Projects/termux-antigravity/install.sh"
}

stop_ag() {
    if [ "$LANG_ES" = true ]; then
        echo -e "${C_WARN}🧹 Deteniendo Antigravity y servicios...${C_NC}"
    else
        echo -e "${C_WARN}🧹 Stopping Antigravity and services...${C_NC}"
    fi
    pkill -f "antigravity" || true
    pkill -x "termux-x11" || true
    pkill -x "pulseaudio" || true
    if [ "$LANG_ES" = true ]; then
        echo -e "${C_SUCCESS}✨ Sesión limpia.${C_NC}"
    else
        echo -e "${C_SUCCESS}✨ Session cleaned.${C_NC}"
    fi
}

uninstall_ag() {
    if [ "$LANG_ES" = true ]; then
        echo -n -e "${C_ERROR}⚠️  ¿Estás seguro de que deseas desinstalar Antigravity? (y/n) ${C_NC}"
    else
        echo -n -e "${C_ERROR}⚠️  Are you sure you want to uninstall Antigravity? (y/n) ${C_NC}"
    fi
    read ans
    if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
        if [ "$LANG_ES" = true ]; then
            echo -e "${C_WARN}🗑️  Eliminando archivos...${C_NC}"
        else
            echo -e "${C_WARN}🗑️  Removing files...${C_NC}"
        fi
        rm -rf "$HOME/.local/share/antigravity"
        rm -f "/data/data/com.termux/files/usr/bin/antigravity"
        if [ "$LANG_ES" = true ]; then
            echo -e "${C_SUCCESS}✅ Desinstalación completa.${C_NC}"
        else
            echo -e "${C_SUCCESS}✅ Uninstallation complete.${C_NC}"
        fi
    else
        if [ "$LANG_ES" = true ]; then
            echo -e "${C_SUCCESS}❌ Desinstalación cancelada.${C_NC}"
        else
            echo -e "${C_SUCCESS}❌ Uninstallation cancelled.${C_NC}"
        fi
    fi
}

while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            start_ag
            if [ "$LANG_ES" = true ]; then read -p "Presiona Enter para continuar..."; else read -p "Press Enter to continue..."; fi
            ;;
        2)
            install_ag
            if [ "$LANG_ES" = true ]; then read -p "Presiona Enter para continuar..."; else read -p "Press Enter to continue..."; fi
            ;;
        3)
            stop_ag
            if [ "$LANG_ES" = true ]; then read -p "Presiona Enter para continuar..."; else read -p "Press Enter to continue..."; fi
            ;;
        4)
            uninstall_ag
            if [ "$LANG_ES" = true ]; then read -p "Presiona Enter para continuar..."; else read -p "Press Enter to continue..."; fi
            ;;
        5)
            toggle_lang
            ;;
        0)
            if [ "$LANG_ES" = true ]; then echo -e "${C_SUCCESS}👋 Saliendo...${C_NC}"; else echo -e "${C_SUCCESS}👋 Exiting...${C_NC}"; fi
            exit 0
            ;;
        *)
            if [ "$LANG_ES" = true ]; then echo -e "${C_ERROR}❌ ¡Opción inválida!${C_NC}"; else echo -e "${C_ERROR}❌ Invalid option!${C_NC}"; fi
            sleep 1
            ;;
    esac
done
