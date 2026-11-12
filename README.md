# Scripts básicos Linux

Configuración personal de terminal y editor para Fedora: Zsh con
Powerlevel10k, tmux, kitty, Neovim (LazyVim), ranger, fastfetch, cava y
utilidades. Todo con un mismo tema morado oscuro sobre fondo transparente.

Sirve tanto para una instalación nueva de Fedora como para una máquina que
ya tiene configuración: los pasos crean respaldo antes de reemplazar nada.

## Qué incluye

| Ruta en el repo | Destino | Qué es |
| --- | --- | --- |
| `config/shell/.zshrc` | `~/.zshrc` | Aliases, fzf, zoxide, eza, gestor de ramas `gbm` (Ctrl+G), arranque automático de tmux |
| `config/shell/.p10k.zsh` | `~/.p10k.zsh` | Tema Powerlevel10k con cápsulas |
| `config/tmux/.tmux.conf` | `~/.tmux.conf` | Atajos sin prefijo, gestor de sesiones (Ctrl+q), ratón, portapapeles, barra de dos filas. Detalle en [`config/tmux/README.md`](config/tmux/README.md) |
| `config/tmux/bin/wl-copy`, `wl-paste` | `~/.local/bin/` | Reemplazo de `wl-copy`/`wl-paste` con `xclip` para evitar el aviso de portapapeles de GNOME Wayland |
| `config/terminal/kitty.conf` | `~/.config/kitty/kitty.conf` | Fuente MesloLGS NF, transparencia, cursor con estela, colores |
| `config/nvim/` | `~/.config/nvim/` | Neovim con LazyVim. `nv` es alias de `nvim`; hay una sola configuración |
| `config/ranger/` | `~/.config/ranger/` | ranger con previsualización de imágenes en kitty, iconos Nerd Font y tema `neon` |
| `config/fastfetch/` | `~/.config/fastfetch/` | Logo propio con temperatura de CPU, GPU dedicada y RAM |
| `config/cava/config` | `~/.config/cava/config` | Gradiente de 8 tonos para cava |
| `config/thefuck/settings.py` | `~/.config/thefuck/settings.py` | Ajustes de `thefuck` |
| `config/cmatrix/cmatrix-jp.c` | `~/.local/bin/cmatrix` | Matrix en katakana, TrueColor y fondo transparente (se compila con gcc) |
| `config/pipes/pipes.sh` | `~/.local/bin/pipes.sh` | pipes.sh con paleta propia (`pipes`, `pipesh`) |
| `config/terminal/windows-terminal-settings.json` | Windows Terminal | Esquema de colores para usar desde Windows (no aplica en Fedora) |

## Instalación en Fedora

Ejecuta los pasos en orden, desde la raíz del repositorio. Todos los bloques
se pueden repetir sin romper nada.

```bash
git clone git@github.com:cris2154/scripts-basicos-linux.git ~/repos/scripts-basicos-linux
cd ~/repos/scripts-basicos-linux
```

### 1. Paquetes del sistema (dnf)

```bash
sudo dnf install -y \
  zsh tmux kitty neovim git curl wget unzip jq \
  gcc make python3-pip pipx nodejs npm tree-sitter-cli \
  fzf fd-find ripgrep bat eza zoxide thefuck \
  wl-clipboard xclip xsel \
  fastfetch cava btop \
  ImageMagick poppler-utils \
  playerctl mpv yt-dlp libnotify libcanberra \
  lazygit gh
```

Si `lazygit` no aparece en tu versión de Fedora, está en COPR:

```bash
sudo dnf copr enable -y atim/lazygit && sudo dnf install -y lazygit
```

Opcionales para que ranger previsualice más formatos (vídeo, audio, archivos
comprimidos, documentos de oficina):

```bash
sudo dnf install -y ffmpegthumbnailer mediainfo atool p7zip highlight perl-Image-ExifTool w3m-img catdoc odt2txt
```

### 2. Herramientas que no están en dnf

Fuente MesloLGS NF (la usan kitty, p10k y los iconos de tmux y Neovim):

```bash
mkdir -p ~/.local/share/fonts
for f in Regular Bold Italic "Bold Italic"; do
  curl -fLo ~/.local/share/fonts/"MesloLGS NF $f.ttf" \
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${f// /%20}.ttf"
done
fc-cache -f
```

Powerlevel10k y plugins de Zsh (se clonan en las rutas que `.zshrc` espera):

```bash
[ -d ~/powerlevel10k ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
mkdir -p ~/.zsh
[ -d ~/.zsh/zsh-autosuggestions ]     || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
[ -d ~/.zsh/zsh-syntax-highlighting ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
[ -d ~/.zsh/fzf-tab ]                 || git clone --depth=1 https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab
```

ranger con pipx (queda en `~/.local/bin/ranger`):

```bash
pipx install ranger-fm
pipx inject ranger-fm pillow
```

keifu (gestor de git en terminal, alias `kg`) via Homebrew para Linux. Si no
lo quieres, omite este bloque; `.zshrc` lo ignora cuando no existe:

```bash
[ -x ~/.linuxbrew/bin/brew ] || git clone https://github.com/Homebrew/brew ~/.linuxbrew
eval "$(~/.linuxbrew/bin/brew shellenv)"
brew install keifu
```

### 3. Copiar la configuración (con respaldo)

Mueve lo que ya exista a una carpeta de respaldo y copia los archivos del
repo. En una instalación nueva simplemente no hay nada que respaldar.

```bash
set -e
cd ~/repos/scripts-basicos-linux

backup_dir="$HOME/.config/scripts-basicos-linux-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir" ~/.config ~/.local/bin

respaldar() { [ ! -e "$1" ] || mv "$1" "$backup_dir/"; }
respaldar ~/.zshrc
respaldar ~/.p10k.zsh
respaldar ~/.tmux.conf
respaldar ~/.config/kitty/kitty.conf
respaldar ~/.config/nvim
respaldar ~/.config/ranger
respaldar ~/.config/fastfetch
respaldar ~/.config/cava/config
respaldar ~/.config/thefuck/settings.py

cp config/shell/.zshrc ~/.zshrc
cp config/shell/.p10k.zsh ~/.p10k.zsh
cp config/tmux/.tmux.conf ~/.tmux.conf
install -m 755 config/tmux/bin/wl-copy config/tmux/bin/wl-paste ~/.local/bin/
mkdir -p ~/.config/kitty ~/.config/cava ~/.config/thefuck ~/.config/fastfetch
cp config/terminal/kitty.conf ~/.config/kitty/kitty.conf
cp -a config/nvim ~/.config/nvim
cp -a config/ranger ~/.config/ranger
cp config/fastfetch/config.jsonc config/fastfetch/logo.txt ~/.config/fastfetch/
cp config/cava/config ~/.config/cava/config
cp config/thefuck/settings.py ~/.config/thefuck/settings.py
gcc -O2 -Wall -Wextra -o ~/.local/bin/cmatrix config/cmatrix/cmatrix-jp.c
install -m 755 config/pipes/pipes.sh ~/.local/bin/pipes.sh
ln -sf ~/.local/bin/pipes.sh ~/.local/bin/pipes
ln -sf ~/.local/bin/pipes.sh ~/.local/bin/pipesh

echo "Respaldo en: $backup_dir"
```

Si quieres volver atrás, copia de vuelta lo que hay en `$backup_dir`.

### 4. Zsh como shell por defecto y recarga del PATH

```bash
sudo usermod -s /usr/bin/zsh "$USER"
zsh -n ~/.zshrc && zsh -n ~/.p10k.zsh   # comprueba sintaxis, no imprime nada si está bien
export PATH="$HOME/.local/bin:$PATH"; hash -r
exec zsh
```

Al entrar en Zsh, `.zshrc` abre automáticamente la sesión `main` de tmux. Para
abrir una shell sin tmux: `NO_TMUX=1 zsh`.

Cierra la sesión gráfica y vuelve a entrar para que el cambio de shell y la
fuente nueva apliquen en todas las terminales. kitty recarga su config en
caliente con `pkill -USR1 kitty`.

### 5. Primer arranque de Neovim

Instala los plugins y los parsers de treesitter sin abrir la interfaz:

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+TSUpdateSync" +qa
```

Después abre `nvim` y ejecuta `:checkhealth`. Lo que necesita cada parte:

- `nodejs` y `npm`: vista previa de markdown y Copilot.
- `gcc`, `make`, `curl`: compilación de treesitter y descarga del binario de avante.
- `ripgrep`, `fd-find`, `fzf`: búsqueda de archivos y texto.
- `lazygit`: pestaña de git (`<leader>gg`).
- `ranger`: integración con el explorador (`<leader>r`).
- `xclip` o `wl-clipboard`: portapapeles.
- `claude`, `opencode`, `gemini`: solo si usas esos asistentes; los plugins se cargan bajo demanda y no fallan si faltan.

### 6. Comprobación rápida

```bash
fastfetch                         # logo y temperaturas
tmux -V && tmux source-file ~/.tmux.conf
command -v fuck ranger keifu lazygit nvim eza bat fzf zoxide
fc-list | grep -c "MesloLGS NF"   # debe ser 4
```

## Máquina con configuración existente

- Los archivos anteriores quedan en `~/.config/scripts-basicos-linux-backup-<fecha>`.
- Si tenías aliases o funciones propias en `~/.zshrc`, cópialos del respaldo al nuevo archivo. Mantén los extras al final, después de la línea que carga `zsh-syntax-highlighting`.
- El repo ya no usa el perfil separado `nvim-gentleman`. Si lo tienes de una versión anterior, puedes borrar `~/.config/nvim-gentleman`, `~/.local/share/nvim-gentleman`, `~/.local/state/nvim-gentleman` y `~/.cache/nvim-gentleman`.
- Si ya tenías `~/.local/share/nvim` de otra configuración, bórralo antes del paso 5 para que LazyVim instale sus plugins limpios.

## Atajos principales

| Atajo | Dónde | Acción |
| --- | --- | --- |
| Alt+c | tmux | Nueva ventana |
| Ctrl+Alt+x | tmux | Cerrar ventana |
| Alt+Shift+c | tmux | Nueva sesión |
| Ctrl+q | tmux | Gestor de sesiones, ventanas y paneles |
| Ctrl+t / Ctrl+f | tmux | Dividir horizontal / vertical |
| Ctrl+x | tmux | Cerrar panel |
| Ctrl+z | tmux | Focus: amplía el panel y oculta la barra |
| Ctrl+G | zsh y keifu | Gestor de ramas `gbm` (switch, pull, push, borrar) |
| `r` / `ra` | zsh | ranger, cambiando al directorio elegido al salir |
| `nv` | zsh | Neovim |
| `kg` | zsh | keifu |

Más detalle de tmux y del gestor de ramas en [`config/tmux/README.md`](config/tmux/README.md).

## Mantener el repo al día

Cuando cambies algo en tu máquina, cópialo al repo y haz commit:

```bash
cd ~/repos/scripts-basicos-linux
cp ~/.zshrc config/shell/.zshrc
cp ~/.tmux.conf config/tmux/.tmux.conf
cp ~/.config/kitty/kitty.conf config/terminal/kitty.conf
rsync -a --delete --exclude lazy-lock.json ~/.config/nvim/ config/nvim/
git status
```

> **Seguridad:** no agregues tokens, claves SSH, contraseñas ni archivos `.env` al repositorio. Revisa `git diff` antes de cada commit.

## Notas para agentes

1. No reemplazar configuraciones existentes sin crear primero un respaldo.
2. No copiar cachés, `__pycache__`, estados de plugins ni credenciales.
3. Hay una sola configuración de Neovim en `~/.config/nvim`; `nv` y `nvim` son lo mismo.
4. Verificar la sintaxis con `zsh -n` después de modificar `.zshrc` o `.p10k.zsh`, y recargar tmux con `tmux source-file ~/.tmux.conf`.
5. Si se agrega una herramienta nueva, documentar su paquete en el paso 1 o 2 de la instalación.
