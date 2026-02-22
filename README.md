# 🌌 Termux-Antigravity
### *Google Antigravity IDE · Alpine Linux · X11 Edition*

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-a855f7?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3ddc84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Alpine](https://img.shields.io/badge/Distro-Alpine_Linux-0d597f?style=for-the-badge&logo=alpinelinux&logoColor=white)](https://alpinelinux.org)
[![Termux](https://img.shields.io/badge/Termux-X11-f97316?style=for-the-badge&logo=gnometerminal&logoColor=white)](https://termux.dev/)
[![ShellCheck](https://img.shields.io/github/actions/workflow/status/kuromi04/termux-antigravity/shellcheck.yml?label=ShellCheck&style=for-the-badge&logo=gnubash&logoColor=white)](https://github.com/kuromi04/termux-antigravity/actions)

<br/>

> **Convierte tu Android en una estación de desarrollo con Google Antigravity IDE.**  
> Despliega Antigravity sobre Alpine Linux (Docker/QEMU en Termux) con entorno gráfico X11 completo.

</div>

---

## 🏗️ Arquitectura

```
Android
└── Termux
    ├── Termux:X11  ← servidor gráfico (display :1)
    ├── PulseAudio  ← audio
    ├── start-gui.sh / antigravity.sh  ← orquestación
    └── Docker / QEMU / proot
        └── Alpine Linux
            ├── gcompat + libstdc++  ← compatibilidad glibc
            ├── Fluxbox              ← gestor de ventanas
            └── Google Antigravity  ← IDE (repo oficial Google)
```

> **¿Por qué Alpine?** Es la distro más ligera disponible en Termux Docker/QEMU.  
> **¿Por qué gcompat?** Antigravity requiere glibc ≥ 2.28, pero Alpine usa musl libc. `gcompat` provee la capa de compatibilidad necesaria.

---

## ✨ ¿Qué incluye?

| Script | Dónde se ejecuta | Función |
|--------|-----------------|---------|
| `install.sh` | **Dentro de Alpine** (como root) | Instala gcompat, X11, Fluxbox, el repo oficial de Google y Antigravity |
| `start-gui.sh` | **Termux** | Inicia Termux:X11 y PulseAudio, luego lanza `antigravity.sh` |
| `antigravity.sh` | **Termux** | Detecta Docker / proot / chroot y lanza Antigravity dentro de Alpine con `DISPLAY=:1` |
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
- Alpine Linux corriendo dentro de Termux vía **Docker**, **QEMU** o **proot**

---

## ⚡ Instalación

### Paso 1 — Preparar Termux

Instala las dependencias del lado de Termux:

```bash
pkg install termux-x11-nightly pulseaudio xdpyinfo git -y
```

Clona el repositorio:

```bash
git clone https://github.com/kuromi04/termux-antigravity.git
cd termux-antigravity
chmod +x *.sh
```

### Paso 2 — Instalar dentro de Alpine

Entra a tu contenedor Alpine y ejecuta el instalador como root:

```bash
# Si usas Docker:
docker exec -it <nombre-contenedor> sh
# Si usas proot/QEMU:
# entra a tu Alpine normalmente

# Dentro de Alpine:
cd /ruta/a/termux-antigravity
sh install.sh
```

El instalador hace automáticamente:

1. Actualiza repositorios de Alpine y habilita `community`
2. Instala `gcompat + libgcc + libstdc++` para compatibilidad con binarios glibc
3. Instala el entorno gráfico: `xorg-server`, `xdpyinfo`, `xterm`, `fluxbox`
4. Instala `pulseaudio` para audio
5. Agrega el **repositorio oficial de Google Antigravity** con su clave GPG
6. Instala Antigravity vía `apt-get`
7. Crea el script `/usr/local/bin/start-antigravity` con las flags necesarias

---

## 🖥️ Uso Diario

Una vez instalado, el flujo es siempre desde **Termux**:

**1.** Abre la app **Termux:X11** en tu dispositivo (déjala en segundo plano).

**2.** En Termux, ejecuta:

```bash
./start-gui.sh
```

**3.** Cambia a la app **Termux:X11** — verás el escritorio Fluxbox con Antigravity abierto.

**4.** Al terminar:

```bash
./stop-gui.sh
```

### Acceso al menú de Fluxbox

Haz **clic derecho** en el escritorio para abrir el menú contextual con acceso rápido a la terminal y al IDE.

---

## 🗂️ Estructura del Proyecto

```
termux-antigravity/
├── .github/
│   └── workflows/
│       └── shellcheck.yml  # CI con ShellCheck (actions/checkout@v4)
├── install.sh              # Instalador para Alpine Linux (ejecutar dentro del contenedor)
├── start-gui.sh            # Inicio del entorno desde Termux
├── stop-gui.sh             # Parada limpia del entorno
├── antigravity.sh          # Lanzador inteligente (Docker / proot / chroot)
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

---

## 🔧 Solución de Problemas

**La pantalla de Termux:X11 aparece en negro**  
Asegúrate de abrir la app Termux:X11 *antes* de ejecutar `./start-gui.sh`. El servidor necesita estar activo primero.

**Error: "Dependencia no encontrada" al ejecutar `start-gui.sh`**  
Instala las dependencias en Termux:
```bash
pkg install termux-x11-nightly pulseaudio xdpyinfo -y
```

**Antigravity abre pero muestra error de librerías**  
Dentro de Alpine, verifica que gcompat esté instalado:
```bash
apk add gcompat libgcc libstdc++
```

**Error: "No se detectó ningún método válido" en `antigravity.sh`**  
El script busca Docker, proot y chroot en ese orden. Verifica que tu contenedor Alpine esté corriendo:
```bash
# Docker:
docker ps
# proot: verifica que el directorio ~/alpine (o similar) exista y tenga /etc/alpine-release
```

**Antigravity no arranca dentro del contenedor**  
Usa siempre el flag `--no-sandbox`. En entornos sin namespaces completos (Docker/QEMU sobre Android) es obligatorio:
```bash
antigravity --no-sandbox
```

**`termux-x11` no se encuentra**  
```bash
pkg install x11-repo -y && pkg install termux-x11-nightly -y
```

---

## 🛠️ Cambios Recientes

### v2.0.0 — Migración a Alpine Linux
- **Nuevo** soporte oficial para Alpine Linux dentro de Termux Docker/QEMU.
- **Nuevo** `install.sh` completamente reescrito para Alpine: usa `apk`, instala `gcompat` para compatibilidad glibc, configura el repositorio Debian oficial de Google con clave GPG y usa `apt-get` para instalar Antigravity.
- **Nuevo** `antigravity.sh` con detección automática del método de virtualización: Docker → proot → chroot.
- **Nuevo** script `/usr/local/bin/start-antigravity` creado en Alpine con `--no-sandbox` preconfigurado.
- **Corregido** `stop-gui.sh`: ahora también detiene Antigravity dentro del contenedor Docker si está activo.

### v1.1.0
- Corregido bug crítico de heredoc `<< 'SHEOF'` que impedía expansión de `$PREFIX`.
- Eliminado `set -e` que abortaba la instalación si `pkg upgrade` no encontraba actualizaciones.
- Corregido `antigravity.sh`: eliminado `&` del fallback xterm para que el proceso bloquee correctamente.
- Añadido `xorg-xdpyinfo` como dependencia instalada.
- Actualizado workflow ShellCheck a `actions/checkout@v4` y `ludeeus/action-shellcheck@2.0.0`.

---

## 🤝 Contribuir

¿Encontraste un bug o tienes una mejora? Lee [CONTRIBUTING.md](CONTRIBUTING.md). Los Pull Requests son bienvenidos, especialmente en:

- Soporte para otras distribuciones dentro de Docker/QEMU (Debian, Ubuntu)
- Optimización del rendimiento gráfico en gama media
- Soporte para gestores de ventanas alternativos (Openbox, i3)

---

## 🛡️ Seguridad y Ética

Este proyecto se distribuye **únicamente con fines educativos**, bajo los principios de Ciberseguridad y Hacking Ético promovidos por [I-HAKLAB](https://github.com/ivam3/i-Haklab). Consulta nuestra [política de seguridad](SECURITY.md) para reportar vulnerabilidades.

---

## 💜 Créditos

- **[ivam3](https://github.com/ivam3)** — por sus enseñanzas, scripts base y la comunidad [ivam3bycinderella](https://github.com/ivam3). Su trabajo es la inspiración directa de este proyecto.
- **Comunidad Termux** — por mantener un ecosistema Linux increíble en Android.
- **Google** — por el [repositorio oficial de Antigravity](https://antigravity.google/download/linux).

---

<div align="center">

Desarrollado con 💜 por **[@maka0024 · kuromi04](https://github.com/kuromi04)**

</div>
