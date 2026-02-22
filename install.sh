#!/bin/sh

# ============================================================
#  Termux-Antigravity · Instalador para Alpine Linux (QEMU)
#  Autor: @maka0024 (kuromi04)
#
#  EJECUTAR DENTRO DE ALPINE (como root):
#    sh install.sh
#
#  Qué hace:
#    1. Instala glibc real (sgerrand ARM64) sobre Alpine/musl
#    2. Instala el entorno gráfico X11 + Fluxbox
#    3. Descarga el binario oficial ARM64 de Antigravity
#    4. Genera los scripts de inicio y desinstalación
# ============================================================

# --- Colores (sh de Alpine/busybox compatible) ---
W='\033[1;37m'; G='\033[1;32m'; R='\033[1;31m'; Y='\033[1;33m'; C='\033[1;36m'; NC='\033[0m'
info()    { printf "${C}[i]${NC} %s\n" "$1"; }
success() { printf "${G}[✓]${NC} %s\n" "$1"; }
warn()    { printf "${Y}[!]${NC} %s\n" "$1"; }
error()   { printf "${R}[✗]${NC} %s\n" "$1"; exit 1; }

# Versión de glibc a instalar (ARM64, la más reciente disponible para Alpine)
GLIBC_VER="2.35-r1"
GLIBC_BASE="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}"
GLIBC_KEY="https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub"

# URL del binario oficial de Antigravity para Linux ARM64
ANTIGRAVITY_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz"
INSTALL_DIR="/opt/antigravity"

printf "\n${C}"
printf "  ╔══════════════════════════════════════════════╗\n"
printf "  ║  Google Antigravity · Alpine QEMU · X11     ║\n"
printf "  ║         Instalador Automático               ║\n"
printf "  ╚══════════════════════════════════════════════╝\n"
printf "${NC}\n"

# --- Verificar root ---
[ "$(id -u)" -eq 0 ] || error "Ejecuta como root dentro de Alpine."

# --- Verificar Alpine ---
[ -f /etc/alpine-release ] || error "Este script es para Alpine Linux."
info "Alpine $(cat /etc/alpine-release) detectado."

# ── PASO 1: Actualizar repositorios ────────────────────────
info "Actualizando repositorios Alpine..."
apk update || error "No se pudo conectar a los repositorios."
apk upgrade || warn "Algunos paquetes no se actualizaron. Continuando..."

# Habilitar repositorio community (necesario para X11/Fluxbox)
if ! grep -q "community" /etc/apk/repositories 2>/dev/null; then
    BASE_URL=$(grep "v[0-9]" /etc/apk/repositories | grep "main" | head -1 | sed 's|/main.*||')
    echo "${BASE_URL}/community" >> /etc/apk/repositories
    apk update
    success "Repositorio community habilitado."
fi

# ── PASO 2: Dependencias base ───────────────────────────────
info "Instalando dependencias base..."
apk add --no-cache \
    bash wget curl aria2 git tar xz \
    ca-certificates gnupg \
    || error "Fallo al instalar dependencias base."
success "Dependencias base listas."

# ── PASO 3: Instalar glibc real (sgerrand ARM64) ────────────
# Alpine usa musl por defecto. Antigravity requiere glibc >= 2.28.
# El paquete sgerrand instala glibc en /usr/glibc-compat sin
# reemplazar musl, permitiendo coexistencia de ambas librerías.
info "Instalando glibc ${GLIBC_VER} para Alpine ARM64 (sgerrand)..."

# 1. Clave de firma del repositorio
wget -q -O /etc/apk/keys/sgerrand.rsa.pub "$GLIBC_KEY" \
    || error "No se pudo descargar la clave GPG de sgerrand."

# 2. Descargar los tres paquetes glibc
wget -q "${GLIBC_BASE}/glibc-${GLIBC_VER}.apk"     || error "Fallo al descargar glibc."
wget -q "${GLIBC_BASE}/glibc-bin-${GLIBC_VER}.apk" || error "Fallo al descargar glibc-bin."
wget -q "${GLIBC_BASE}/glibc-i18n-${GLIBC_VER}.apk"|| error "Fallo al descargar glibc-i18n."

# 3. Instalar (--force-overwrite resuelve conflicto con nsswitch.conf de Alpine)
apk add --force-overwrite --no-cache \
    "glibc-${GLIBC_VER}.apk" \
    "glibc-bin-${GLIBC_VER}.apk" \
    "glibc-i18n-${GLIBC_VER}.apk" \
    || error "Fallo al instalar glibc."

# 4. Configurar locale en_US.UTF-8
/usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 2>/dev/null || true

# 5. Enlazar librerías para que el loader de glibc las encuentre
mkdir -p /lib64
ln -sf /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1 2>/dev/null || true
ln -sf /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /lib64/ld-linux-aarch64.so.1 2>/dev/null || true

# 6. Libstdc++ y libgcc para dependencias C++ de Antigravity
apk add --no-cache libstdc++ libgcc || warn "libstdc++ no disponible, puede haber errores."

# Limpieza de .apk temporales
rm -f "glibc-${GLIBC_VER}.apk" "glibc-bin-${GLIBC_VER}.apk" "glibc-i18n-${GLIBC_VER}.apk"
success "glibc ${GLIBC_VER} instalado en /usr/glibc-compat."

# ── PASO 4: Entorno gráfico X11 + Fluxbox ──────────────────
info "Instalando entorno gráfico X11 y Fluxbox..."
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
success "X11 y Fluxbox instalados."

# ── PASO 5: Audio ───────────────────────────────────────────
info "Instalando PulseAudio..."
apk add --no-cache pulseaudio pulseaudio-utils \
    || warn "PulseAudio no pudo instalarse. El audio puede no funcionar."
success "PulseAudio instalado."

# ── PASO 6: Dependencias de Antigravity ────────────────────
info "Instalando dependencias de Antigravity..."
apk add --no-cache \
    nss \
    nspr \
    at-spi2-core \
    gtk+3.0 \
    pango \
    cairo \
    glib \
    libxcomposite \
    libxdamage \
    libxrandr \
    libxkbcommon \
    alsa-lib \
    || warn "Algunas dependencias de UI no se instalaron. Antigravity puede mostrar advertencias."
success "Dependencias de Antigravity instaladas."

# ── PASO 7: Descargar binario oficial de Antigravity ───────
info "Descargando Google Antigravity (binario oficial ARM64)..."
mkdir -p "$INSTALL_DIR"
cd /tmp || error "No se pudo acceder a /tmp."

aria2c -x 4 -s 4 -o Antigravity.tar.gz "$ANTIGRAVITY_URL" \
    || error "Fallo al descargar Antigravity. Verifica tu conexión (~300 MB)."

success "Descarga completada."

# ── PASO 8: Extraer e instalar ─────────────────────────────
info "Extrayendo Antigravity en ${INSTALL_DIR}..."
tar -xzf Antigravity.tar.gz -C "$INSTALL_DIR" --strip-components=1 \
    || error "Fallo al extraer el archivo."
rm -f /tmp/Antigravity.tar.gz
chmod +x "${INSTALL_DIR}/bin/antigravity"
success "Antigravity instalado en ${INSTALL_DIR}."

# ── PASO 9: Script lanzador principal ──────────────────────
info "Creando script de inicio /usr/local/bin/start-antigravity..."
cat > /usr/local/bin/start-antigravity << 'EOF'
#!/bin/sh
# ── Lanzador de Google Antigravity para Alpine/QEMU ──
export DISPLAY="${DISPLAY:-:1}"
export PULSE_SERVER="${PULSE_SERVER:-127.0.0.1}"
# Asegurar que glibc-compat está en el path de librerías
export LD_LIBRARY_PATH="/usr/glibc-compat/lib:${LD_LIBRARY_PATH}"

echo "[Antigravity] Iniciando..."
exec /opt/antigravity/bin/antigravity --no-sandbox "$@"
EOF
chmod +x /usr/local/bin/start-antigravity
success "Lanzador creado."

# ── PASO 10: Configurar Fluxbox ────────────────────────────
info "Configurando Fluxbox..."
mkdir -p /root/.fluxbox
cat > /root/.fluxbox/menu << 'MENUEOF'
[begin] (Antigravity)
    [exec] (Iniciar Antigravity) {start-antigravity}
    [exec] (Terminal) {xterm}
    [separator]
    [submenu] (Sistema)
        [exec] (Salir) {fluxbox-remote quit}
    [end]
[end]
MENUEOF
success "Fluxbox configurado."

# ── PASO 11: Script de desinstalación ──────────────────────
cat > /usr/local/bin/uninstall-antigravity << 'EOF'
#!/bin/sh
printf "\033[1;37m¿Desinstalar Google Antigravity?\033[0m\n"
printf "1. Desinstalar conservando datos de usuario\n"
printf "2. Desinstalar eliminando todos los datos\n"
printf "Otro. Cancelar\n"
read -r opt
case "$opt" in
    1)
        rm -rf /opt/antigravity
        rm -f /usr/local/bin/start-antigravity
        printf "\033[1;32m[✓] Antigravity desinstalado (datos conservados).\033[0m\n"
        ;;
    2)
        rm -rf /opt/antigravity /root/.config/Google/Antigravity
        rm -f /usr/local/bin/start-antigravity
        printf "\033[1;32m[✓] Antigravity desinstalado (datos eliminados).\033[0m\n"
        ;;
    *)
        printf "Cancelado.\n"
        ;;
esac
EOF
chmod +x /usr/local/bin/uninstall-antigravity

# ── Resumen ─────────────────────────────────────────────────
printf "\n${G}══════════════════════════════════════════════${NC}\n"
printf "${G}  ✅ Instalación completada exitosamente!${NC}\n"
printf "${G}══════════════════════════════════════════════${NC}\n\n"
printf "  ${C}Desde Termux (fuera de Alpine), ejecuta:${NC}\n\n"
printf "      ${Y}./start-gui.sh${NC}\n\n"
printf "  Esto abrirá X11 y lanzará Antigravity\n"
printf "  automáticamente en la app Termux:X11.\n\n"
printf "  ${W}Para desinstalar (dentro de Alpine):${NC}\n"
printf "      uninstall-antigravity\n\n"
