### XDG locations

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"


### poerlevel10k instant prompt

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
PROMPT_SCRIPT="$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
if [[ -r $PROMPT_SCRIPT ]]; then
  source "$PROMPT_SCRIPT"
fi


### load plugins

source ~/.zplug/init.zsh

function has_command {
  command -v "$*" &> /dev/null
}

zplug "robbyrussell/oh-my-zsh", use:"lib/*.zsh", defer:0
zplug "plugins/dirhistory", from:oh-my-zsh, defer:1
zplug "agkozak/zsh-z"
zplug "le0me55i/zsh-extract"
zplug "ael-code/zsh-colored-man-pages"
zplug "zdharma-continuum/fast-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "MichaelAquilina/zsh-autoswitch-virtualenv"
zplug 'knu/zsh-manydots-magic', use:manydots-magic, defer:3
zplug "romkatv/powerlevel10k", as:theme, depth:1

if [[ -z $SINGULARITY_CONTAINER ]]; then
  zplug "plugins/command-not-found", from:oh-my-zsh, defer:1
fi

if has_command notify-send; then
  zplug "MichaelAquilina/zsh-auto-notify"
  export AUTO_NOTIFY_THRESHOLD=30
  export AUTO_NOTIFY_ICON_SUCCESS='/usr/share/icons/breeze/status/64/dialog-positive.svg'
  export AUTO_NOTIFY_ICON_FAILURE='/usr/share/icons/breeze/status/64/dialog-error.svg'
fi

if [[ "$TERM" == linux ]]; then
  export TERM=linux-16color
fi

zplug load


### environment variables

export EDITOR='nvim'
export VISUAL='nvim'
export HISTFILE=~/.zhistory
export HISTSIZE=50000
export SAVEHIST=50000
export COLORTERM=truecolor
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export AUTOSWITCH_FILE="venv"
export WORDCHARS='.-'


### aliases

if has_command eza; then
  alias ls='eza'
  alias l='eza --long --icons --all'
  alias tree='eza --tree'
fi

alias open='xdg-open'
alias x='extract'
alias cls='clear'
alias src="source $HOME/.zshrc"
alias help='run-help'

if has_command nvim && ! has_command vim; then
  alias vim='nvim'
  alias vimdiff='nvim -d'
fi


### auto rehash executable completion

zstyle ':completion:*' rehash true
zstyle ':completion:*:functions' ignored-patterns '_*'


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
    echo 'Usage: hrep <pattern>'
    return 1
  fi
  history | grep -E "$*" -
}

function killregex {
  local regex="$1"; shift
  local args="$@"
  for p in $(ps -A | grep -E "$regex" | awk '{print $1}'); do
    kill $args $p
  done
}

function update {
  yay
  flatpak update
  zplug update
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
  cht.sh "$*?style=rrt"
}


### load powerlevel10k config

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

