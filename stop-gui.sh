#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity - Script de Parada del Entorno Gráfico
#  Autor: @maka0024 (kuromi04)
# ============================================================

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${YELLOW}[*] Deteniendo entorno gráfico...${NC}"

# Detener Antigravity dentro del contenedor si está corriendo vía Docker
if command -v docker &>/dev/null; then
    CONTAINER=$(docker ps --filter "ancestor=alpine" --format "{{.Names}}" | head -1)
    if [ -n "$CONTAINER" ]; then
        docker exec "$CONTAINER" sh -c "pkill -f antigravity 2>/dev/null || true" 2>/dev/null
        docker exec "$CONTAINER" sh -c "pkill fluxbox 2>/dev/null || true" 2>/dev/null
    fi
fi

# Detener procesos en Termux
pkill -f antigravity 2>/dev/null || true
pkill fluxbox        2>/dev/null || true
pkill termux-x11     2>/dev/null || true
pkill pulseaudio     2>/dev/null || true

sleep 1

echo -e "${GREEN}[OK] Entorno gráfico detenido correctamente.${NC}"
