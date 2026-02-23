#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Google Antigravity — Lanzador diario
#  Autor: @maka0024 (kuromi04)
#
#  Ejecuta desde Termux: ./antigravity.sh
#  Entra a Debian como 'devroom' y lanza Antigravity.
# ============================================================

DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"

# Verificar instalación
if [ ! -f "$DEBIAN_ROOT/Apps/IDE/Antigravity/bin/antigravity" ]; then
    echo -e "\e[1;31m[!] Antigravity no está instalado.\e[0m"
    echo -e "\e[1;37mEjecuta primero el instalador:\e[0m"
    echo -e "\e[1;37mcurl -H 'Cache-Control: no-cache' -o installantigravity.sh https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/installantigravity.sh && chmod +rwx installantigravity.sh && ./installantigravity.sh && rm installantigravity.sh && clear\e[0m"
    exit 1
fi

# Inyectar autorun en .profile de devroom
sed -i "/startantigravity.sh/d" "${DEBIAN_ROOT}/home/devroom/.profile" 2>/dev/null || true
echo '/Apps/IDE/Antigravity/startantigravity.sh' >> "${DEBIAN_ROOT}/home/devroom/.profile"

clear

# Entrar a Debian como devroom → startantigravity.sh se ejecuta solo
proot-distro login debian --user devroom

clear
