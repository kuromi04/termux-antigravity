#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Instalador Principal
#  Autor: @maka0024 (kuromi04)
#
#  EJECUTAR DESDE TERMUX:
#    ./install.sh
#
#  Usa 'termux-docker-qemu alpine' para ejecutar comandos
#  dentro de Alpine sin necesidad de SSH ni contraseña.
# ============================================================

G='\033[0;32m'; C='\033[0;36m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${C}[INFO]${NC}  $1"; }
success() { echo -e "${G}[OK]${NC}    $1"; }
warn()    { echo -e "${Y}[WARN]${NC}  $1"; }
error()   { echo -e "${R}[ERROR]${NC} $1"; exit 1; }

# Alias corto para ejecutar dentro de Alpine
alpine() { termux-docker-qemu alpine sh -c "$1"; }

# Versión de glibc
GLIBC_VER="2.35-r1"
GLIBC_BASE="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}"
GLIBC_KEY="https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub"

# URL del binario oficial ARM64 de Antigravity
ANTIGRAVITY_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz"
INSTALL_DIR="/opt/antigravity"

clear
echo -e "${C}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  Google Antigravity · Alpine QEMU · X11     ║"
echo "  ║         Instalador Automático               ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# --- Verificar que termux-docker-qemu está disponible ---
command -v termux-docker-qemu &>/dev/null \
    || error "'termux-docker-qemu' no encontrado. Instálalo primero."

# --- Verificar que Alpine responde ---
info "Verificando conexión con Alpine..."
alpine "echo OK" | grep -q "OK" \
    || error "No se pudo conectar a Alpine. Verifica que QEMU esté corriendo."
success "Alpine respondiendo correctamente."

# ── PASO 1: Actualizar Alpine ───────────────────────────────
info "Actualizando repositorios de Alpine..."
alpine "apk update && apk upgrade" || warn "Algunos paquetes no se actualizaron."

# Habilitar community
alpine "grep -q community /etc/apk/repositories || \
    echo \"\$(grep 'main' /etc/apk/repositories | head -1 | sed 's|/main.*||')/community\" \
    >> /etc/apk/repositories && apk update"
success "Repositorios actualizados."

# ── PASO 2: Dependencias base ───────────────────────────────
info "Instalando dependencias base en Alpine..."
alpine "apk add --no-cache bash wget curl aria2 git tar ca-certificates gnupg" \
    || error "Fallo al instalar dependencias base."
success "Dependencias base listas."

# ── PASO 3: Instalar glibc real (sgerrand ARM64) ────────────
info "Instalando glibc ${GLIBC_VER} (sgerrand ARM64)..."

alpine "wget -q -O /etc/apk/keys/sgerrand.rsa.pub '${GLIBC_KEY}'" \
    || error "No se pudo descargar la clave GPG de sgerrand."

alpine "
cd /tmp
wget -q '${GLIBC_BASE}/glibc-${GLIBC_VER}.apk'
wget -q '${GLIBC_BASE}/glibc-bin-${GLIBC_VER}.apk'
wget -q '${GLIBC_BASE}/glibc-i18n-${GLIBC_VER}.apk'
apk add --force-overwrite --no-cache \
    /tmp/glibc-${GLIBC_VER}.apk \
    /tmp/glibc-bin-${GLIBC_VER}.apk \
    /tmp/glibc-i18n-${GLIBC_VER}.apk
rm -f /tmp/glibc-*.apk
" || error "Fallo al instalar glibc."

# Configurar loader y locale
alpine "
mkdir -p /lib64
ln -sf /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1 2>/dev/null || true
ln -sf /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /lib64/ld-linux-aarch64.so.1 2>/dev/null || true
/usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 2>/dev/null || true
apk add --no-cache libstdc++ libgcc
"
success "glibc ${GLIBC_VER} instalado correctamente."

# ── PASO 4: Entorno gráfico X11 + Fluxbox ──────────────────
info "Instalando X11 y Fluxbox..."
alpine "apk add --no-cache \
    xorg-server xauth xdpyinfo xterm fluxbox \
    dbus mesa-gl mesa-dri-gallium" \
    || error "Fallo al instalar el entorno gráfico."
success "X11 y Fluxbox instalados."

# ── PASO 5: Audio ───────────────────────────────────────────
info "Instalando PulseAudio..."
alpine "apk add --no-cache pulseaudio pulseaudio-utils" \
    || warn "PulseAudio no pudo instalarse."
success "PulseAudio instalado."

# ── PASO 6: Dependencias de Antigravity ────────────────────
info "Instalando dependencias de Antigravity..."
alpine "apk add --no-cache \
    nss nspr at-spi2-core gtk+3.0 pango cairo glib \
    libxcomposite libxdamage libxrandr libxkbcommon alsa-lib" \
    || warn "Algunas dependencias de UI no se instalaron."
success "Dependencias de Antigravity listas."

# ── PASO 7: Descargar e instalar Antigravity ───────────────
info "Descargando Google Antigravity (~300 MB)..."
alpine "
mkdir -p ${INSTALL_DIR}
aria2c -x 4 -s 4 -d /tmp -o Antigravity.tar.gz '${ANTIGRAVITY_URL}'
" || error "Fallo al descargar Antigravity."

info "Extrayendo Antigravity en ${INSTALL_DIR}..."
alpine "
tar -xzf /tmp/Antigravity.tar.gz -C ${INSTALL_DIR} --strip-components=1
rm -f /tmp/Antigravity.tar.gz
chmod +x ${INSTALL_DIR}/bin/antigravity
" || error "Fallo al extraer Antigravity."
success "Antigravity instalado en ${INSTALL_DIR}."

# ── PASO 8: Script lanzador dentro de Alpine ───────────────
info "Creando /usr/local/bin/start-antigravity en Alpine..."
alpine "cat > /usr/local/bin/start-antigravity << 'EOF'
#!/bin/sh
export DISPLAY=\"\${DISPLAY:-:1}\"
export PULSE_SERVER=\"\${PULSE_SERVER:-127.0.0.1}\"
export LD_LIBRARY_PATH=\"/usr/glibc-compat/lib:\${LD_LIBRARY_PATH}\"
exec /opt/antigravity/bin/antigravity --no-sandbox \"\$@\"
EOF
chmod +x /usr/local/bin/start-antigravity"
success "Lanzador creado."

# ── PASO 9: Configurar Fluxbox ─────────────────────────────
info "Configurando Fluxbox..."
alpine "
mkdir -p /root/.fluxbox
cat > /root/.fluxbox/menu << 'EOF'
[begin] (Antigravity)
    [exec] (Iniciar Antigravity) {start-antigravity}
    [exec] (Terminal) {xterm}
    [separator]
    [submenu] (Sistema)
        [exec] (Salir) {fluxbox-remote quit}
    [end]
[end]
EOF"
success "Fluxbox configurado."

# ── PASO 10: Script de desinstalación ──────────────────────
alpine "cat > /usr/local/bin/uninstall-antigravity << 'EOF'
#!/bin/sh
printf 'Desinstalar Antigravity:\n1. Conservar datos\n2. Eliminar datos\nOtro. Cancelar\n'
read -r opt
case \"\$opt\" in
    1) rm -rf /opt/antigravity; rm -f /usr/local/bin/start-antigravity
       printf 'Desinstalado (datos conservados).\n' ;;
    2) rm -rf /opt/antigravity /root/.config/Google/Antigravity
       rm -f /usr/local/bin/start-antigravity
       printf 'Desinstalado (datos eliminados).\n' ;;
    *) printf 'Cancelado.\n' ;;
esac
EOF
chmod +x /usr/local/bin/uninstall-antigravity"

# ── Resumen ─────────────────────────────────────────────────
echo ""
echo -e "${G}══════════════════════════════════════════════${NC}"
echo -e "${G}  ✅ Instalación completada exitosamente!${NC}"
echo -e "${G}══════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${C}Para iniciar Antigravity ejecuta desde Termux:${NC}"
echo ""
echo -e "      ${Y}./start-gui.sh${NC}"
echo ""
