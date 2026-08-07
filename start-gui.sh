#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

CONFIG_FILE="$HOME/.antigravity_config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    if [[ "${LANG:-}" =~ "es" ]]; then LANG_ES=true; else LANG_ES=false; fi
fi

C_INFO='\e[38;2;56;189;248m'
C_SUCCESS='\e[38;2;52;211;153m'
C_WARN='\e[38;2;251;191;36m'
C_ERROR='\e[38;2;239;68;68m'
C_NC='\e[0m'

msg() {
    local es_msg=$1
    local en_msg=$2
    local color=$3
    if [ "$LANG_ES" = true ]; then
        echo -e "${color}${es_msg}${C_NC}"
    else
        echo -e "${color}${en_msg}${C_NC}"
    fi
}

msg "🎵 Iniciando PulseAudio..." "🎵 Starting PulseAudio..." "$C_INFO"
if ! pgrep -x "pulseaudio" > /dev/null; then
    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 2>/dev/null || true
fi

export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"

# Start Termux:X11 if not running
if ! pgrep -x "termux-x11" > /dev/null; then
    msg "🖥️  Iniciando servidor Termux:X11..." "🖥️  Starting Termux:X11 server..." "$C_INFO"
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity 2>/dev/null || true
    termux-x11 :1 &>/dev/null &
    
    msg "⏳ Esperando a que el servidor X11 esté listo..." "⏳ Waiting for X11 server to be ready..." "$C_WARN"
    WAITED=0
    until xdpyinfo -display :1 &>/dev/null 2>&1; do
        sleep 1
        WAITED=$((WAITED + 1))
        if [ "$WAITED" -ge 20 ]; then
            msg "❌ El servidor X11 no respondió en 20s. ¿Está abierta la app Termux:X11?" "❌ X11 server did not respond in 20s. Is Termux:X11 app open?" "$C_ERROR"
            exit 1
        fi
    done
    msg "✅ ¡Servidor X11 listo! Lanzando Antigravity..." "✅ X11 server ready! Launching Antigravity..." "$C_SUCCESS"
else
    # X11 is running, make sure MainActivity is open
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity 2>/dev/null || true
    
    # If Antigravity is not running, start it
    if ! pgrep -f ".local/share/antigravity/antigravity" > /dev/null; then
        msg "🚀 Iniciando Antigravity..." "🚀 Starting Antigravity..." "$C_INFO"
        /data/data/com.termux/files/usr/bin/antigravity "$@" &
    else
        msg "ℹ️  Antigravity ya se está ejecutando." "ℹ️  Antigravity is already running." "$C_INFO"
    fi
fi
