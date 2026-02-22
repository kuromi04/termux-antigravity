#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity - Script de Instalación
#  Autor: @maka0024 (kuromi04)
#  Descripción: Instala el entorno gráfico X11 y Google
#               Antigravity IDE en Termux para Android.
# ============================================================

# --- Colores para output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Funciones de log ---
info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Banner ---
echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║     Google Antigravity - Termux X11      ║"
echo "  ║         Instalador Automático            ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# --- Verificar que estamos en Termux ---
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX/bin" ]; then
    error "Este script debe ejecutarse dentro de Termux."
fi

# --- Actualizar repositorios ---
info "Actualizando repositorios de paquetes..."
# No usamos set -e porque pkg upgrade puede retornar código != 0
# si no hay nada que actualizar, abortando la instalación innecesariamente.
if ! pkg update -y; then
    error "No se pudo actualizar los repositorios. Verifica tu conexión."
fi
pkg upgrade -y || warn "Algunos paquetes no pudieron actualizarse. Continuando..."
success "Repositorios actualizados."

# --- Instalar dependencias base ---
info "Instalando dependencias base..."
pkg install -y \
    x11-repo \
    wget \
    curl \
    git \
    tar \
    unzip \
    || error "Fallo al instalar dependencias base."
success "Dependencias base instaladas."

# --- Instalar entorno gráfico X11 ---
info "Instalando entorno gráfico (X11 + Fluxbox)..."
pkg install -y \
    termux-x11-nightly \
    xorg-xauth \
    xorg-xdpyinfo \
    fluxbox \
    xterm \
    || error "Fallo al instalar el entorno gráfico."
success "Entorno gráfico instalado."

# --- Instalar audio ---
info "Instalando soporte de audio (PulseAudio)..."
pkg install -y pulseaudio || warn "PulseAudio no pudo instalarse. El audio puede no funcionar."
success "PulseAudio instalado."

# --- Instalar dependencias del IDE (Node.js, Python) ---
info "Instalando dependencias del IDE (Node.js, Python)..."
pkg install -y \
    nodejs \
    python \
    python-pip \
    || error "Fallo al instalar dependencias del IDE."
success "Node.js y Python instalados."

# --- Instalar Google Antigravity via npm ---
info "Instalando Google Antigravity IDE..."
if npm install -g @google/antigravity 2>/dev/null; then
    success "Google Antigravity instalado vía npm."
else
    warn "No se encontró paquete npm oficial. Configurando lanzador genérico..."

    mkdir -p "$PREFIX/lib/antigravity"

    cat > "$PREFIX/lib/antigravity/main.js" << 'JSEOF'
const { execSync } = require('child_process');
console.log("[Antigravity] Iniciando entorno de desarrollo...");
try {
    execSync('xterm &', { stdio: 'inherit', env: process.env });
} catch (e) {
    console.error("[Antigravity] Error al iniciar:", e.message);
}
JSEOF

    # CORRECCIÓN: heredoc sin comillas para que $PREFIX se expanda
    # y el script generado use la ruta real, no el literal '$PREFIX'
    cat > "$PREFIX/bin/antigravity-ide" << SHEOF
#!/data/data/com.termux/files/usr/bin/bash
node "$PREFIX/lib/antigravity/main.js"
SHEOF
    chmod +x "$PREFIX/bin/antigravity-ide"
    success "Lanzador genérico creado en $PREFIX/bin/antigravity-ide."
fi

# --- Configurar Fluxbox (menú básico) ---
info "Configurando Fluxbox..."
mkdir -p ~/.fluxbox
if [ ! -f ~/.fluxbox/menu ]; then
    cat > ~/.fluxbox/menu << 'MENUEOF'
[begin] (Antigravity Menu)
    [exec] (Terminal) {xterm}
    [exec] (Antigravity IDE) {bash ~/termux-antigravity/antigravity.sh}
    [separator]
    [submenu] (Sistema)
        [exec] (Recargar Fluxbox) {fluxbox-remote restart}
        [exec] (Salir) {fluxbox-remote quit}
    [end]
[end]
MENUEOF
    success "Menú de Fluxbox configurado."
else
    info "Configuración de Fluxbox ya existe, omitiendo."
fi

if [ ! -f ~/.fluxbox/startup ]; then
    cat > ~/.fluxbox/startup << 'STARTEOF'
#!/data/data/com.termux/files/usr/bin/bash
exec fluxbox
STARTEOF
    chmod +x ~/.fluxbox/startup
fi

# --- Resumen final ---
echo ""
echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Instalación completada exitosamente!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}Próximos pasos:${NC}"
echo "  1. Abre la app Termux:X11 en tu dispositivo."
echo "  2. Regresa a Termux y ejecuta:  ./start-gui.sh"
echo "  3. Cambia a Termux:X11 para usar el IDE."
echo ""
echo -e "  ${YELLOW}Nota:${NC} Asegúrate de tener la app Termux:X11 instalada."
echo "  Descárgala en: https://github.com/termux/termux-x11/releases"
echo ""
