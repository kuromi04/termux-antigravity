#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity - Lanzador del IDE
#  Autor: @maka0024 (kuromi04)
#
#  Se ejecuta desde Termux. Detecta el método de virtualización
#  (Docker o QEMU) y lanza Antigravity dentro de Alpine
#  apuntando al servidor X11 de Termux:X11.
# ============================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# DISPLAY apunta al servidor X11 de Termux:X11
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1

# Comando a ejecutar dentro de Alpine
# --no-sandbox es obligatorio en entornos sin namespaces completos (Docker/QEMU en Android)
ANTIGRAVITY_CMD="DISPLAY=:1 PULSE_SERVER=127.0.0.1 start-antigravity --no-sandbox"

# ── Detección del método de virtualización ──────────────────

# Opción 1: Docker
if command -v docker &>/dev/null && docker ps &>/dev/null 2>&1; then
    # Buscar contenedor Alpine corriendo
    CONTAINER=$(docker ps --filter "ancestor=alpine" --format "{{.Names}}" | head -1)

    if [ -n "$CONTAINER" ]; then
        info "Contenedor Alpine detectado vía Docker: '${CONTAINER}'"
        info "Lanzando Antigravity dentro del contenedor..."

        # Permitir que el contenedor acceda al servidor X11 de Termux
        xhost +local: 2>/dev/null || true

        docker exec -it \
            -e DISPLAY=:1 \
            -e PULSE_SERVER=127.0.0.1 \
            "$CONTAINER" \
            sh -c "start-antigravity --no-sandbox"

        exit $?
    else
        warn "No se encontró contenedor Alpine corriendo en Docker."
    fi
fi

# Opción 2: QEMU (acceso vía chroot o proot)
if command -v proot &>/dev/null; then
    # Detectar instalación Alpine bajo proot (común en Termux)
    ALPINE_ROOT=""
    for dir in "$HOME/alpine" "$HOME/.alpine" "/data/alpine" "/sdcard/alpine"; do
        if [ -f "${dir}/etc/alpine-release" ]; then
            ALPINE_ROOT="$dir"
            break
        fi
    done

    if [ -n "$ALPINE_ROOT" ]; then
        info "Alpine detectado vía proot en: ${ALPINE_ROOT}"
        info "Lanzando Antigravity con proot..."

        proot \
            --link2symlink \
            -0 \
            -r "$ALPINE_ROOT" \
            -b /dev \
            -b /proc \
            -b /sys \
            -b "/tmp/.X11-unix:/tmp/.X11-unix" \
            -w /root \
            /usr/bin/env \
                DISPLAY=:1 \
                PULSE_SERVER=127.0.0.1 \
                HOME=/root \
                PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
            /bin/sh -c "start-antigravity --no-sandbox"

        exit $?
    fi
fi

# Opción 3: chroot directo (requiere root en Android)
if command -v chroot &>/dev/null; then
    ALPINE_ROOT=""
    for dir in "$HOME/alpine" "/data/alpine"; do
        if [ -f "${dir}/etc/alpine-release" ]; then
            ALPINE_ROOT="$dir"
            break
        fi
    done

    if [ -n "$ALPINE_ROOT" ]; then
        info "Alpine detectado vía chroot en: ${ALPINE_ROOT}"
        mount --bind /dev  "${ALPINE_ROOT}/dev"  2>/dev/null || true
        mount --bind /proc "${ALPINE_ROOT}/proc" 2>/dev/null || true
        chroot "$ALPINE_ROOT" /bin/sh -c \
            "DISPLAY=:1 PULSE_SERVER=127.0.0.1 start-antigravity --no-sandbox"
        exit $?
    fi
fi

# ── Sin método disponible ───────────────────────────────────
error "No se detectó ningún método válido para acceder al contenedor Alpine.
       Verifica que tu contenedor Alpine esté corriendo y que Docker o proot
       estén instalados. Consulta el README para más información."
