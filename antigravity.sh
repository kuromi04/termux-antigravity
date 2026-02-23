#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Lanzador del IDE
#  Autor: @maka0024 (kuromi04)
#  Ejecutar desde Termux: ./antigravity.sh
#
#  Usa termux-docker-qemu para ejecutar dentro de Alpine
#  sin SSH ni contraseña.
# ============================================================

G='\033[0;32m'; C='\033[0;36m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${C}[INFO]${NC}  $1"; }
error() { echo -e "${R}[ERROR]${NC} $1"; exit 1; }

# Verificar dependencias
command -v termux-docker-qemu &>/dev/null \
    || error "'termux-docker-qemu' no encontrado."

# Verificar que Antigravity está instalado en Alpine
termux-docker-qemu alpine sh -c \
    "test -f /opt/antigravity/bin/antigravity" 2>/dev/null \
    || error "Antigravity no encontrado en Alpine. Ejecuta primero: ./install.sh"

info "Lanzando Fluxbox y Antigravity en Alpine..."

# Permite conexiones X11 locales desde el contenedor
xhost +local: 2>/dev/null || true

# Ejecutar dentro de Alpine:
#   - DISPLAY=:1 apunta al servidor X11 de Termux:X11
#   - LD_LIBRARY_PATH incluye glibc-compat para que el binario lo encuentre
#   - fluxbox en background, luego Antigravity en primer plano
termux-docker-qemu alpine sh -c "
    export DISPLAY=:1
    export PULSE_SERVER=127.0.0.1
    export LD_LIBRARY_PATH=/usr/glibc-compat/lib:\$LD_LIBRARY_PATH
    export HOME=/root
    fluxbox &>/dev/null &
    sleep 1
    exec /opt/antigravity/bin/antigravity --no-sandbox
"

echo -e "${G}[OK]${NC} Antigravity cerrado. Cambia a Termux:X11 si aún está corriendo."
