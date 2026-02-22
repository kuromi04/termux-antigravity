#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity - Lanzador del IDE
#  Autor: @maka0024 (kuromi04)
# ============================================================

export DISPLAY="${DISPLAY:-:1}"

# Intentar lanzar Google Antigravity si está instalado vía npm
if command -v antigravity &>/dev/null; then
    echo "[Antigravity] Lanzando Google Antigravity IDE..."
    antigravity
# Lanzador alternativo instalado por install.sh
elif command -v antigravity-ide &>/dev/null; then
    echo "[Antigravity] Lanzando mediante antigravity-ide..."
    antigravity-ide
# Fallback: terminal xterm
# CORRECCIÓN: sin & para que el proceso bloquee y start-gui.sh
# no finalice antes de que el IDE esté corriendo
else
    echo "[Antigravity] IDE no encontrado. Abriendo terminal de desarrollo..."
    xterm \
        -fa 'Monospace' \
        -fs 12 \
        -bg '#1e1e2e' \
        -fg '#cdd6f4' \
        -title "Antigravity Dev Terminal" \
        -e bash --login
fi
