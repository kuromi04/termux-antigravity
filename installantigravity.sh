#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Google Antigravity para Termux
#  Autor: @maka0024 (kuromi04)
#  GitHub: https://github.com/kuromi04/termux-antigravity
# ============================================================

# --- Permisos de almacenamiento ---
clear
getpermisionsdcard=$(ls -l /sdcard/)
if [ "$getpermisionsdcard" == "" ]; then
    echo -e "\e[1;37m[!] Debes conceder acceso al almacenamiento.\e[0m"
    yes y | termux-setup-storage
    clear
    echo -e "\e[1;37m[i] Continuando en 5 segundos...\e[0m"
    sleep 5
fi

# --- Aviso ---
clear
echo -e "\e[1;37m[!] ¡Aviso importante, no lo ignores!\e[0m"
echo -e "\e[1;37m-\e[0m"
echo -e "\e[1;37mAsegúrate de tener al menos 4 GB de espacio libre."
echo -e "No ejecutes otros comandos durante la instalación."
echo -e "Si quieres cancelar presiona Ctrl + C ahora.\e[0m"
echo -e "\e[1;37m\e[0m"
echo -e "\e[1;37mContinúa en 60 segundos o presiona cualquier tecla para empezar ya.\e[0m"
if read -r -t 60 -n 1 _; then
    echo "Continuando..."
else
    echo "60 segundos, continuando..."
fi

# --- Instalar paquetes en Termux ---
clear
echo -e '\e[1;37m[i] Instalando paquetes en Termux...\e[0m'
apt update
yes y | apt upgrade -y
apt install x11-repo -y
apt install proot-distro aria2 termux-x11-nightly -y

# --- Instalar Debian ---
clear
echo -e '\e[1;37m[i] Instalando Debian...\e[0m'
proot-distro install debian

# --- Descargar Antigravity ---
clear
echo -e '\e[1;37m[i] Descargando Google Antigravity (~300 MB)...\e[0m'
DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
mkdir -p "$DEBIAN_ROOT/Apps/IDE"
cd "$DEBIAN_ROOT/Apps/IDE" || exit 1
aria2c -x 4 -o Antigravity.tar.gz \
    https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz

# --- Extraer ---
clear
echo -e '\e[1;37m[i] Instalando Google Antigravity...\e[0m'
tar -xvzf Antigravity.tar.gz
rm Antigravity.tar.gz
cd Antigravity

# Script que abre X11 + fluxbox + Antigravity
cat > antigravity.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity && \
termux-x11 -xstartup "bash -c 'fluxbox & thunar & /Apps/IDE/Antigravity/bin/antigravity --no-sandbox && sleep infinity'"
EOF

chmod +x bin/antigravity
chmod +x antigravity.sh

# --- Configurar entorno ---
clear
echo -e '\e[1;37m[i] Configurando entorno...\e[0m'

mkdir -p "$DEBIAN_ROOT/home/devroom"

# install2: se ejecuta en el primer login de Debian
cat > "$DEBIAN_ROOT/etc/profile.d/installantigravity.sh" << 'INSTALL2'
#!/bin/bash
chmod -x /etc/profile.d/installantigravity.sh
clear
echo -e '\e[1;37m[i] Instalando paquetes dentro de Debian...\e[0m'
apt update && apt upgrade -y
apt install -y sudo xterm thunar fluxbox aria2 firefox-esr \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 \
    libcairo2 libcurl3-gnutls libcurl4 libdbus-1-3 libexpat1 \
    libgbm1 libglib2.0-0 libgtk-3-0 libgtk-4-1 libnspr4 libnss3 \
    libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 \
    libxext6 libxfixes3 libxkbcommon0 libxkbfile1 libxrandr2 xdg-utils
useradd -m devroom 2>/dev/null || true
passwd -d devroom
usermod -s /bin/bash devroom
echo 'devroom ALL=(ALL) ALL' | tee /etc/sudoers.d/devroom
chmod 440 /etc/sudoers.d/devroom
rm -f /etc/profile.d/installantigravity.sh
clear
echo -e '\e[1;37m[i] ¡Debian configurado! Escribe "exit" para volver al menú.\e[0m'
INSTALL2
chmod +x "$DEBIAN_ROOT/etc/profile.d/installantigravity.sh"

# Scripts internos de Debian
cat > "$DEBIAN_ROOT/root/antigravity.sh" << 'EOF'
#!/bin/bash
sed -i "/startantigravity.sh/d" /home/devroom/.profile 2>/dev/null
echo "/Apps/IDE/Antigravity/startantigravity.sh" >> /home/devroom/.profile
clear
su - devroom
clear
EOF
chmod +x "$DEBIAN_ROOT/root/antigravity.sh"

cat > "$DEBIAN_ROOT/home/devroom/antigravity.sh" << 'EOF'
#!/bin/bash
/Apps/IDE/Antigravity/startantigravity.sh
EOF
chmod +x "$DEBIAN_ROOT/home/devroom/antigravity.sh"

# --- Primer login para ejecutar install2 ---
clear
echo -e '\e[1;37m[i] Configurando Debian (primera vez)... Escribe "exit" cuando termine.\e[0m'
proot-distro login debian

clear
echo -e "\e[1;37m[i] ¡Instalación completada! Ejecuta: ./antigravity.sh\e[0m"
