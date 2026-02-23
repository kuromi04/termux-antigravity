# 🌌 Termux-Antigravity
### *Google Antigravity IDE · Termux · Debian · X11*

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-a855f7?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3ddc84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Distro](https://img.shields.io/badge/Distro-Debian-a80030?style=for-the-badge&logo=debian&logoColor=white)](https://www.debian.org)
[![Termux](https://img.shields.io/badge/Termux-X11-f97316?style=for-the-badge&logo=gnometerminal&logoColor=white)](https://termux.dev/)
[![ShellCheck](https://img.shields.io/github/actions/workflow/status/kuromi04/termux-antigravity/shellcheck.yml?label=ShellCheck&style=for-the-badge&logo=gnubash&logoColor=white)](https://github.com/kuromi04/termux-antigravity/actions)

<br/>

> **Google Antigravity IDE en Android con un solo comando.**  
> Corre Debian dentro de Termux vía `proot-distro`, descarga el binario oficial ARM64  
> y gestiona todo desde un menú interactivo profesional.

</div>

---

## ⚡ Instalación — Un solo comando

Abre **Termux** y pega esto:

```bash
curl -H 'Cache-Control: no-cache' -o installantigravity.sh \
  https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/installantigravity.sh \
  && chmod +rwx installantigravity.sh \
  && ./installantigravity.sh \
  && rm installantigravity.sh \
  && clear
```

---

## 🖥️ Menú interactivo

Después de instalar, todo se gestiona desde un solo comando:

```bash
./antigravity.sh
```

El menú muestra:

```
  ╔═══════════════════════════════════════════════╗
  ║                                               ║
  ║   🌌  Google Antigravity IDE                  ║
  ║   Termux · Debian · Android · ARM64           ║
  ║                                               ║
  ╠═══════════════════════════════════════════════╣
  ║  Autor   @maka0024 · kuromi04                 ║
  ║  GitHub  kuromi04/termux-antigravity          ║
  ║  Versión 1.16.5                               ║
  ║  Estado  ● Instalado                          ║
  ╚═══════════════════════════════════════════════╝

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    MENÚ PRINCIPAL
  ─────────────────────────────────────────────────

    1  ▶  Iniciar Antigravity
    2  ↻  Actualizar Antigravity
    3  ■  Detener y limpiar sesión
    4  ⚙  Abrir Debian (terminal)
    5  ✕  Desinstalar Antigravity

  ─────────────────────────────────────────────────
    0  Salir
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## ✨ Funciones del menú

### 1 ▶ Iniciar Antigravity
Entra a Debian como `devroom` y lanza el IDE. Abre la app **Termux:X11** automáticamente con `fluxbox` + `thunar` + Antigravity.

### 2 ↻ Actualizar Antigravity
Descarga la última versión del binario ARM64 desde los servidores de Google, reemplaza el binario existente y restaura automáticamente tu configuración de usuario, scripts personalizados y datos de sesión.

### 3 ■ Detener y limpiar sesión
Tres niveles de limpieza:
- **Solo detener** — mata los procesos de Antigravity, Fluxbox, X11 y la sesión proot de Debian.
- **Detener + limpiar logs** — además elimina los logs de sesión de Debian y Termux.
- **Detener + limpiar logs + caché** — limpieza completa incluyendo la caché de Antigravity.

### 4 ⚙ Abrir Debian (terminal)
Acceso directo a la terminal de Debian como root para tareas de administración.

### 5 ✕ Desinstalar Antigravity
Dos modos:
- **Conservar datos** — elimina el binario y scripts pero conserva la configuración del usuario.
- **Eliminar todo** — limpieza completa: binario, scripts, datos, logs y caché. Pide confirmación antes de proceder.

---

## 🏗️ Cómo funciona

```
Termux
├── proot-distro
│   └── Debian
│       ├── fluxbox + thunar        ← escritorio gráfico
│       ├── usuario devroom         ← entorno aislado
│       └── /Apps/IDE/Antigravity/
│           └── bin/antigravity --no-sandbox
└── Termux:X11 ← display :1
```

---

## 📋 Requisitos

### Hardware

| Componente | Mínimo | Recomendado |
|------------|--------|-------------|
| **SoC** | Snapdragon 700 / Dimensity 900 | Snapdragon 8+ Gen 1 o superior |
| **RAM** | 6 GB | 8 GB o más |
| **Almacenamiento** | 4 GB libres | 8 GB libres |
| **Pantalla** | 6.5" smartphone | 10.1" tablet |
| **Android** | 10+ | 12+ |

### Software

- [Termux](https://f-droid.org/en/packages/com.termux/) — **instalar desde F-Droid**, no desde Play Store
- [Termux:X11](https://github.com/termux/termux-x11/releases) — app del servidor gráfico

---

## 🗂️ Archivos

```
termux-antigravity/
├── .github/
│   └── workflows/
│       └── shellcheck.yml
├── installantigravity.sh   ← instalador completo (un solo uso)
├── antigravity.sh          ← menú interactivo principal
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

---

## 🔧 Solución de Problemas

**Pantalla negra en Termux:X11**  
Abre la app Termux:X11 manualmente antes de elegir "Iniciar" en el menú.

**Error al actualizar / descargar**  
Verifica tu conexión. El binario pesa ~300 MB. Usa la opción 2 del menú para reintentar.

**"Antigravity no está instalado"**  
Ejecuta el comando de instalación completo desde la sección ⚡.

**Debian no arranca**  
```bash
proot-distro list
proot-distro install debian   # si no aparece en la lista
```

---

## 🤝 Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md). Pull Requests bienvenidos para:
- Actualización del binario ARM64 a versiones nuevas
- Mejoras en el menú interactivo
- Soporte para otras distribuciones

---

## 🛡️ Seguridad y Ética

Distribuido **únicamente con fines educativos**, bajo los principios de Hacking Ético de [I-HAKLAB](https://github.com/ivam3/i-Haklab).

---

## 💜 Créditos

- **[ivam3](https://github.com/ivam3)** — por sus enseñanzas y la comunidad [ivam3bycinderella](https://github.com/ivam3).
- **[AnBui2004](https://github.com/AnBui2004)** — por el instalador de referencia.
- **Comunidad Termux** — por mantener un ecosistema Linux increíble en Android.

---

<div align="center">

Desarrollado con 💜 por **[@maka0024 · kuromi04](https://github.com/kuromi04)**

</div>
