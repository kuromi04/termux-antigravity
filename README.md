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

Al terminar, el menú principal se abre **automáticamente**.

---

## 🖥️ Menú interactivo

Después de instalar, abre el menú con:

```bash
./antigravity.sh
```

```
  ╔═══════════════════════════════════════════════╗
  ║                                               ║
  ║   🌌  Google Antigravity IDE                  ║
  ║   Termux · Debian · Android · ARM64           ║
  ║                                               ║
  ╠═══════════════════════════════════════════════╣
  ║  Autor   @maka0024 · kuromi04                 ║
  ║  GitHub  kuromi04/termux-antigravity          ║
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

**1 ▶ Iniciar** — entra a Debian como `devroom` y lanza Antigravity IDE con X11, Fluxbox y Thunar.

**2 ↻ Actualizar** — descarga la nueva versión del binario ARM64, hace backup de tus scripts y configuración, reemplaza solo el binario y restaura todo lo demás.

**3 ■ Detener y limpiar** — tres niveles: solo matar procesos / + limpiar logs / + limpiar logs y caché completa.

**4 ⚙ Terminal Debian** — acceso directo a Debian como root para administración.

**5 ✕ Desinstalar** — dos modos (conservar datos / eliminar todo) con confirmación obligatoria.

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

- [Termux](https://f-droid.org/en/packages/com.termux/) — **desde F-Droid**, no desde Play Store
- [Termux:X11](https://github.com/termux/termux-x11/releases) — servidor gráfico para Android

---

## 🗂️ Estructura del repositorio

```
termux-antigravity/
├── .github/
│   └── workflows/
│       └── shellcheck.yml
├── antigravity.sh          ← menú interactivo principal
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

> `installantigravity.sh` **no está en el repositorio** — se descarga directamente con `curl`
> al instalarlo y se borra al terminar. El menú `antigravity.sh` sí queda en tu HOME de Termux.

---

## 🔧 Solución de Problemas

**Pantalla negra en Termux:X11**
Abre la app Termux:X11 manualmente antes de elegir "Iniciar".

**Error al descargar Antigravity**
El binario pesa ~300 MB. Verifica tu conexión y ejecuta de nuevo el instalador.

**El menú no se abre al terminar la instalación**
Ejecuta manualmente: `./antigravity.sh`

**Debian no arranca**
```bash
proot-distro list
proot-distro install debian   # si no aparece
```

---

## 🤝 Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md). Pull Requests bienvenidos para actualización del binario ARM64 y mejoras en el menú.

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
