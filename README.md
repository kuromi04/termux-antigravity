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
> Usa `termux-docker-qemu` para comunicarse con Alpine sin SSH ni contraseñas,  
> instala glibc real y lanza el IDE con interfaz gráfica X11 completa.

</div>

---

## ⚡ Instalación

Todo se hace desde **Termux**, sin entrar a Alpine manualmente.

### Paso 1 — Clonar el repositorio

```bash
pkg install git termux-x11-nightly pulseaudio xdpyinfo -y && \
git clone https://github.com/kuromi04/termux-antigravity.git && \
cd termux-antigravity && \
chmod +x *.sh
```

### Paso 2 — Instalar

```bash
./install.sh
```

El instalador se comunica con Alpine usando `termux-docker-qemu alpine sh -c "..."` y hace todo automáticamente — no pide contraseña ni requiere SSH.

### Paso 3 — Usar

```bash
./start-gui.sh
```

Cambia a la app **Termux:X11** para ver el escritorio con Antigravity.

---

## 🏗️ Arquitectura

```
Android
└── Termux
    ├── Termux:X11 ──────────────────── display :1
    ├── PulseAudio ──────────────────── audio
    ├── termux-docker-qemu ──────────── acceso a Alpine sin SSH
    └── QEMU
        └── Alpine Linux
            ├── glibc 2.35 (sgerrand) ─ compatibilidad con binarios glibc
            ├── Fluxbox               ─ gestor de ventanas
            └── /opt/antigravity/
                └── bin/antigravity --no-sandbox
```

### ¿Por qué glibc manual?

Antigravity requiere `glibc ≥ 2.28`. Alpine usa `musl libc`, que es incompatible. El paquete **sgerrand** instala glibc 2.35 completo en `/usr/glibc-compat` sin reemplazar musl, y configura el loader `ld-linux-aarch64.so.1` para que Antigravity lo encuentre automáticamente.

| | `gcompat` | `glibc` sgerrand |
|--|-----------|-----------------|
| Compatibilidad | Parcial | ✅ Completa |
| NSS / GTK / libgbm | ⚠️ Puede fallar | ✅ Funciona |
| Tamaño | ~1 MB | ~8 MB |

---

## ✨ ¿Qué hace `install.sh`?

| Paso | Acción |
|------|--------|
| 1 | Verifica que `termux-docker-qemu alpine` responde |
| 2 | Actualiza Alpine y habilita el repositorio `community` |
| 3 | Instala dependencias base (`curl`, `aria2`, `gnupg`...) |
| 4 | Instala **glibc 2.35** real (sgerrand ARM64) y configura el loader |
| 5 | Instala `xorg-server`, `fluxbox`, `xterm`, `pulseaudio` |
| 6 | Instala dependencias de Antigravity (`nss`, `gtk+3.0`, `pango`...) |
| 7 | Descarga el **binario oficial ARM64** de Antigravity vía `aria2c` (~300 MB) |
| 8 | Crea `/usr/local/bin/start-antigravity` con variables de entorno correctas |
| 9 | Configura el menú de Fluxbox |
| 10 | Crea `/usr/local/bin/uninstall-antigravity` |

---

## 🖥️ Uso Diario

```bash
# Iniciar el entorno completo
./start-gui.sh

# Detener todo limpiamente
./stop-gui.sh
```

Cambia a la app **Termux:X11** para ver el escritorio. Haz **clic derecho** para abrir el menú de Fluxbox:

```
┌─────────────────────────┐
│ Iniciar Antigravity     │
│ Terminal                │
├─────────────────────────┤
│ Sistema > Salir         │
└─────────────────────────┘
```

### Desinstalar Antigravity (desde Termux)

```bash
termux-docker-qemu alpine sh -c "uninstall-antigravity"
```

---

## 📋 Scripts del Repositorio

| Script | Función |
|--------|---------|
| `install.sh` | Instalación completa desde Termux (un solo uso) |
| `start-gui.sh` | Inicia X11, PulseAudio y lanza Antigravity en Alpine |
| `antigravity.sh` | Lanzador: ejecuta Fluxbox + Antigravity dentro de Alpine |
| `stop-gui.sh` | Detiene Antigravity, Fluxbox, X11 y PulseAudio |

Todos los scripts se ejecutan **desde Termux**. Ninguno requiere entrar a Alpine manualmente.

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
- `termux-docker-qemu` con Alpine Linux ya configurado

---

## 🗂️ Estructura del Proyecto

```
termux-antigravity/
├── .github/
│   └── workflows/
│       └── shellcheck.yml
├── install.sh        # Instalación completa desde Termux
├── start-gui.sh      # Inicio del entorno
├── antigravity.sh    # Lanzador del IDE
├── stop-gui.sh       # Parada limpia
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

---

## 🔧 Solución de Problemas

**`termux-docker-qemu` no encontrado**  
Instala o verifica que `termux-docker-qemu` está en tu PATH de Termux. Es el componente que permite comunicarse con Alpine sin SSH.

**Error: "Alpine no responde"**  
Verifica que tu instancia QEMU está corriendo:
```bash
termux-docker-qemu alpine sh -c "echo OK"
```
Si no responde, reinicia QEMU desde tu setup habitual.

**Descarga de Antigravity falla**  
El binario pesa ~300 MB. Verifica tu conexión y vuelve a ejecutar:
```bash
./install.sh
```
`aria2c` usa 4 conexiones paralelas para acelerar la descarga.

**Antigravity no aparece en Termux:X11**  
Asegúrate de abrir la app Termux:X11 antes de ejecutar `./start-gui.sh`. Luego:
```bash
./stop-gui.sh && ./start-gui.sh
```

**Error de librería al iniciar Antigravity**  
Verifica que glibc está correctamente instalado en Alpine:
```bash
termux-docker-qemu alpine sh -c "ls /usr/glibc-compat/lib/ld-linux-aarch64.so.1"
```
Si no existe, vuelve a ejecutar `./install.sh`.

---

## 🛠️ Changelog

### v5.0.0 — Sin SSH, sin contraseñas
- **Nuevo** todos los scripts usan `termux-docker-qemu alpine sh -c "..."` para comunicarse con Alpine directamente desde Termux, eliminando por completo la dependencia de SSH.
- **Eliminado** el requisito de configurar `sshd` dentro de Alpine.
- **Simplificado** `install.sh`: ya no requiere copiar archivos manualmente a Alpine.
- **Simplificado** `antigravity.sh`: un solo bloque `termux-docker-qemu` lanza Fluxbox y Antigravity.
- **Actualizado** `stop-gui.sh`: usa `termux-docker-qemu` para detener procesos dentro de Alpine.

### v4.0.0
- Migración a Alpine QEMU con glibc 2.35 real (sgerrand ARM64).
- Detección automática de Alpine vía SSH con fallback a proot.

### v3.0.0
- Reescritura completa basada en `proot-distro` + Debian.

### v1.1.0
- Corrección de bug crítico heredoc `<< 'SHEOF'`.

---

## 🤝 Contribuir

¿Encontraste un bug o tienes una mejora? Lee [CONTRIBUTING.md](CONTRIBUTING.md). Pull Requests bienvenidos, especialmente para:

- Soporte a versiones nuevas del binario ARM64 de Antigravity
- Optimización del rendimiento gráfico en gama media
- Script de actualización automática

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
