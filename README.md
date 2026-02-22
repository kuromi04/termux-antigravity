# 🌌 Termux-Antigravity
### *Google Antigravity IDE · Android · X11 Edition*

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-a855f7?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3ddc84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Termux](https://img.shields.io/badge/Termux-X11-f97316?style=for-the-badge&logo=gnometerminal&logoColor=white)](https://termux.dev/)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-22c55e?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.shellcheck.net/)

<br/>

> **Convierte tu Android en una estación de desarrollo de IA completa.**  
> Script automatizado que despliega Google Antigravity IDE con entorno gráfico X11 en Termux.

</div>

---

## ✨ ¿Qué incluye?

| Script | Función |
|--------|---------|
| `install.sh` | Instala todas las dependencias: X11, Fluxbox, PulseAudio, Node.js y el IDE |
| `start-gui.sh` | Inicia el servidor gráfico, espera que esté listo y lanza el IDE |
| `antigravity.sh` | Lanzador del IDE con fallback automático a terminal gráfica |
| `stop-gui.sh` | Detiene limpiamente todos los procesos del entorno |

---

## ⚡ Instalación Rápida

Abre **Termux** y ejecuta:

```bash
pkg install git -y && \
git clone https://github.com/kuromi04/termux-antigravity.git && \
cd termux-antigravity && \
chmod +x *.sh && \
./install.sh
```

La instalación configura automáticamente:
- Repositorios de paquetes X11 para Termux
- Servidor gráfico `termux-x11`
- Gestor de ventanas `fluxbox` con menú personalizado
- Motor de audio `pulseaudio`
- Entorno de ejecución `Node.js` y `Python`
- Google Antigravity IDE

---

## 🖥️ Cómo Usar

**Paso 1.** Instala la app [Termux:X11](https://github.com/termux/termux-x11/releases) en tu dispositivo Android.

**Paso 2.** Abre la app **Termux:X11** (déjala en segundo plano).

**Paso 3.** En **Termux**, inicia el entorno:

```bash
./start-gui.sh
```

**Paso 4.** Cambia a la app **Termux:X11** — el escritorio con el IDE ya estará corriendo.

**Paso 5.** Cuando termines, detén el entorno con:

```bash
./stop-gui.sh
```

---

## 📋 Requisitos

### Hardware Recomendado

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| **SoC** | Snapdragon 700 / Dimensity 900 | Snapdragon 8+ Gen 1 o superior |
| **RAM** | 6 GB | 8 GB o más |
| **Almacenamiento** | 4 GB libres | 8 GB libres |
| **Pantalla** | 6.5" smartphone | 10.1" tablet |
| **Android** | 10+ | 12+ |

### Software Requerido

- [Termux](https://f-droid.org/en/packages/com.termux/) — **instalar desde F-Droid**, no desde Play Store
- [Termux:X11](https://github.com/termux/termux-x11/releases) — app del servidor gráfico

---

## 🗂️ Estructura del Proyecto

```
termux-antigravity/
├── install.sh          # Instalador principal
├── start-gui.sh        # Inicio del entorno gráfico
├── stop-gui.sh         # Parada limpia del entorno
├── antigravity.sh      # Lanzador del IDE
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

---

## 🔧 Solución de Problemas

**La pantalla de Termux:X11 aparece en negro**  
Asegúrate de ejecutar `./start-gui.sh` *después* de abrir la app Termux:X11. El servidor X11 necesita que la app ya esté activa.

**Error: "Dependencia no encontrada"**  
Ejecuta `./install.sh` de nuevo. Si persiste, actualiza Termux manualmente:
```bash
pkg update && pkg upgrade
```

**Fluxbox inicia pero el IDE no abre**  
Haz clic derecho en el escritorio → selecciona **Antigravity IDE** en el menú contextual, o abre una terminal y ejecuta `./antigravity.sh` con `DISPLAY=:1` exportado.

**`termux-x11` no se encuentra**  
El paquete está en el repositorio `x11-repo`. Actívalo con:
```bash
pkg install x11-repo -y && pkg install termux-x11-nightly -y
```

---

## 🤝 Contribuir

¿Encontraste un bug o tienes una mejora? Lee [CONTRIBUTING.md](CONTRIBUTING.md) para saber cómo colaborar. Los Pull Requests son bienvenidos, especialmente en:

- Optimización del rendimiento gráfico en dispositivos de gama media
- Soporte para gestores de ventanas alternativos (Openbox, i3)
- Mejoras en la detección de hardware

---

## 🛡️ Seguridad y Ética

Este proyecto se distribuye **únicamente con fines educativos**, bajo los principios de Ciberseguridad y Hacking Ético promovidos por [I-HAKLAB](https://github.com/ivam3/i-Haklab). Consulta nuestra [política de seguridad](SECURITY.md) para reportar vulnerabilidades.

---

## 💜 Créditos

- **[ivam3](https://github.com/ivam3)** — por sus enseñanzas, scripts base y la comunidad [ivam3bycinderella](https://github.com/ivam3). Su trabajo es la inspiración directa de este proyecto.
- **Comunidad Termux** — por mantener un ecosistema Linux increíble en Android.

---

<div align="center">

Desarrollado con 💜 por **[@maka0024 · kuromi04](https://github.com/kuromi04)**

</div>
