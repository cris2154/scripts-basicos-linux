# tmux y sus gestores

Respaldo de `~/.tmux.conf`, con tema Azul Neón, dos filas de estado,
ayuda contextual, mouse, portapapeles, imágenes mediante passthrough y barra
de scroll en modo copia. La configuración se valida con tmux 3.8.

## Archivos y referencias

| Archivo | Destino o uso |
| --- | --- |
| [`.tmux.conf`](.tmux.conf) | `~/.tmux.conf`; incluye el manager de sesiones, ventanas y paneles (`choose-tree`) |
| [`../shell/.zshrc`](../shell/.zshrc) | `~/.zshrc`; inicia la sesión `main`, define `kg`, `gbm`, sus funciones `_gbm_*` y el atajo `Ctrl+G` |
| [`../shell/.p10k.zsh`](../shell/.p10k.zsh) | `~/.p10k.zsh`; tema de Zsh, cargado por `.zshrc` cuando existe |
| [`bin/wl-copy`](bin/wl-copy), [`bin/wl-paste`](bin/wl-paste) | Copia de los adaptadores locales de portapapeles basados en `xclip` |
| [`../terminal/kitty.conf`](../terminal/kitty.conf) | `~/.config/kitty/kitty.conf`; fuente MesloLGS NF, transparencia y colores |
| [`../nvim-gentleman/lua/plugins/vim-tmux-navigation.lua`](../nvim-gentleman/lua/plugins/vim-tmux-navigation.lua) | Declaración del plugin de navegación del perfil Neovim |

El manager de tmux es integrado: sus formatos, atajos y ayuda están en
`.tmux.conf`. No usa TPM ni carga scripts o archivos adicionales mediante
`source-file`, salvo la recarga de `~/.tmux.conf` con prefijo + `r`.

El gestor de ramas `gbm` está completo en `.zshrc`. Desde Keifu, `Ctrl+G`
ejecuta `zsh -ic gbm` en un popup con `NO_TMUX=1` y `GBM_POPUP=1`.
Permite cambiar de rama, hacer pull, commit/push y borrar ramas. El popup
necesita la configuración de Zsh además de la de tmux.

## Dependencias

- `tmux` y `/usr/bin/zsh`. Para reproducir todos los ajustes se ha usado tmux
  3.8; las opciones recientes de scroll pueden fallar en versiones anteriores.
- `git` y `fzf` para `gbm`; `keifu` para el alias `kg` y el popup desde Keifu.
- Portapapeles: `xsel`, `wl-copy` de `wl-clipboard` o `xclip`, en ese orden.
  Los adaptadores de `bin/` usan `xclip` y necesitan X11/XWayland.
- Una Nerd Font (la configuración de Kitty usa MesloLGS NF) para los iconos.
- Para la apariencia de Zsh, Powerlevel10k en `~/powerlevel10k/` y
  `~/.p10k.zsh`. Las demás integraciones de shell están en
  [`../shell/.zshrc`](../shell/.zshrc) y se describen en el
  [README general](../../README.md).

Dependencias base en Fedora:

```sh
sudo dnf install tmux zsh git fzf xsel xclip wl-clipboard
```

Keifu se instaló en esta máquina mediante el tap `trasta298/tap` de Homebrew:

```sh
brew install trasta298/tap/keifu
```

## Copiar la configuración

Desde la carpeta `config/` del repositorio, este bloque respalda los archivos
existentes antes de copiar tmux y la shell que contiene `gbm`:

```sh
(
  set -eu
  backup_dir=$(mktemp -d "$HOME/tmux-backup.XXXXXXXX")
  for file in .tmux.conf .zshrc .p10k.zsh; do
    if [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
      cp -a "$HOME/$file" "$backup_dir/"
    fi
  done
  cp tmux/.tmux.conf "$HOME/.tmux.conf"
  cp shell/.zshrc shell/.p10k.zsh "$HOME/"
  zsh -n "$HOME/.zshrc"
  zsh -n "$HOME/.p10k.zsh"
  printf 'Respaldo: %s\n' "$backup_dir"
)
```

Si ya tienes una shell personalizada, incorpora el bloque de inicio de tmux,
`alias kg`, `_GBM_COLORS`, las funciones `_gbm_*` y `gbm`, y el registro de
`_gbm_widget` desde `.zshrc` en lugar de reemplazarla completa.

Los adaptadores de portapapeles son opcionales y se conservan tal como están
en la máquina original; no implementan todas las opciones de `wl-clipboard`.
Para usarlos, desde `config/`:

```sh
(
  set -eu
  backup_dir=$(mktemp -d "$HOME/clipboard-backup.XXXXXXXX")
  mkdir -p "$HOME/.local/bin"
  for file in wl-copy wl-paste; do
    if [ -e "$HOME/.local/bin/$file" ] || [ -L "$HOME/.local/bin/$file" ]; then
      cp -a "$HOME/.local/bin/$file" "$backup_dir/"
    fi
    install -m 755 "tmux/bin/$file" "$HOME/.local/bin/$file"
  done
  printf 'Respaldo: %s\n' "$backup_dir"
)
```

La shell respaldada agrega `~/.local/bin` al `PATH`. En Wayland sin XWayland,
usa los ejecutables originales de `wl-clipboard`.

Abre una nueva terminal para cargar Zsh. Dentro de una sesión existente,
recarga tmux con `Ctrl+b`, luego `r`, o `tmux source-file ~/.tmux.conf`.

## Atajos principales

El prefijo es `Ctrl+b`, con `Ctrl+a` como alternativa.

Una sesión contiene ventanas (las pestañas de la barra), y cada ventana puede
contener varios paneles. `Alt+c` crea una ventana en la sesión actual.

| Atajo | Acción |
| --- | --- |
| `Ctrl+q` / `Alt+w` | Abrir manager de ventanas |
| `Alt+s` | Abrir manager de sesiones |
| `Enter` / `q` en el manager | Abrir selección / salir |
| `x` en el manager | Eliminar selección con confirmación |
| `Alt+c` | Crear ventana en la sesión y carpeta desde las que abriste el manager |
| `Ctrl+Alt+c` / prefijo, luego `c` | Crear ventana en la carpeta actual |
| `Alt+Shift+c` | Crear una sesión nueva y entrar en ella desde la carpeta actual |
| `Ctrl+Alt+x` / prefijo, luego `X` (mayúscula) | Cerrar la ventana activa y todos sus paneles, sin confirmación |
| Prefijo, luego `&` | Cerrar la ventana activa con confirmación |
| `Ctrl+t` / `Ctrl+f` | Dividir arriba-abajo / izquierda-derecha |
| `Ctrl+z` / `Ctrl+x` | Zoom / cerrar panel activo |
| `Ctrl+flechas` / `Alt+flechas` | Cambiar de panel |
| `Shift+izquierda` / `Shift+derecha` | Ventana anterior / siguiente |
| `Ctrl+Alt+flechas` | Redimensionar panel |
| `PageUp` o rueda hacia arriba | Entrar al historial |
| `y`, `Enter` o `Ctrl+c` en modo copia | Copiar selección |
| `Ctrl+g` dentro de Keifu | Abrir `gbm` en popup |
| `Ctrl+g` en Zsh / `gbm` | Abrir gestor de ramas |

`Ctrl+x` cierra solo el panel activo; si era el último panel, también cierra
su ventana. Al cerrar la última ventana se cierra la sesión. Para usar el
prefijo, pulsa `Ctrl+b`, suelta ambas teclas y pulsa la tecla indicada.

Los atajos sin prefijo ocupan esas combinaciones dentro de tmux; por ejemplo,
`Ctrl+f` divide el panel aunque `.zshrc` también lo asigne a autosugerencias.
