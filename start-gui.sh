#!/data/data/com.termux/files/usr/bin/bash

# Limpieza de procesos
pkill -9 termux-x11
pkill -9 fluxbox

echo "[*] Iniciando servidor gráfico y audio..."
termux-x11 :1 > /dev/null 2>&1 &
pulseaudio --start --exit-idle-time=-1

sleep 3

# Variables de entorno
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR=${TMPDIR}

# Lanzar gestor de ventanas y el IDE
fluxbox &
echo "[*] Abriendo Google Antigravity..."
./antigravity.sh
