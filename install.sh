#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Language Detection
if [[ "${LANG:-}" =~ "es" ]]; then
    LANG_ES=true
else
    LANG_ES=false
fi

# Curated Colors
C_ACCENT='\e[38;2;168;85;247m' # Purple
C_INFO='\e[38;2;56;189;248m'   # Light Blue
C_SUCCESS='\e[38;2;52;211;153m' # Mint Green
C_WARN='\e[38;2;251;191;36m'    # Amber
C_NC='\e[0m'

msg_step() {
    local step=$1
    local en_msg=$2
    local es_msg=$3
    if [ "$LANG_ES" = true ]; then
        echo -e "${C_ACCENT}🌌 [$step]${C_NC} ${C_INFO}${es_msg}${C_NC}"
    else
        echo -e "${C_ACCENT}🌌 [$step]${C_NC} ${C_INFO}${en_msg}${C_NC}"
    fi
}

msg_success() {
    local en_msg=$1
    local es_msg=$2
    if [ "$LANG_ES" = true ]; then
        echo -e "${C_SUCCESS}✨ $es_msg${C_NC}"
    else
        echo -e "${C_SUCCESS}✨ $en_msg${C_NC}"
    fi
}

msg_info() {
    local en_msg=$1
    local es_msg=$2
    if [ "$LANG_ES" = true ]; then
        echo -e "${C_INFO}ℹ️  $es_msg${C_NC}"
    else
        echo -e "${C_INFO}ℹ️  $en_msg${C_NC}"
    fi
}

if [ "$LANG_ES" = true ]; then
    echo -e "${C_ACCENT}🚀 Iniciando instalación de Termux-Antigravity...${C_NC}"
else
    echo -e "${C_ACCENT}🚀 Starting Termux-Antigravity Installation...${C_NC}"
fi

msg_step "1/7" "Installing Termux packages..." "Instalando paquetes de Termux..."
pkg install -y x11-repo
pkg install -y proot-distro pulseaudio patchelf-glibc glibc-repo libxcomposite-glibc libxfixes-glibc libxext-glibc libxrandr-glibc libxkbcommon-glibc pango-glibc libcairo-glibc alsa-lib-glibc

msg_step "2/7" "Checking Debian installation..." "Verificando instalación de Debian..."
if [ ! -d "/data/data/com.termux/files/usr/var/lib/proot-distro/containers/debian" ]; then
    msg_info "Installing debian via proot-distro..." "Instalando debian vía proot-distro..."
    proot-distro install debian
else
    msg_success "Debian is already installed." "Debian ya está instalado."
fi

msg_step "3/7" "Installing GUI libraries in Debian..." "Instalando librerías GUI en Debian..."
proot-distro login debian -- sh -c "apt update && apt install -y ca-certificates curl gnupg libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcairo2 libcups2 libdbus-1-3 libdrm2 libexpat1 libgbm1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxkbfile1 libxrandr2 gcc"

AGY_DIR="$HOME/.local/share/antigravity"
mkdir -p "$AGY_DIR"
cd "$AGY_DIR"

msg_step "4/7" "Downloading Antigravity..." "Descargando Antigravity..."
curl -L -o Antigravity.tar.gz "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-arm/Antigravity.tar.gz"

msg_step "5/7" "Extracting Antigravity..." "Extrayendo Antigravity..."
tar -xzf Antigravity.tar.gz --strip-components=1
rm Antigravity.tar.gz

msg_step "6/7" "Compiling localtime fix..." "Compilando parche localtime..."
cat << 'EOF' > "$AGY_DIR/localtime_fix.c"
#include <time.h>
struct tm *localtime64(const time_t *timep) {
    return localtime(timep);
}
struct tm *localtime64_r(const time_t *timep, struct tm *result) {
    return localtime_r(timep, result);
}
EOF
proot-distro login debian -- gcc -shared -fPIC -o /data/data/com.termux/files/home/.local/share/antigravity/liblocaltime_fix.so /data/data/com.termux/files/home/.local/share/antigravity/localtime_fix.c

msg_step "7/7" "Patching interpreter and creating launcher..." "Parcheando intérprete y creando lanzador..."
patchelf --set-interpreter /data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1 "$AGY_DIR/antigravity"

WRAPPER="/data/data/com.termux/files/usr/bin/antigravity"
cat << 'EOF' > "$WRAPPER"
#!/data/data/com.termux/files/usr/bin/bash
export LD_LIBRARY_PATH="/data/data/com.termux/files/usr/glibc/lib:/data/data/com.termux/files/usr/var/lib/proot-distro/containers/debian/rootfs/usr/lib/aarch64-linux-gnu:/data/data/com.termux/files/usr/var/lib/proot-distro/containers/debian/rootfs/lib/aarch64-linux-gnu"
export LD_PRELOAD="/data/data/com.termux/files/home/.local/share/antigravity/liblocaltime_fix.so"
exec /data/data/com.termux/files/home/.local/share/antigravity/antigravity --no-sandbox "$@"
EOF
chmod +x "$WRAPPER"

msg_success "Installation completed successfully!" "¡Instalación completada exitosamente!"
