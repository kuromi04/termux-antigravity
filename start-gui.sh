#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity - Inicio del Entorno Gráfico
#  Autor: @maka0024 (kuromi04)
#
#  Se ejecuta desde TERMUX (fuera de Alpine).
#  Inicia Termux:X11, luego entra al contenedor Alpine
#  y lanza Antigravity con el DISPLAY correcto.
# ============================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Verificar dependencias en Termux ---
for cmd in termux-x11 pulseaudio; do
    if ! command -v "$cmd" &>/dev/null; then
        error "Falta '$cmd' en Termux. Ejecuta: pkg install termux-x11-nightly pulseaudio"
    fi
done

# Verificar que Docker o el acceso al contenedor Alpine está disponible
if ! command -v docker &>/dev/null && [ ! -d /var/run/alpine ]; then
    warn "No se detectó 'docker'. Asegúrate de tener acceso al contenedor Alpine."
fi

# --- Limpiar sesiones anteriores ---
info "Limpiando sesiones anteriores..."
pkill termux-x11 2>/dev/null || true
pkill pulseaudio  2>/dev/null || true
pkill fluxbox     2>/dev/null || true
sleep 1
success "Sesiones anteriores cerradas."

# --- Iniciar PulseAudio ---
info "Iniciando PulseAudio..."
pulseaudio --start --exit-idle-time=-1 --daemonize=true 2>/dev/null \
    || warn "PulseAudio no pudo iniciarse. Continuando sin audio."

# --- Variables de entorno X11 ---
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"

# --- Iniciar servidor Termux:X11 ---
info "Iniciando servidor Termux:X11 en display :1..."
termux-x11 :1 &>/dev/null &

# Esperar que X11 esté disponible (máx 20 segundos)
MAX_WAIT=20
WAITED=0
info "Esperando que X11 esté disponible..."
until xdpyinfo -display :1 &>/dev/null 2>&1; do
    sleep 1
    WAITED=$((WAITED + 1))
    if [ "$WAITED" -ge "$MAX_WAIT" ]; then
        error "X11 no respondió tras ${MAX_WAIT}s. ¿Está abierta la app Termux:X11?"
    fi
done
success "Servidor X11 listo (tardó ${WAITED}s)."

# --- Lanzar Antigravity dentro del contenedor Alpine ---
info "Iniciando entorno Alpine y lanzando Antigravity..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${SCRIPT_DIR}/antigravity.sh" ]; then
    bash "${SCRIPT_DIR}/antigravity.sh"
else
    error "antigravity.sh no encontrado en ${SCRIPT_DIR}."
fi
