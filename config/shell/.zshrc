# Iniciar sesión de tmux automáticamente al iniciar zsh
if command -v tmux >/dev/null 2>&1 && [[ -o interactive ]] && [[ -t 0 && -t 1 ]] && [[ -z "$TMUX" ]] && [[ -z "$NO_TMUX" ]]; then
  tmux new-session -A -s main
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Historial
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY SHARE_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY EXTENDED_HISTORY
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS CORRECT NO_BEEP

# Autocompletado (con caché diaria para arrancar rápido)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
bindkey -e

setopt COMPLETE_IN_WORD ALWAYS_TO_END AUTO_MENU AUTO_LIST LIST_PACKED
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{#a78bfa}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{red}sin coincidencias%f'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=38;5;75'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'

# Historial por prefijo con flechas arriba/abajo
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Sugerencias al escribir
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
bindkey '^[[C' forward-char

# fzf: integración compatible con distintas versiones + tema Azul Neón
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow -g "!.git"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}'"
fi
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=always --color=always {} | head -100'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:wrap --bind 'ctrl-/:toggle-preview'"
export FZF_DEFAULT_OPTS="--height=50% --layout=reverse --border=rounded --info=inline --prompt=❯\  --pointer=▶ --marker=✓ --color=bg+:#241a45,fg+:#ffffff,hl:#a78bfa,hl+:#c4b5fd,pointer:#a78bfa,marker:#7c3aed,prompt:#a78bfa,header:#8b5cf6,border:#7c3aed,info:#c4b5fd"

if fzf --zsh >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# fzf-tab: completado con menú fzf (debe ir después de compinit y fzf)
if [[ -f "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"
  zstyle ':completion:*' menu no
  zstyle ':fzf-tab:*' fzf-flags --color=bg+:#241a45,fg+:#ffffff,hl:#a78bfa,hl+:#c4b5fd,pointer:#a78bfa,border:#7c3aed
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=2 --icons=always --color=always $realpath'
  zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza --tree --level=2 --icons=always --color=always $realpath'
  zstyle ':fzf-tab:complete:(nvim|nv|bat|cat):*' fzf-preview '[[ -d $realpath ]] && eza -1 --icons=always --color=always $realpath || bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null'
fi

# Saltar a carpetas frecuentes
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Listados con iconos
if command -v eza >/dev/null 2>&1; then
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lah --icons=auto --git --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto'
fi
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never --style=plain'
alias grep='grep --color=auto'
alias gl='git log --oneline --graph --decorate -15'
alias ga='git add'
alias gc='git commit'
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# Navegación
alias ..='cd ..'
alias ...='cd ../..'
[[ -d /mnt/c/Users/usuario/Documents/Trabajo ]] && alias trabajo='cd /mnt/c/Users/usuario/Documents/Trabajo'

# Atajos Git
alias gs='git status -sb'
alias gb='git branch'
alias gsw='git switch'
alias gd='git diff'
[[ -x "$HOME/.linuxbrew/bin/brew" ]] && eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
alias kg='keifu'

# Gestor de ramas con fzf (Ctrl+G en zsh o dentro de keifu, o el comando gbm)
_GBM_COLORS='bg+:#241a45,fg+:#ffffff,hl:#a78bfa,hl+:#c4b5fd,pointer:#a78bfa,border:#7c3aed'

# Rama de la que se creó $1 (vacío si git no lo registró)
_gbm_parent() {
  local b="$1" p sha line
  # Guardado por gbm antes
  p="$(git config --get "branch.$b.gbm-parent")"
  [[ -n "$p" ]] && git show-ref --verify --quiet "refs/heads/$p" && { echo "$p"; return; }
  # Reflog de la rama: "branch: Created from dev"
  p="$(git reflog show --format=%gs "refs/heads/$b" 2>/dev/null | tail -1)"
  p="${p#branch: Created from }"
  if [[ "$p" == HEAD ]]; then
    # git switch -c: buscar la primera vez que se entró a la rama
    line="$(git reflog show --format=%gs HEAD 2>/dev/null | grep -E "^checkout: moving from .+ to $b\$" | tail -1)"
    p="${${line#checkout: moving from }% to $b}"
  elif [[ "$p" == refs/remotes/* || "$p" == origin/* ]]; then
    p="${p#refs/remotes/}"; p="${p#origin/}"
  elif [[ -n "$p" ]] && ! git show-ref --verify --quiet "refs/heads/$p"; then
    # Creada desde un commit (p. ej. con b en keifu): rama que contiene ese commit
    sha="$(git rev-parse --verify --quiet "$p^{commit}")"
    p=""
    if [[ -n "$sha" ]]; then
      local c
      for c in dev develop main master $(git for-each-ref --format='%(refname:short)' --contains "$sha" refs/heads); do
        [[ "$c" != "$b" ]] && git merge-base --is-ancestor "$sha" "refs/heads/$c" 2>/dev/null && { p="$c"; break; }
      done
    fi
  fi
  [[ -n "$p" && "$p" != "$b" ]] && git show-ref --verify --quiet "refs/heads/$p" || return 0
  git config "branch.$b.gbm-parent" "$p"
  echo "$p"
}

_gbm_delete() {
  local b="$1" remote="$2" back="$3"
  if [[ "$b" == (dev|develop|main|master) ]]; then
    echo "No se borra la rama protegida: $b"; return 1
  fi
  if [[ "$(git branch --show-current)" == "$b" ]]; then
    git switch "${back:-$(_gbm_base)}" || return 1
  fi
  if ! git branch -d "$b"; then
    read -q "?$b no está fusionada. ¿Borrar de todas formas? (y/N) " || { echo; return 1; }
    echo
    git branch -D "$b" || return 1
  fi
  git config --remove-section "branch.$b" 2>/dev/null
  if [[ "$remote" == remote ]] && git ls-remote --exit-code --heads origin "$b" >/dev/null 2>&1; then
    git push origin --delete "$b"
  fi
}

_gbm_push() {
  local b="$1" msg
  [[ "$(git branch --show-current)" == "$b" ]] || git switch "$b" || return 1
  if [[ -n "$(git status --porcelain)" ]]; then
    git status -sb
    read "msg?Mensaje del commit (vacío = cancelar): "
    [[ -z "$msg" ]] && { echo "Cancelado"; return 1; }
    git add -A && git commit -m "$msg" || return 1
  fi
  if git rev-parse --abbrev-ref --symbolic-full-name "$b@{upstream}" >/dev/null 2>&1; then
    git push
  else
    git push -u origin "$b"
  fi
}

_gbm_base() {
  if [[ -n "$GBM_BASE" ]]; then echo "$GBM_BASE"; return; fi
  local b
  for b in dev develop main master; do
    git show-ref --verify --quiet "refs/heads/$b" && { echo "$b"; return; }
  done
  echo main
}

gbm() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "No estás en un repositorio git"; return 1; }
  local current branch parent action rc
  current="$(git branch --show-current)"

  branch="$(git for-each-ref --sort=-committerdate refs/heads --format='%(refname:short)' |
    fzf --height=60% --reverse --border --prompt="rama > " --color="$_GBM_COLORS" \
      --header="Actual: $current | Enter: elegir | Esc: salir" \
      --preview='git log --oneline --graph --color=always --decorate -20 {}')" || return 0
  [[ -z "$branch" ]] && return 0
  parent="$(_gbm_parent "$branch")"

  local -a opts
  opts=("Subir cambios a GitHub (commit + push de $branch)"
        "Pull origin $branch"
        "Switch a $branch")
  [[ -n "$parent" && "$branch" != (dev|develop|main|master) ]] && opts+=("Separar rama: volver a $parent, pull origin $parent y borrar $branch")
  opts+=("Borrar $branch (local)" "Borrar $branch (local y en origin)")

  action="$(printf '%s\n' "${opts[@]}" |
    fzf --height=40% --reverse --border --prompt="$branch > " --color="$_GBM_COLORS" \
      --header="¿Qué hacer con $branch?${parent:+  (creada desde $parent)}")" || return 0

  case "$action" in
    Subir*)  _gbm_push "$branch" ;;
    Pull*)   { [[ "$current" == "$branch" ]] || git switch "$branch"; } && git pull origin "$branch" ;;
    Switch*) git switch "$branch" ;;
    Separar*) git switch "$parent" && git pull origin "$parent" && _gbm_delete "$branch" "" "$parent" ;;
    *"local y en origin"*) _gbm_delete "$branch" remote "$parent" ;;
    Borrar*) _gbm_delete "$branch" "" "$parent" ;;
  esac
  rc=$?
  # Dentro del popup de keifu: dejar ver el resultado antes de cerrar
  [[ -n "$GBM_POPUP" ]] && read -sk "?
Presiona una tecla para volver..."
  return $rc
}

_gbm_widget() {
  BUFFER="gbm"
  zle accept-line
}
zle -N _gbm_widget
bindkey '^G' _gbm_widget

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Ejecutables instalados con Go
export PATH="$HOME/go/bin:$PATH"
# Personalización de sugerencias
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
bindkey '^F' autosuggest-accept

# Abrir Ranger y conservar la carpeta al salir
if command -v ranger >/dev/null 2>&1; then
function r() {
  local tmp
  tmp="$(mktemp -t "ranger-cwd.XXXXXX")" || return

  command ranger --choosedir="$tmp" "$@"
  if [[ -f "$tmp" ]]; then
    local cwd
    cwd="$(< "$tmp")"
    command rm -f -- "$tmp"
    if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
      builtin cd -- "$cwd"
    fi
  fi
}
alias ra="r"
fi

# Tema Powerlevel10k
if [[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/powerlevel10k/powerlevel10k.zsh-theme
fi

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Resaltado de comandos: mantener al final
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

export PATH="$HOME/.local/bin:$PATH"

if command -v thefuck >/dev/null 2>&1; then
  if _thefuck_alias=$(thefuck --alias 2>/dev/null); then
    eval "$_thefuck_alias"
  fi
  unset _thefuck_alias
fi

# Open the isolated Gentleman Neovim profile.
alias nv="nvim"
export EDITOR="nv"
export VISUAL="nv"

# csakura (paleta azul sky)
command -v csakura >/dev/null 2>&1 && alias saku='csakura -c sky'

# cmatrix en japonés (Katakana) + Azul Neón por defecto
alias cmatrix="$HOME/.local/bin/cmatrix -c -C blue"
alias matrix="$HOME/.local/bin/cmatrix -c -C blue"

# pipes.sh en Azul Neón
alias pipes="$HOME/.local/bin/pipes.sh"
alias pipesh="$HOME/.local/bin/pipes.sh"

# CAVA: solo usa cava-windows si existe (WSL)
command -v cava-windows >/dev/null 2>&1 && alias cava='cava-windows'
