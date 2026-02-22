#!/bin/sh

# ============================================================
#  Termux-Antigravity - Instalador para Alpine Linux
#  Autor: @maka0024 (kuromi04)
#
#  Requisitos:
#    - Alpine Linux corriendo dentro de Termux via Docker/QEMU
#    - Este script se ejecuta DENTRO de Alpine (como root)
#    - Termux:X11 ya instalado en Android
#
#  Flujo:
#    1. Instala dependencias base en Alpine (apk)
#    2. Instala gcompat para compatibilidad con binarios glibc
#    3. Configura el entorno gráfico X11 + Fluxbox
#    4. Añade el repositorio oficial de Google Antigravity (APT)
#    5. Instala Antigravity vía apt-get dentro de Alpine
# ============================================================

# --- Colores (compatibles con sh de Alpine/busybox) ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { printf "${CYAN}[INFO]${NC}  %s\n" "$1"; }
success() { printf "${GREEN}[OK]${NC}    %s\n" "$1"; }
warn()    { printf "${YELLOW}[WARN]${NC}  %s\n" "$1"; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$1"; exit 1; }

# --- Banner ---
printf "${CYAN}"
printf "  ╔══════════════════════════════════════════╗\n"
printf "  ║   Google Antigravity · Alpine · X11      ║\n"
printf "  ║         Instalador Automático            ║\n"
printf "  ╚══════════════════════════════════════════╝\n"
printf "${NC}\n"

# --- Verificar que somos root ---
if [ "$(id -u)" -ne 0 ]; then
    error "Este script debe ejecutarse como root dentro de Alpine."
fi

# --- Verificar que estamos en Alpine ---
if [ ! -f /etc/alpine-release ]; then
    error "Este script está diseñado para Alpine Linux. Ejecuta dentro de tu contenedor Alpine."
fi

ALPINE_VER=$(cat /etc/alpine-release)
info "Alpine Linux detectado: v${ALPINE_VER}"

# ── PASO 1: Actualizar repositorios Alpine ──────────────────
info "Actualizando repositorios de Alpine..."
apk update || error "No se pudieron actualizar los repositorios. Verifica conexión."
apk upgrade || warn "Algunos paquetes no pudieron actualizarse. Continuando..."
success "Repositorios actualizados."

# ── PASO 2: Instalar dependencias base ─────────────────────
info "Instalando dependencias base..."
apk add --no-cache \
    bash \
    curl \
    wget \
    git \
    tar \
    unzip \
    gnupg \
    ca-certificates \
    || error "Fallo al instalar dependencias base."
success "Dependencias base instaladas."

# ── PASO 3: Instalar capa de compatibilidad glibc ──────────
# CRÍTICO: Antigravity requiere glibc >= 2.28 pero Alpine usa musl.
# gcompat provee compatibilidad para ejecutar binarios glibc en musl.
info "Instalando capa de compatibilidad glibc (gcompat + libstdc++)..."
apk add --no-cache \
    gcompat \
    libgcc \
    libstdc++ \
    || error "Fallo al instalar gcompat. Antigravity no podrá ejecutarse."
success "Compatibilidad glibc instalada."

# ── PASO 4: Instalar entorno gráfico X11 + Fluxbox ─────────
info "Instalando entorno gráfico X11 y Fluxbox..."

# Habilitar repositorios community y edge/testing para paquetes X11
if ! grep -q "community" /etc/apk/repositories; then
    ALPINE_MAIN=$(grep "main" /etc/apk/repositories | head -1)
    ALPINE_BASE=$(echo "$ALPINE_MAIN" | sed 's|/main||')
    echo "${ALPINE_BASE}/community" >> /etc/apk/repositories
    apk update
fi

apk add --no-cache \
    xorg-server \
    xauth \
    xdpyinfo \
    xterm \
    fluxbox \
    dbus \
    mesa-gl \
    mesa-dri-gallium \
    || error "Fallo al instalar el entorno gráfico."
success "Entorno gráfico instalado."

# ── PASO 5: Instalar audio (opcional) ──────────────────────
info "Instalando PulseAudio..."
apk add --no-cache pulseaudio pulseaudio-utils \
    || warn "PulseAudio no pudo instalarse. El audio puede no funcionar."
success "PulseAudio instalado."

# ── PASO 6: Instalar apt-get para el repo de Google ─────────
# Google Antigravity usa un repositorio Debian/apt, por lo que
# necesitamos apt dentro de Alpine para instalarlo.
info "Instalando apt para compatibilidad con repositorio Debian de Google..."
apk add --no-cache apt || error "No se pudo instalar apt en Alpine."
success "apt instalado."

# ── PASO 7: Configurar repositorio oficial de Antigravity ──
info "Configurando repositorio oficial de Google Antigravity..."

mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
    gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg \
    || error "No se pudo descargar la clave GPG de Google."

echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] \
https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ \
antigravity-debian main" | tee /etc/apt/sources.list.d/antigravity.list > /dev/null

apt-get update || error "Fallo al actualizar el índice apt de Antigravity."
success "Repositorio de Antigravity configurado."

# ── PASO 8: Instalar Google Antigravity ────────────────────
info "Instalando Google Antigravity IDE..."
apt-get install -y antigravity || error "Fallo al instalar Antigravity."
success "Google Antigravity instalado correctamente."

# ── PASO 9: Configurar Fluxbox ─────────────────────────────
info "Configurando Fluxbox..."
mkdir -p ~/.fluxbox
if [ ! -f ~/.fluxbox/menu ]; then
    cat > ~/.fluxbox/menu << 'MENUEOF'
[begin] (Antigravity Menu)
    [exec] (Terminal) {xterm}
    [exec] (Antigravity IDE) {antigravity --no-sandbox}
    [separator]
    [submenu] (Sistema)
        [exec] (Salir) {fluxbox-remote quit}
    [end]
[end]
MENUEOF
    success "Menú de Fluxbox configurado."
fi

# ── PASO 10: Crear script de lanzamiento rápido ────────────
# start-gui.sh se ejecuta desde Termux (fuera de Alpine)
# antigravity.sh se ejecuta dentro de Alpine con DISPLAY apuntando a X11

info "Creando script de inicio rápido /usr/local/bin/start-antigravity..."
cat > /usr/local/bin/start-antigravity << 'STARTEOF'
#!/bin/sh
export DISPLAY="${DISPLAY:-:1}"
export PULSE_SERVER=127.0.0.1
# --no-sandbox es necesario para entornos sin kernel de seguridad completo
exec antigravity --no-sandbox "$@"
STARTEOF
chmod +x /usr/local/bin/start-antigravity
success "Script de inicio creado."

# ── Resumen ─────────────────────────────────────────────────
printf "\n"
printf "${GREEN}══════════════════════════════════════════════${NC}\n"
printf "${GREEN}  ✅ Instalación completada exitosamente!${NC}\n"
printf "${GREEN}══════════════════════════════════════════════${NC}\n"
printf "\n"
printf "  ${CYAN}Próximos pasos (desde Termux, fuera de Alpine):${NC}\n"
printf "  1. Abre la app Termux:X11 en tu dispositivo.\n"
printf "  2. Ejecuta: ./start-gui.sh\n"
printf "  3. Cambia a Termux:X11 para ver el escritorio.\n"
printf "\n"
printf "  ${YELLOW}Nota:${NC} Antigravity requiere cuenta de Google al primer inicio.\n"
printf "\n"
