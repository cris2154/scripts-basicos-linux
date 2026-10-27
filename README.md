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
| `config/nvim-gentleman/` | `~/.config/nvim-gentleman/` | Perfil aislado de Neovim basado en LazyVim |
| `config/tmux/.tmux.conf` | `~/.tmux.conf` | Atajos, mouse, portapapeles y estilo de tmux |
| `config/shell/.zshrc` | `~/.zshrc` | Aliases, funciones y carga de herramientas |
| `config/shell/.p10k.zsh` | `~/.p10k.zsh` | Tema Powerlevel10k; la ruta del prompt usa color blanco |

### Instalación segura

Ejecutá estos comandos desde la raíz de este repositorio. Se crea un respaldo antes de reemplazar cualquier archivo existente:

```bash
set -e

backup_dir="$HOME/.config/scripts-basicos-linux-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir" "$HOME/.config"

[ ! -e "$HOME/.config/nvim-gentleman" ] || mv "$HOME/.config/nvim-gentleman" "$backup_dir/"
[ ! -e "$HOME/.tmux.conf" ] || mv "$HOME/.tmux.conf" "$backup_dir/"
[ ! -e "$HOME/.zshrc" ] || mv "$HOME/.zshrc" "$backup_dir/"
[ ! -e "$HOME/.p10k.zsh" ] || mv "$HOME/.p10k.zsh" "$backup_dir/"

cp -a config/nvim-gentleman "$HOME/.config/"
cp config/tmux/.tmux.conf "$HOME/.tmux.conf"
cp config/shell/.zshrc "$HOME/.zshrc"
cp config/shell/.p10k.zsh "$HOME/.p10k.zsh"
```

Después, recargá Zsh y validá Powerlevel10k:

```bash
zsh -n "$HOME/.zshrc"
zsh -n "$HOME/.p10k.zsh"
source "$HOME/.zshrc"
```

### Herramientas usadas por los aliases

El `.zshrc` configura, entre otros:

- `nv`: abre Neovim con el perfil `nvim-gentleman`.
- `thefuck`: genera su alias automáticamente cuando está instalado.
- `yazi`, `zoxide`, `eza`, `fzf`, `Powerlevel10k` y `zsh-syntax-highlighting`.

Instalá únicamente las herramientas que quieras usar. Si una no está instalada, eliminá su bloque del `.zshrc` o instalala con el gestor de paquetes de tu distribución.

> **Seguridad:** revisá el contenido antes de copiarlo a otra máquina. No agregues tokens, claves SSH, contraseñas ni archivos `.env` a este repositorio.

### Notas para agentes

1. No reemplazar configuraciones existentes sin crear primero un respaldo.
2. No copiar cachés, `__pycache__`, diccionarios generados de Vim, respaldos automáticos, estados de plugins ni credenciales.
3. Mantener `nvim-gentleman` como perfil separado; no mezclarlo con `~/.config/nvim`.
4. Verificar la sintaxis con `zsh -n` después de modificar `.zshrc` o `.p10k.zsh`.
5. Si se agrega una nueva herramienta, documentar su dependencia y el comando de instalación en esta sección.
