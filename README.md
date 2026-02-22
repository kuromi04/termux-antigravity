# 🌌 Termux-Antigravity
### *Google Antigravity IDE · Alpine Linux · QEMU · X11*

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-a855f7?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3ddc84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Alpine](https://img.shields.io/badge/Distro-Alpine_Linux-0d597f?style=for-the-badge&logo=alpinelinux&logoColor=white)](https://alpinelinux.org)
[![Termux](https://img.shields.io/badge/Termux-X11-f97316?style=for-the-badge&logo=gnometerminal&logoColor=white)](https://termux.dev/)
[![ShellCheck](https://img.shields.io/github/actions/workflow/status/kuromi04/termux-antigravity/shellcheck.yml?label=ShellCheck&style=for-the-badge&logo=gnubash&logoColor=white)](https://github.com/kuromi04/termux-antigravity/actions)

<br/>

> **Google Antigravity IDE funcionando en Android sobre Alpine Linux.**  
> Usa QEMU en Termux, instala glibc real sobre Alpine y lanza el IDE con interfaz gráfica X11.

</div>

---

## 🏗️ Arquitectura

```
Android
└── Termux
    ├── Termux:X11  ──────────────────── display :1
    ├── PulseAudio  ──────────────────── audio
    ├── start-gui.sh / antigravity.sh  ─ orquestación
    └── QEMU
        └── Alpine Linux
            ├── glibc 2.35 (sgerrand) ─ compatibilidad con binarios glibc
            ├── Fluxbox               ─ gestor de ventanas
            └── /opt/antigravity/
                └── bin/antigravity --no-sandbox
```

### ¿Por qué glibc manual y no gcompat?

| | `gcompat` | `glibc` (sgerrand) |
|--|-----------|-------------------|
| **Compatibilidad** | Parcial (solo API básica) | Completa (todas las libs de glibc) |
| **Antigravity** | ⚠️ Puede fallar con NSS/GTK | ✅ Funciona correctamente |
| **Tamaño** | ~1 MB | ~8 MB |
| **Estabilidad** | Media | Alta |

---

## ⚡ Instalación

### Requisitos previos en Termux

```bash
pkg install termux-x11-nightly pulseaudio xdpyinfo openssh -y
```

### Paso 1 — Dentro de Alpine (como root)

Copia el instalador a tu Alpine y ejecútalo:

```bash
# Desde Termux, copiar install.sh a Alpine via scp:
scp -P 2222 install.sh root@127.0.0.1:/root/

# Entrar a Alpine:
ssh -p 2222 root@127.0.0.1

# Dentro de Alpine:
sh install.sh
```

El instalador hace automáticamente:

1. Habilita el repositorio `community` de Alpine
2. Instala **glibc 2.35** real (paquete `sgerrand` ARM64) en `/usr/glibc-compat`
3. Configura el loader `ld-linux-aarch64.so.1` para que los binarios glibc lo encuentren
4. Instala `xorg-server`, `fluxbox`, `xterm` y todas las dependencias de Antigravity
5. Descarga el **binario oficial ARM64** de Antigravity vía `aria2c` (~300 MB)
6. Crea `/usr/local/bin/start-antigravity` con las variables de entorno correctas

### Paso 2 — Desde Termux (cada vez que quieras usar el IDE)

```bash
./start-gui.sh
```

Cambia a la app **Termux:X11** para ver el escritorio con Antigravity.

---

## 🖥️ Uso Diario

```bash
# Iniciar
./start-gui.sh

# Detener
./stop-gui.sh
```

### Menú de Fluxbox

Haz **clic derecho** en el escritorio para acceder al menú:

```
┌─────────────────────────┐
│ Iniciar Antigravity     │
│ Terminal                │
├─────────────────────────┤
│ Sistema                 │
│  └─ Salir               │
└─────────────────────────┘
```

---

## 📋 Scripts del Repositorio

| Script | Dónde ejecutar | Función |
|--------|---------------|---------|
| `install.sh` | **Dentro de Alpine** (root) | Instala glibc, X11, Fluxbox y Antigravity |
| `start-gui.sh` | **Termux** | Inicia X11, PulseAudio y lanza Antigravity en Alpine |
| `antigravity.sh` | **Termux** | Conecta a Alpine vía SSH/proot y lanza el IDE |
| `stop-gui.sh` | **Termux** | Detiene Antigravity, Fluxbox, X11 y PulseAudio |

---

## 📋 Requisitos

### Hardware

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| **SoC** | Snapdragon 700 / Dimensity 900 | Snapdragon 8+ Gen 1 o superior |
| **RAM** | 6 GB | 8 GB o más |
| **Almacenamiento** | 6 GB libres | 10 GB libres |
| **Pantalla** | 6.5" smartphone | 10.1" tablet |
| **Android** | 10+ | 12+ |

### Software

- [Termux](https://f-droid.org/en/packages/com.termux/) — **instalar desde F-Droid**, no desde Play Store
- [Termux:X11](https://github.com/termux/termux-x11/releases) — servidor gráfico para Android
- **QEMU** con Alpine Linux ya configurado en Termux
- `openssh` corriendo dentro de Alpine (para que `antigravity.sh` pueda conectarse)

---

## 🗂️ Estructura del Proyecto

```
termux-antigravity/
├── .github/
│   └── workflows/
│       └── shellcheck.yml
├── install.sh       # Instalador para Alpine (ejecutar dentro del contenedor)
├── start-gui.sh     # Inicio del entorno desde Termux
├── antigravity.sh   # Lanzador: Termux → Alpine vía SSH/proot
├── stop-gui.sh      # Parada limpia del entorno
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

---

## 🔧 Solución de Problemas

**`antigravity.sh` dice "No se pudo conectar a Alpine"**  
Verifica que `sshd` está corriendo dentro de Alpine:
```bash
# Dentro de Alpine:
apk add openssh
rc-service sshd start
# O si tu QEMU usa otro puerto, edita la variable QEMU_SSH_PORTS en antigravity.sh
```

**Error al instalar glibc: "trying to overwrite etc/nsswitch.conf"**  
El instalador ya usa `--force-overwrite`, pero si lo instalas manualmente:
```bash
apk add --force-overwrite glibc-2.35-r1.apk
```

**Antigravity arranca pero la ventana no aparece en Termux:X11**  
Asegúrate de que la app Termux:X11 esté abierta antes de ejecutar `./start-gui.sh`. Luego:
```bash
./stop-gui.sh && ./start-gui.sh
```

**Error de librería al iniciar Antigravity**  
El binario necesita `LD_LIBRARY_PATH` apuntando a glibc-compat. Dentro de Alpine:
```bash
export LD_LIBRARY_PATH=/usr/glibc-compat/lib:$LD_LIBRARY_PATH
start-antigravity --no-sandbox
```

**`termux-x11` no se encuentra en Termux**  
```bash
pkg install x11-repo -y && pkg install termux-x11-nightly -y
```

---

## 🛠️ Changelog

### v4.0.0 — Alpine QEMU + glibc real
- **Nuevo** instalador específico para Alpine Linux sobre QEMU en Termux.
- **Nuevo** instalación de **glibc 2.35 real** (paquete `sgerrand` ARM64) en lugar de `gcompat`, con soporte completo de NSS, GTK y librerías C++ requeridas por Antigravity.
- **Nuevo** configuración automática del loader `ld-linux-aarch64.so.1` en `/lib` y `/lib64`.
- **Nuevo** `antigravity.sh` con detección automática de Alpine vía SSH (puertos QEMU estándar) con fallback a proot.
- **Nuevo** `stop-gui.sh` envía señal de parada a Alpine vía SSH antes de cerrar X11.
- **Nuevo** menú de Fluxbox integrado con acceso directo a Antigravity y terminal.
- **Nuevo** script `/usr/local/bin/uninstall-antigravity` dentro de Alpine con opción de conservar o eliminar datos.

### v3.0.0
- Reescritura completa basada en `proot-distro` + Debian con binario oficial ARM64.

### v1.1.0
- Corrección de bug crítico heredoc `<< 'SHEOF'`.
- Eliminación de `set -e` problemático con `pkg upgrade`.

---

## 🤝 Contribuir

¿Encontraste un bug o tienes una mejora? Lee [CONTRIBUTING.md](CONTRIBUTING.md). Pull Requests bienvenidos, especialmente para:

- Soporte a versiones nuevas de Antigravity (actualización del binario ARM64)
- Configuración automática de SSH dentro de Alpine durante la instalación
- Optimización del rendimiento gráfico en gama media

---

## 🛡️ Seguridad y Ética

Este proyecto se distribuye **únicamente con fines educativos**, bajo los principios de Ciberseguridad y Hacking Ético promovidos por [I-HAKLAB](https://github.com/ivam3/i-Haklab). Consulta [SECURITY.md](SECURITY.md) para reportar vulnerabilidades.

---

## 💜 Créditos

- **[ivam3](https://github.com/ivam3)** — por sus enseñanzas y la comunidad [ivam3bycinderella](https://github.com/ivam3).
- **[sgerrand](https://github.com/sgerrand/alpine-pkg-glibc)** — por el paquete glibc para Alpine.
- **Comunidad Termux** — por mantener un ecosistema Linux increíble en Android.
- **Google** — por el [repositorio oficial de Antigravity](https://antigravity.google/download/linux).

---

<div align="center">

Desarrollado con 💜 por **[@maka0024 · kuromi04](https://github.com/kuromi04)**

</div>
