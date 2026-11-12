# Scripts para Linux Básicos

Este repositorio contiene una colección de scripts prácticos en Bash y Go para automatizar tareas comunes en entornos Linux (especialmente útiles en configuraciones de escritorio basadas en Wayland/Hyprland).

## Scripts incluidos

1. **`letraS` (Bubbletea TUI):** Muestra de forma sincronizada y fluida la letra de la canción que se esté reproduciendo actualmente en Spotify local.
2. **`despertador` (Bash):** Alarma programable para cualquier hora (por defecto las 05:00 AM) que muestra una cuenta regresiva, lanza una notificación de sistema crítica y reproduce alertas sonoras.
3. **`spotify_alarm.sh` (Bash):** Alarma inteligente para las 5:00 AM que sube el volumen del sistema y de Spotify al 100%, inicia el reproductor y arranca la música automáticamente.

---

## Dependencias de los scripts

Para que todos los scripts funcionen correctamente sin errores, necesitas instalar las siguientes herramientas del sistema:

- `playerctl` (para leer y controlar el estado del reproductor de Spotify)
- `libnotify` / `notify-send` (para lanzar notificaciones de escritorio)
- `libcanberra` (para reproducir alertas de audio a través de los temas del sistema)
- `curl` (para descargar las portadas de álbumes de Spotify)
- `jq` (para la codificación y análisis de texto en llamadas a APIs de letras y carátulas)

---

## Comando de instalación de dependencias "de golpe"

Ejecuta el comando correspondiente al gestor de paquetes de tu distribución para instalar todas las dependencias juntas:

### En Arch Linux (pacman)
```bash
sudo pacman -S --needed playerctl libnotify libcanberra curl jq
```

### En Ubuntu / Debian / Pop!_OS (apt)
```bash
sudo apt update && sudo apt install -y playerctl libnotify-bin libcanberra-gtk-module curl jq
```

### En Fedora (dnf)
```bash
sudo dnf install -y playerctl libnotify libcanberra-gtk-module curl jq
```

---

## Replicar la configuración de terminal y editor

La carpeta [`config/`](config/) contiene una copia reproducible de la configuración personal de Neovim, tmux, Zsh y Powerlevel10k.

### Contenido respaldado

| Ruta | Destino | Propósito |
| --- | --- | --- |
| `config/nvim/` | `~/.config/nvim/` | Configuración de Neovim basada en LazyVim (estilo morado oscuro) |
| `config/tmux/.tmux.conf` | `~/.tmux.conf` | Atajos, mouse, portapapeles y estilo morado oscuro de tmux |
| `config/shell/.zshrc` | `~/.zshrc` | Aliases, funciones y carga de herramientas |
| `config/shell/.p10k.zsh` | `~/.p10k.zsh` | Tema Powerlevel10k con cápsulas Azul Neón (`#0f2952` / `#38bdf8`) |
| `config/cmatrix/cmatrix-jp.c` | `~/.local/bin/cmatrix` | Matrix en japonés (Katakana) con TrueColor 24-bit Azul Neón y fondo transparente |
| `config/pipes/pipes.sh` | `~/.local/bin/pipes.sh` | `pipes.sh` configurado con paleta Azul Neón / Cian Eléctrico (`pipes`, `pipesh`) |
| `config/cava/config` | `~/.config/cava/config` | Gradiente de 8 tonos Azul Neón para CAVA |
| `config/fastfetch/` | `~/.config/fastfetch/` | Logo Unicode personalizado en cian con temperatura de CPU, GPU dedicada y RAM |
| `config/ranger/` | `~/.config/ranger/` | Administrador de archivos Ranger con tema Azul Neón (`neon`), iconos Nerd Fonts y previsualización |
| `config/terminal/windows-terminal-settings.json` | `settings.json` (Windows Terminal) | Esquema de colores y background Azul Neón (`#03122F`) con acrílico |
| `config/thefuck/settings.py` | `~/.config/thefuck/settings.py` | Ajustes de `thefuck` |

### Instalación segura

Ejecutá estos comandos desde la raíz de este repositorio. Se crea un respaldo antes de reemplazar cualquier archivo existente:

```bash
set -e

backup_dir="$HOME/.config/scripts-basicos-linux-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir" "$HOME/.config" "$HOME/.local/bin"

[ ! -e "$HOME/.config/nvim" ] || mv "$HOME/.config/nvim" "$backup_dir/"
[ ! -e "$HOME/.config/ranger" ] || mv "$HOME/.config/ranger" "$backup_dir/"
[ ! -e "$HOME/.tmux.conf" ] || mv "$HOME/.tmux.conf" "$backup_dir/"
[ ! -e "$HOME/.zshrc" ] || mv "$HOME/.zshrc" "$backup_dir/"
[ ! -e "$HOME/.p10k.zsh" ] || mv "$HOME/.p10k.zsh" "$backup_dir/"

cp -a config/nvim "$HOME/.config/"
cp -a config/ranger "$HOME/.config/"
cp config/tmux/.tmux.conf "$HOME/.tmux.conf"
cp config/shell/.zshrc "$HOME/.zshrc"
cp config/shell/.p10k.zsh "$HOME/.p10k.zsh"
mkdir -p "$HOME/.config/thefuck" "$HOME/.config/cava"
cp config/thefuck/settings.py "$HOME/.config/thefuck/settings.py"
cp config/cava/config "$HOME/.config/cava/config"
gcc -O2 -Wall -Wextra -o "$HOME/.local/bin/cmatrix" config/cmatrix/cmatrix-jp.c
install -m 755 config/pipes/pipes.sh "$HOME/.local/bin/pipes.sh"
ln -sf "$HOME/.local/bin/pipes.sh" "$HOME/.local/bin/pipes"
ln -sf "$HOME/.local/bin/pipes.sh" "$HOME/.local/bin/pipesh"
```

Después, recargá Zsh y validá Powerlevel10k:

```bash
zsh -n "$HOME/.zshrc"
zsh -n "$HOME/.p10k.zsh"
source "$HOME/.zshrc"
```

### Fastfetch con logo personalizado

Requiere `fastfetch` (configuración validada con la versión 2.68.1). Para instalar solo este perfil, desde la raíz del repositorio:

```bash
if [ -e "$HOME/.config/fastfetch" ]; then
  cp -a "$HOME/.config/fastfetch" "$HOME/.config/fastfetch.backup-$(date +%Y%m%d-%H%M%S-%N)"
fi
mkdir -p "$HOME/.config/fastfetch"
cp config/fastfetch/config.jsonc config/fastfetch/logo.txt "$HOME/.config/fastfetch/"
fastfetch
```

El logo conserva el dibujo Unicode completo. Debajo solo muestra la temperatura de la CPU, la GPU dedicada con su temperatura y una barra de RAM; las GPU integradas se omiten.

### Herramientas usadas por los aliases

El `.zshrc` configura, entre otros:

- `nv`: alias corto de `nvim` (misma configuración).
- `thefuck`: genera su alias automáticamente cuando está instalado.
- `ranger` (alias `r` y `ra` con cambio automático de directorio al salir).
- `zoxide`, `eza`, `fzf`, `Powerlevel10k` y `zsh-syntax-highlighting`.

#### `ranger` (Administrador de archivos)

Ranger incluye configuración en `config/ranger/` con tema Azul Neón (`neon`), bordes completos, previsualización de imágenes integrada con Kitty y soporte para iconos Nerd Fonts (`ranger_devicons`).

Instalación con `pipx`:

```bash
pipx install ranger-fm
pipx inject ranger-fm pillow
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
```

Al iniciar Zsh, se cargan la función `r` y el alias `ra` para navegar y conservar la carpeta seleccionada al salir.

#### `thefuck` y el comando `fuck`

`thefuck` es una herramienta externa que debe estar instalada en la máquina. Su configuración se respalda en `config/thefuck/settings.py`. Al iniciar Zsh, `config/shell/.zshrc` ejecuta `thefuck --alias` y genera la función interactiva `fuck`.

Verificá la instalación con:

```bash
command -v thefuck
thefuck --alias
command -v fuck
```

Si falta, instalalo con el método recomendado por tu distribución o mediante `pipx`:

```bash
pipx install thefuck
```

Después recargá la shell:

```bash
source ~/.zshrc
```

Instalá únicamente las herramientas que quieras usar. Si una no está instalada, eliminá su bloque del `.zshrc` o instalala con el gestor de paquetes de tu distribución.

> **Seguridad:** revisá el contenido antes de copiarlo a otra máquina. No agregues tokens, claves SSH, contraseñas ni archivos `.env` a este repositorio.

### Notas para agentes

1. No reemplazar configuraciones existentes sin crear primero un respaldo.
2. No copiar cachés, `__pycache__`, diccionarios generados de Vim, respaldos automáticos, estados de plugins ni credenciales.
3. Hay una sola configuración de Neovim en `~/.config/nvim`; `nv` y `nvim` son lo mismo.
4. Verificar la sintaxis con `zsh -n` después de modificar `.zshrc` o `.p10k.zsh`.
5. Si se agrega una nueva herramienta, documentar su dependencia y el comando de instalación en esta sección.
