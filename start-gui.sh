#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity - Script de Inicio de Entorno Gráfico
#  Autor: @maka0024 (kuromi04)
# ============================================================

# --- Colores ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Verificar dependencias necesarias ---
for cmd in termux-x11 fluxbox pulseaudio xdpyinfo; do
    if ! command -v "$cmd" &>/dev/null; then
        error "Dependencia no encontrada: '$cmd'. Ejecuta primero: ./install.sh"
    fi
done

# --- Limpieza de procesos anteriores ---
info "Limpiando procesos anteriores..."
pkill termux-x11 2>/dev/null || true
pkill fluxbox    2>/dev/null || true
pkill pulseaudio 2>/dev/null || true
sleep 1
success "Procesos anteriores terminados."

# --- Iniciar servidor de audio ---
info "Iniciando PulseAudio..."
pulseaudio --start --exit-idle-time=-1 --daemonize=true 2>/dev/null \
    || warn "PulseAudio no pudo iniciarse. Continuando sin audio."

# --- Variables de entorno X11 ---
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"

# --- Iniciar servidor X11 ---
info "Iniciando servidor Termux:X11 en display :1 ..."
# CORRECCIÓN: X11_PID eliminado, era una variable declarada y nunca usada
termux-x11 :1 &>/dev/null &

# Esperar hasta que X11 esté listo (máx 15 segundos)
MAX_WAIT=15
WAITED=0
info "Esperando que X11 esté disponible..."
until xdpyinfo -display :1 &>/dev/null 2>&1; do
    sleep 1
    WAITED=$((WAITED + 1))
    if [ "$WAITED" -ge "$MAX_WAIT" ]; then
        error "X11 no respondió tras ${MAX_WAIT}s. Revisa que Termux:X11 esté abierto."
    fi
done
success "Servidor X11 listo (tardó ${WAITED}s)."

# --- Lanzar gestor de ventanas ---
info "Iniciando Fluxbox..."
DISPLAY=:1 fluxbox &>/dev/null &
sleep 1
success "Fluxbox en marcha."

# --- Lanzar Google Antigravity IDE ---
info "Abriendo Google Antigravity IDE..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${SCRIPT_DIR}/antigravity.sh" ]; then
    DISPLAY=:1 bash "${SCRIPT_DIR}/antigravity.sh"
else
    warn "antigravity.sh no encontrado. Abriendo terminal xterm como fallback."
    DISPLAY=:1 xterm &
fi

echo ""
echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Entorno gráfico iniciado correctamente.${NC}"
echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}➡ Cambia a la app Termux:X11 para ver el escritorio.${NC}"
echo ""
echo -e "  Para detener el entorno ejecuta: ${YELLOW}./stop-gui.sh${NC}"
echo ""
