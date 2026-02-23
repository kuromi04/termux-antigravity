#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Google Antigravity para Termux
#  Autor: @maka0024 (kuromi04)
#
#  Uso:
#    curl -H 'Cache-Control: no-cache' -o installantigravity.sh \
#      https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/installantigravity.sh \
#    && chmod +rwx installantigravity.sh \
#    && ./installantigravity.sh \
#    && rm installantigravity.sh \
#    && clear
# ============================================================

# --- Permisos de almacenamiento ---
clear
getpermisionsdcard=$(ls -l /sdcard/)
if [ "$getpermisionsdcard" == "" ]; then
    echo -e "\e[1;37m[!] Debes conceder acceso al almacenamiento."
    yes y | termux-setup-storage
    clear
    echo -e "\e[1;37m[i] Continuando en 5 segundos...\e[0m"
    sleep 5
fi

# --- Aviso ---
clear
echo -e "\e[1;37m[!] ¡Aviso importante, no lo ignores!\e[0m"
echo -e "\e[1;37m-\e[0m"
echo -e "\e[1;37mAsegúrate de tener al menos 4 GB de espacio libre. No ejecutes otros comandos durante la instalación. Si quieres cancelar, presiona Ctrl + C ahora.\e[0m"
echo -e "\e[1;37m\e[0m"
echo -e "\e[1;37mContinúa automáticamente en 60 segundos o presiona cualquier tecla para empezar ya.\e[0m"
if read -r -t 60 -n 1 _; then
    echo "Tecla presionada, continuando..."
else
    echo "60 segundos transcurridos, continuando..."
fi

# --- Instalar paquetes en Termux ---
clear
echo -e '\e[1;37m[i] Instalando paquetes...\e[0m'
apt update
yes y | apt upgrade -y
apt install x11-repo -y
apt install proot-distro aria2 termux-x11-nightly -y

# --- Instalar Debian vía proot-distro ---
clear
echo -e '\e[1;37m[i] Instalando Linux (Debian)...\e[0m'
proot-distro install debian

# --- Descargar binario de Antigravity ---
clear
echo -e '\e[1;37m[i] Descargando Google Antigravity...\e[0m'
cd "$PREFIX/var/lib/proot-distro/installed-rootfs/debian" || exit 1
mkdir -p Apps/IDE
cd Apps/IDE
aria2c -x 4 -o Antigravity.tar.gz \
    https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.16.5-6703236727046144/linux-arm/Antigravity.tar.gz

# --- Extraer e instalar ---
clear
echo -e '\e[1;37m[i] Instalando Google Antigravity...\e[0m'
tar -xvzf Antigravity.tar.gz
rm Antigravity.tar.gz
cd Antigravity

# Script que lanza X11 + fluxbox + thunar + Antigravity
cat > antigravity.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity && \
termux-x11 -xstartup "bash -c 'fluxbox & thunar & /Apps/IDE/Antigravity/bin/antigravity --no-sandbox && sleep infinity'"
EOF

# startantigravity.sh — menú interactivo dentro de Debian
cat > startantigravity.sh << 'EOF'
#!/bin/bash
sed -i "/startantigravity.sh/d" "$HOME/.profile"
clear
getpermisionsdcard=$(ls -l /sdcard/)
if [ "$getpermisionsdcard" == "" ]; then
    echo -e "\e[1;37m[!] Sin acceso al almacenamiento.\e[0m"
    echo -e "\e[1;37m--------------------\e[0m"
fi
echo -e "\e[1;37m--------------------\e[0m"
echo -e "\e[1;37m¿Qué quieres hacer con Google Antigravity?\e[0m"
echo -e "\e[1;37m--------------------\e[0m"
echo -e "\e[1;37m1. Iniciar Antigravity\e[0m"
echo -e "\e[1;37m2. Desinstalar\e[0m"
echo -e "\e[1;37mOtro. Salir y usar Debian\e[0m"
echo -e "\e[1;37m--------------------\e[0m"
read -r -n 1 option
case "$option" in
    '1')
        clear
        echo -e "\e[1;37m[i] Iniciando Google Antigravity...\e[0m"
        /Apps/IDE/Antigravity/antigravity.sh
        /Apps/IDE/Antigravity/startantigravity.sh
        ;;
    '2')
        /Apps/IDE/Antigravity/uninstall.sh
        ;;
    *)
        clear
        echo -e "\e[1;37mSaliendo...\e[0m"
        ;;
esac
clear
EOF

# uninstall.sh — desinstalador con opciones
cat > uninstall.sh << 'EOF'
#!/bin/bash
echo -e "\e[1;37m--------------------\e[0m"
echo -e "\e[1;37m¿Desinstalar Google Antigravity?\e[0m"
echo -e "\e[1;37m--------------------\e[0m"
echo -e "\e[1;37m1. Desinstalar y CONSERVAR datos del usuario.\e[0m"
echo -e "\e[1;37m2. Desinstalar y ELIMINAR datos del usuario.\e[0m"
echo -e "\e[1;37mOtro. Cancelar\e[0m"
echo -e "\e[1;37m--------------------\e[0m"
read -r -n 1 option
case "$option" in
    '1')
        clear
        echo -e "\e[1;37m[i] Desinstalando Antigravity...\e[0m"
        sed -i "/startantigravity.sh/d" "$HOME/.profile"
        rm -rf "$HOME/antigravity.sh"
        sudo rm -f /root/antigravity.sh /data/data/com.termux/files/home/antigravity.sh
        sudo rm -rf /Apps/IDE/Antigravity
        clear
        echo -e "\e[1;37m[i] Antigravity desinstalado (datos conservados).\e[0m"
        ;;
    '2')
        clear
        echo -e "\e[1;37m[i] Desinstalando Antigravity...\e[0m"
        sed -i "/startantigravity.sh/d" "$HOME/.profile"
        rm -rf "$HOME/antigravity.sh" "$HOME/.antigravity"
        sudo rm -f /root/antigravity.sh /root/.antigravity \
                   /data/data/com.termux/files/home/antigravity.sh
        sudo rm -rf /Apps/IDE/Antigravity
        clear
        echo -e "\e[1;37m[i] Antigravity desinstalado (datos eliminados).\e[0m"
        ;;
    *)
        clear
        echo -e "\e[1;37mCancelando...\e[0m"
        ;;
esac
clear
EOF

chmod +x bin/antigravity
chmod +x antigravity.sh
chmod +x startantigravity.sh
chmod +x uninstall.sh

# --- Preparar estructura de usuarios y scripts ---
clear
echo -e '\e[1;37m[i] Configurando entorno...\e[0m'

DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"

# Crear directorio home de devroom
mkdir -p "$DEBIAN_ROOT/home/devroom"

# install2.sh — se ejecuta automáticamente al primer login en Debian
# instala paquetes dentro de Debian y crea el usuario devroom
cat > "$DEBIAN_ROOT/etc/profile.d/installantigravity.sh" << 'INSTALL2'
#!/bin/bash
chmod -x /etc/profile.d/installantigravity.sh
clear
echo -e '\e[1;37m[i] Instalando paquetes dentro de Debian...\e[0m'
apt update
apt upgrade -y
apt install -y sudo xterm thunar fluxbox aria2 firefox-esr \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 \
    libcairo2 libcurl3-gnutls libcurl4 libdbus-1-3 libexpat1 \
    libgbm1 libglib2.0-0 libgtk-3-0 libgtk-4-1 libnspr4 libnss3 \
    libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 \
    libxext6 libxfixes3 libxkbcommon0 libxkbfile1 libxrandr2 xdg-utils
useradd -m devroom
passwd -d devroom
usermod -s /bin/bash devroom
echo 'devroom ALL=(ALL) ALL' | tee /etc/sudoers.d/devroom
chmod 440 /etc/sudoers.d/devroom
clear
echo -e '\e[1;37m[i] ¡Listo!\e[0m'
echo -e '\e[1;37m-\e[0m'
echo -e "\e[1;37mEjecuta: \"./antigravity.sh\"\e[0m"
echo -e '\e[1;37m-\e[0m'
rm -f /etc/profile.d/installantigravity.sh
rm -f /data/data/com.termux/files/home/installantigravity.sh
INSTALL2
chmod +x "$DEBIAN_ROOT/etc/profile.d/installantigravity.sh"

# Script de arranque para root dentro de Debian
cat > "$DEBIAN_ROOT/root/antigravity.sh" << EOF
#!/bin/bash
sed -i "/startantigravity.sh/d" /home/devroom/.profile
echo "/Apps/IDE/Antigravity/startantigravity.sh" >> /home/devroom/.profile
clear
su - devroom
clear
EOF
chmod +x "$DEBIAN_ROOT/root/antigravity.sh"

# Script de arranque para devroom dentro de Debian
cat > "$DEBIAN_ROOT/home/devroom/antigravity.sh" << 'EOF'
#!/bin/bash
/Apps/IDE/Antigravity/startantigravity.sh
EOF
chmod +x "$DEBIAN_ROOT/home/devroom/antigravity.sh"

# Script ./antigravity.sh en el HOME de Termux (el que usas cada día)
cat > "$HOME/antigravity.sh" << EOF
#!/data/data/com.termux/files/usr/bin/bash
sed -i "/startantigravity.sh/d" ${DEBIAN_ROOT}/home/devroom/.profile
echo '/Apps/IDE/Antigravity/startantigravity.sh' >> ${DEBIAN_ROOT}/home/devroom/.profile
clear
proot-distro login debian --user devroom
clear
EOF
chmod +x "$HOME/antigravity.sh"

# --- Primer login en Debian para ejecutar install2 ---
clear
echo -e '\e[1;37m[i] Entrando a Debian para completar la instalación...\e[0m'
proot-distro login debian

clear
echo -e "\e[1;37m[i] ¡Instalación completada!\e[0m"
echo -e "\e[1;37m-\e[0m"
echo -e "\e[1;37mEjecuta: ./antigravity.sh\e[0m"
echo -e "\e[1;37m-\e[0m"
