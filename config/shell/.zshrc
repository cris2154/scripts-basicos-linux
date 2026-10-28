# Iniciar sesión de tmux automáticamente al iniciar zsh
if command -v tmux >/dev/null 2>&1 && [[ -o interactive ]] && [[ -t 0 && -t 1 ]] && [[ -z "$TMUX" ]]; then
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
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY HIST_IGNORE_DUPS SHARE_HISTORY

# Autocompletado
autoload -Uz compinit
compinit
bindkey -e

# Sugerencias al escribir
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^[[C' forward-char

# fzf: integración compatible con distintas versiones + tema Azul Neón
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --color=bg+:#0f2952,fg+:#ffffff,hl:#38bdf8,hl+:#67e8f9,pointer:#38bdf8,marker:#2563eb,prompt:#38bdf8,header:#60a5fa,border:#2563eb,info:#93c5fd'

if fzf --zsh >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# Saltar a carpetas frecuentes
eval "$(zoxide init zsh)"

# Listados con iconos
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lah --icons=auto --git --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto'

# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias trabajo='cd /mnt/c/Users/usuario/Documents/Trabajo'

# Atajos Git
alias gs='git status -sb'
alias gb='git branch'
alias gsw='git switch'
alias gd='git diff'

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

# Abrir Yazi y conservar la carpeta al salir con q
function y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return

  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"

  if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
    builtin cd -- "$cwd"
  fi

  command rm -f -- "$tmp"
}

# Tema Powerlevel10k
if [[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/powerlevel10k/powerlevel10k.zsh-theme
fi

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Resaltado de comandos: mantener al final
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# >>> Codex installer >>>
export PATH="/home/cris/.local/bin:$PATH"
# <<< Codex installer <<<
export PATH="$HOME/.local/bin:$PATH"

if command -v thefuck >/dev/null 2>&1; then
  if _thefuck_alias=$(thefuck --alias 2>/dev/null); then
    eval "$_thefuck_alias"
  fi
  unset _thefuck_alias
fi

eval $(thefuck --alias)

# Open the isolated Gentleman Neovim profile.
alias nv="NVIM_APPNAME=nvim-gentleman nvim"

# csakura (paleta azul sky)
alias saku='csakura -c sky'

# cmatrix en japonés (Katakana) + Azul Neón por defecto
alias cmatrix="$HOME/.local/bin/cmatrix -c -C blue"
alias matrix="$HOME/.local/bin/cmatrix -c -C blue"

# CAVA Windows Audio Capture
alias cava='cava-windows'
alias cava-windols='cava-windows'
alias cava-widnolss='cava-windows'
