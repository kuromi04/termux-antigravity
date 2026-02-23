# 🌌 Termux-Antigravity
### *Google Antigravity IDE · Termux · Debian · X11*

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-a855f7?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3ddc84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Distro](https://img.shields.io/badge/Distro-Debian-a80030?style=for-the-badge&logo=debian&logoColor=white)](https://www.debian.org)
[![Termux](https://img.shields.io/badge/Termux-X11-f97316?style=for-the-badge&logo=gnometerminal&logoColor=white)](https://termux.dev/)
[![ShellCheck](https://img.shields.io/github/actions/workflow/status/kuromi04/termux-antigravity/shellcheck.yml?label=ShellCheck&style=for-the-badge&logo=gnubash&logoColor=white)](https://github.com/kuromi04/termux-antigravity/actions)

<br/>

> **Instala Google Antigravity IDE en Android con un solo comando.**  
> Corre Debian dentro de Termux con `proot-distro`, descarga el binario oficial ARM64 y lanza el IDE con interfaz gráfica X11.

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

## 🏗️ Cómo funciona

```
Termux
├── proot-distro
│   └── Debian
│       ├── fluxbox + thunar        ← escritorio gráfico
│       ├── usuario devroom         ← entorno aislado
│       └── /Apps/IDE/Antigravity/
│           └── bin/antigravity --no-sandbox
└── Termux:X11 ← display :1 (interfaz gráfica en Android)
```

El instalador hace todo en orden:

| Paso | Qué ocurre |
|------|-----------|
| 1 | Verifica permisos de almacenamiento |
| 2 | Instala `proot-distro`, `aria2`, `termux-x11` en Termux |
| 3 | Instala **Debian** vía `proot-distro` |
| 4 | Descarga el **binario oficial ARM64** de Antigravity (~300 MB) vía `aria2c` |
| 5 | Extrae Antigravity en `/Apps/IDE/Antigravity/` dentro de Debian |
| 6 | Al primer login en Debian instala `fluxbox`, `thunar`, `firefox-esr` y todas las dependencias |
| 7 | Crea el usuario `devroom` sin contraseña con permisos sudo |
| 8 | Genera los scripts `antigravity.sh`, `startantigravity.sh` y `uninstall.sh` |

---

## 🖥️ Uso diario

Una vez instalado, para abrir Antigravity ejecuta desde **Termux**:

```bash
./antigravity.sh
```

Esto entra a Debian como `devroom` y muestra el menú:

```
--------------------
¿Qué quieres hacer con Google Antigravity?
--------------------
1. Iniciar Antigravity
2. Desinstalar
Otro. Salir y usar Debian
--------------------
```

Al elegir **1**, se abre la app **Termux:X11** automáticamente con el escritorio Fluxbox y Antigravity IDE.

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

## 🗂️ Archivos del repositorio

```
termux-antigravity/
├── .github/
│   └── workflows/
│       └── shellcheck.yml
├── installantigravity.sh   ← instalador completo (un solo uso)
├── antigravity.sh          ← lanzador diario
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

---

## 🔧 Solución de Problemas

**La pantalla de Termux:X11 aparece en negro**  
Abre la app **Termux:X11** manualmente antes de elegir "Iniciar" en el menú.

**Error al descargar Antigravity**  
El binario pesa ~300 MB. Si la descarga falla, vuelve a ejecutar el instalador. `aria2c` usa 4 conexiones paralelas para mayor velocidad.

**"Antigravity no está instalado" al ejecutar `./antigravity.sh`**  
La instalación no completó. Vuelve a ejecutar el comando de instalación completo.

**Debian no arranca**  
```bash
proot-distro list
# Si debian no aparece:
proot-distro install debian
```

---

## 🤝 Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md). Pull Requests bienvenidos, especialmente para:

- Actualización del binario ARM64 de Antigravity a versiones nuevas
- Soporte para otras distribuciones (Ubuntu, Alpine)
- Mejoras en el menú interactivo

---

## 🛡️ Seguridad y Ética

Distribuido **únicamente con fines educativos**, bajo los principios de Hacking Ético de [I-HAKLAB](https://github.com/ivam3/i-Haklab). Consulta [SECURITY.md](SECURITY.md) para reportar vulnerabilidades.

---

## 💜 Créditos

- **[ivam3](https://github.com/ivam3)** — por sus enseñanzas y la comunidad [ivam3bycinderella](https://github.com/ivam3).
- **[AnBui2004](https://github.com/AnBui2004)** — por el instalador de referencia.
- **Comunidad Termux** — por mantener un ecosistema Linux increíble en Android.

---

<div align="center">

Desarrollado con 💜 por **[@maka0024 · kuromi04](https://github.com/kuromi04)**

</div>
