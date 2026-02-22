#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Inicio del Entorno Gráfico
#  Autor: @maka0024 (kuromi04)
#
#  EJECUTAR DESDE TERMUX (fuera de Alpine).
#  Inicia Termux:X11 y PulseAudio, reenvía el display
#  a Alpine vía QEMU y lanza Antigravity.
# ============================================================

G='\033[0;32m'; C='\033[0;36m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${C}[INFO]${NC}  $1"; }
success() { echo -e "${G}[OK]${NC}    $1"; }
warn()    { echo -e "${Y}[WARN]${NC}  $1"; }
error()   { echo -e "${R}[ERROR]${NC} $1"; exit 1; }

# --- Verificar dependencias en Termux ---
for cmd in termux-x11 pulseaudio; do
    command -v "$cmd" &>/dev/null \
        || error "Falta '$cmd'. Ejecuta: pkg install termux-x11-nightly pulseaudio xdpyinfo -y"
done

# --- Limpiar sesiones previas ---
info "Limpiando sesiones anteriores..."
pkill termux-x11 2>/dev/null || true
pkill pulseaudio  2>/dev/null || true
sleep 1

# --- Iniciar PulseAudio ---
info "Iniciando PulseAudio..."
pulseaudio --start --exit-idle-time=-1 --daemonize=true 2>/dev/null \
    || warn "PulseAudio no pudo iniciarse. Continuando sin audio."

# --- Variables de entorno X11 ---
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"

# --- Abrir Termux:X11 y arrancar el servidor ---
info "Iniciando Termux:X11..."
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity 2>/dev/null || true
termux-x11 :1 &>/dev/null &

# Esperar que X11 esté disponible (máx 20s)
WAITED=0
info "Esperando que X11 esté disponible..."
until xdpyinfo -display :1 &>/dev/null 2>&1; do
    sleep 1
    WAITED=$((WAITED + 1))
    [ "$WAITED" -ge 20 ] && error "X11 no respondió en 20s. ¿Está abierta la app Termux:X11?"
done
success "Servidor X11 listo (${WAITED}s)."

# --- Lanzar Antigravity dentro de Alpine vía QEMU ──────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "Lanzando entorno Alpine y Antigravity..."
bash "${SCRIPT_DIR}/antigravity.sh"
