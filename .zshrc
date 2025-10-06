### non-interative mode

[[ $- =~ .*i.* ]] || return


### utility functions

function add_path {
  local arg
  for arg in "$@"; do
    [[ :"$PATH": != *:"$arg":* ]] || continue
    export PATH="$arg:$PATH"
  done
}

function has_command {
  command -v $* &> /dev/null
}

function ensure_command {
  local cmd
  for cmd in "$@"; do
    if ! has_command "$cmd"; then
      print -u2 "Error: command '$cmd' required for this action."
      return 1
    fi
  done
}

function first_available {
  local cmd
  for cmd in "$@"; do
    has_command "$cmd" || continue
    echo "$cmd"
    return 0
  done
  return 1
}


### execute default script for remote nodes

function {
  local sing_default="$HOME/.singularity_default"
  if has_command singularity && [[ -x $sing_default ]]; then
    exec "$sing_default"
  fi
}


### XDG locations

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export ZSH_CUSTOM="$XDG_DATA_HOME/zshcustom"


### powerlevel10k instant prompt

function {
  local PROMPT_SCRIPT="$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
  [[ -r $PROMPT_SCRIPT ]] && source "$PROMPT_SCRIPT"
}


### load plugins

source ~/.zplug/init.zsh
zplug "mmorys/dirhistory"
zplug "agkozak/zsh-z"
zplug "le0me55i/zsh-extract"
zplug "zdharma-continuum/fast-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions", defer:1
zplug "zsh-users/zsh-autosuggestions", defer:1
zplug 'knu/zsh-manydots-magic', use:manydots-magic, defer:3
zplug "romkatv/powerlevel10k", as:theme, depth:1

if [[ -z $SINGULARITY_CONTAINER ]]; then
  zplug "plugins/command-not-found", from:oh-my-zsh, defer:1
fi

if has_command awk notify-send; then
  zplug "MichaelAquilina/zsh-auto-notify"
  export AUTO_NOTIFY_THRESHOLD=30
  export AUTO_NOTIFY_ICON_SUCCESS='/usr/share/icons/breeze/status/64/dialog-positive.svg'
  export AUTO_NOTIFY_ICON_FAILURE='/usr/share/icons/breeze/status/64/dialog-error.svg'
fi

function {
  [[ -d $ZSH_CUSTOM ]] || return
  local plugin
  for plugin in "$ZSH_CUSTOM/"*(N); do
    zplug "$plugin", from:local
  done
}

if [[ "$TERM" == linux ]]; then
  export TERM=linux-16color
fi

zplug load


### options & environment variables

setopt autocd globdots histignoredups

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey '^W' backward-kill-word

zstyle ':completion:*' menu yes select
zstyle ':completion:*' rehash true
zstyle ':completion:*:functions' ignored-patterns '_*'

add_path "$HOME/.local/bin" \
         "$HOME/.ghcup/bin" \
         "$HOME/.rustup/bin"

export EDITOR="$(first_available nvim vim nano)"
export VISUAL="$EDITOR"
export HISTFILE=~/.zhistory
export HISTSIZE=50000
export SAVEHIST=50000
export COLORTERM=truecolor
export DISABLE_UNTRACKED_FILES_DIRTY="true"


### aliases

if has_command eza; then
  alias ls='eza'
  alias l='eza --long --icons --group --all'
  alias tree='eza --tree'
else
  alias ls='ls --color'
  alias l='ls -l --color --all -F -h'
fi

if has_command fdfind; then
  alias fd='fdfind'
fi

if has_command batcat; then
  alias bat='batcat'
  export MANPAGER='bat'
fi

alias open='xdg-open'
alias x='extract'
alias cls='clear'
alias md='mkdir'
alias src="source $HOME/.zshrc"
alias help='run-help'

if has_command nvim && ! has_command vim; then
  alias vim='nvim'
  alias vimdiff='nvim -d'
fi

if has_command batman; then
  alias man=batman
fi


### speed up copy & paste

function pasteinit {
  OLD_SELF_INSERT="${${(s.:.)widgets[self-insert]}[2,3]}"
  zle -N self-insert url-quote-magic
}

function pastefinish {
  zle -N self-insert "$OLD_SELF_INSERT"
}

zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish


### functions

function zshrc {
  "$EDITOR" "$HOME/.zshrc"
}

function vimrc {
  if has_command nvim; then
    "$EDITOR" "$HOME/.config/nvim/init.lua"
  else
    "$EDITOR" "$HOME/.vimrc"
  fi
}

function mkcd {
  if (( $# != 1 )); then
    echo 'Usage: mkcd <dir>'
    return 1
  fi
  mkdir "$1" && cd "$1"
}

function hgrep {
  if (( $# < 1 )); then
    echo 'Usage: hgrep <pattern>'
    return 1
  fi
  if has_command rg; then
    history | rg "$*"
  else
    history | grep -E "$*" -
  fi
}

function killregex {
  local regex="$1"; shift
  local args="$@"
  for p in $(ps -A | grep -E "$regex" | awk '{print $1}'); do
    kill $args $p
  done
}

function repo {
  local repo_exe local_repo cur_dir="$PWD"
  while [[ $cur_dir != / ]]; do
    local_repo="$cur_dir/.repo/repo/repo"
    if [[ -x $local_repo ]]; then
      repo_exe="$local_repo"
      break
    fi
    cur_dir="$(dirname "$cur_dir")"
  done
  [[ -x $repo_exe ]] || repo_exe="$(which -p repo)"
  echo "Using $repo_exe"
  "$repo_exe" "$@"
}

function tldr {
  if has_command cht.sh; then
    cht.sh "$*?style=rrt"
  elif has_command curl; then
    curl "cht.sh/$*?style=rrt"
  else
    print -u2 'No TLDR providers'
    return 1
  fi
}

function frg {
  ensure_command bat rg fzf
  local rg_prefix="rg --column --line-number --no-heading --color=always --smart-case "
  fzf --ansi --disabled --query "${*:-}" \
      --bind "start:reload:$rg_prefix {q}" \
      --bind "change:reload:sleep 0.1; $rg_prefix {q} || true" \
      --delimiter ':' \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind "enter:become($EDITOR {1} +{2})"
}

function wman {
  ensure_command mktemp curl man
  local tmpfile="$(mktemp)"
  local ret=0
  local url="https://man.archlinux.org/man/$*.raw"
  local respcode="$(curl -o "$tmpfile" -sL "$url" -w '%{response_code}')"
  if (( respcode >= 400 )); then
    print -u2 "Failed to fetch man page for $* (response code: $respcode)"
    ret=1
  else
    man -l "$tmpfile"
    ret=$?
  fi
  rm "$tmpfile"
  return "$ret"
}


### load powerlevel10k config

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

