#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Lanzador (Termux → Alpine QEMU)
#  Autor: @maka0024 (kuromi04)
#
#  EJECUTAR DESDE TERMUX.
#  Detecta tu Alpine corriendo en QEMU y le envía
#  el comando para lanzar Antigravity con DISPLAY=:1
#  apuntando al servidor X11 de Termux:X11.
# ============================================================

G='\033[0;32m'; C='\033[0;36m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${C}[INFO]${NC}  $1"; }
success() { echo -e "${G}[OK]${NC}    $1"; }
warn()    { echo -e "${Y}[WARN]${NC}  $1"; }
error()   { echo -e "${R}[ERROR]${NC} $1"; exit 1; }

# Display del servidor Termux:X11 (corriendo en Termux)
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1

# Comando a ejecutar dentro de Alpine
# LD_LIBRARY_PATH asegura que glibc-compat sea encontrado
# --no-sandbox es obligatorio en entornos QEMU sin namespaces completos
LAUNCH_CMD="export DISPLAY=:1 PULSE_SERVER=127.0.0.1 LD_LIBRARY_PATH=/usr/glibc-compat/lib:\$LD_LIBRARY_PATH && fluxbox &>/dev/null & sleep 1 && start-antigravity --no-sandbox"

# ── Detección del método de acceso a QEMU ──────────────────

# Puerto SSH por defecto de Alpine en QEMU (Termux suele usar 2222 o 2200)
QEMU_SSH_PORTS="2222 2200 22222 10022"
QEMU_HOST="127.0.0.1"
QEMU_USER="root"

# ── Opción 1: SSH hacia Alpine QEMU ────────────────────────
if command -v ssh &>/dev/null; then
    for PORT in $QEMU_SSH_PORTS; do
        if ssh -o ConnectTimeout=2 \
               -o StrictHostKeyChecking=no \
               -o BatchMode=yes \
               -p "$PORT" \
               "${QEMU_USER}@${QEMU_HOST}" \
               "exit 0" &>/dev/null 2>&1; then

            info "Alpine detectado via SSH en puerto ${PORT}."
            info "Reenviando display X11 a Alpine y lanzando Antigravity..."

            # Verificar que Antigravity está instalado dentro de Alpine
            if ! ssh -o StrictHostKeyChecking=no -p "$PORT" \
                     "${QEMU_USER}@${QEMU_HOST}" \
                     "test -f /opt/antigravity/bin/antigravity" 2>/dev/null; then
                error "Antigravity no encontrado en Alpine. Ejecuta install.sh dentro de Alpine primero."
            fi

            # Lanzar con reenvío X11 (-X) para que el display pase al servidor X11 de Termux
            ssh -X \
                -o StrictHostKeyChecking=no \
                -o ForwardX11Trusted=yes \
                -p "$PORT" \
                "${QEMU_USER}@${QEMU_HOST}" \
                "sh -c '${LAUNCH_CMD}'"

            exit $?
        fi
    done
    warn "No se encontró Alpine en SSH (puertos: ${QEMU_SSH_PORTS})."
fi

# ── Opción 2: qemu-system corriendo como proceso en Termux ─
# Algunos setups montan el sistema de archivos de Alpine como
# una carpeta accesible desde Termux
ALPINE_FS_PATHS="$HOME/alpine $HOME/qemu/alpine /data/alpine /sdcard/alpine"
if command -v proot &>/dev/null; then
    for APATH in $ALPINE_FS_PATHS; do
        if [ -f "${APATH}/etc/alpine-release" ]; then
            info "Alpine detectado vía proot en: ${APATH}"

            # Permitir acceso X11 local
            xhost +local: 2>/dev/null || true

            proot \
                --link2symlink \
                -0 \
                -r "$APATH" \
                -b /dev \
                -b /proc \
                -b /sys \
                -b "/tmp/.X11-unix:/tmp/.X11-unix" \
                -w /root \
                /usr/bin/env \
                    DISPLAY=:1 \
                    PULSE_SERVER=127.0.0.1 \
                    LD_LIBRARY_PATH="/usr/glibc-compat/lib" \
                    HOME=/root \
                    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
                /bin/sh -c "$LAUNCH_CMD"

            exit $?
        fi
    done
fi

# ── Sin método detectado ────────────────────────────────────
echo ""
error "No se pudo conectar a Alpine.

  Opciones para solucionarlo:

  1. SSH: Asegúrate de que Alpine QEMU tiene sshd corriendo
     y que el puerto está en ${QEMU_SSH_PORTS}. Instala en Alpine:
       apk add openssh && rc-service sshd start

  2. Ajusta el puerto en este script si usas otro puerto.
     Edita la línea: QEMU_SSH_PORTS=\"2222 2200 22222 10022\"

  3. Si usas proot, verifica que tu Alpine está en:
     ${ALPINE_FS_PATHS}"
