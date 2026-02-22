#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Parada del Entorno
#  Autor: @maka0024 (kuromi04)
# ============================================================

Y='\033[1;33m'; G='\033[0;32m'; NC='\033[0m'

echo -e "${Y}[*] Deteniendo entorno gráfico...${NC}"

# Detener dentro de Alpine via SSH si está disponible
for PORT in 2222 2200 22222 10022; do
    if ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no \
           -o BatchMode=yes -p "$PORT" root@127.0.0.1 "exit 0" &>/dev/null 2>&1; then
        ssh -o StrictHostKeyChecking=no -p "$PORT" root@127.0.0.1 \
            "pkill -f antigravity; pkill fluxbox" 2>/dev/null || true
        break
    fi
done

# Detener en Termux
pkill -f antigravity 2>/dev/null || true
pkill fluxbox        2>/dev/null || true
pkill termux-x11     2>/dev/null || true
pkill pulseaudio     2>/dev/null || true

sleep 1
echo -e "${G}[OK] Entorno detenido correctamente.${NC}"
