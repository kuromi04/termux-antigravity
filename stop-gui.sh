#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Parada del Entorno
#  Autor: @maka0024 (kuromi04)
# ============================================================

Y='\033[1;33m'; G='\033[0;32m'; NC='\033[0m'

echo -e "${Y}[*] Deteniendo entorno gráfico...${NC}"

# Detener procesos dentro de Alpine
if command -v termux-docker-qemu &>/dev/null; then
    termux-docker-qemu alpine sh -c \
        "pkill -f antigravity 2>/dev/null; pkill fluxbox 2>/dev/null" 2>/dev/null || true
fi

# Detener procesos en Termux
pkill -f antigravity 2>/dev/null || true
pkill fluxbox        2>/dev/null || true
pkill termux-x11     2>/dev/null || true
pkill pulseaudio     2>/dev/null || true

sleep 1
echo -e "${G}[OK] Entorno detenido correctamente.${NC}"
