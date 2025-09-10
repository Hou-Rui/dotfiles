### non-interative mode

[[ $- =~ .*i.* ]] || return

### XDG locations

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export ZSH_CUSTOM="$XDG_DATA_HOME/zshcustom"

### poerlevel10k instant prompt

function {
  local PROMPT_SCRIPT="$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
  [[ -r $PROMPT_SCRIPT ]] && source "$PROMPT_SCRIPT"
}

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

### load plugins

source ~/.zplug/init.zsh
zplug "robbyrussell/oh-my-zsh", use:"lib/*.zsh", defer:0
zplug "plugins/dirhistory", from:oh-my-zsh, defer:1
zplug "agkozak/zsh-z"
zplug "le0me55i/zsh-extract"
zplug "zdharma-continuum/fast-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
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


### environment variables
export EDITOR="$(first_available nvim vim nano)"
export VISUAL="$EDITOR"
export HISTFILE=~/.zhistory
export HISTSIZE=50000
export SAVEHIST=50000
export COLORTERM=truecolor
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export AUTOSWITCH_FILE="venv"
export GROFF_NO_SGR=1
export WORDCHARS='-'

### PATH

add_path "$HOME/.local/bin" \
         "$HOME/.ghcup/bin" \
         "$HOME/.rustup/bin"

### aliases

if has_command eza; then
  alias ls='eza'
  alias l='eza --long --icons --group --all'
  alias tree='eza --tree'
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
alias src="source $HOME/.zshrc"
alias help='run-help'

if has_command nvim && ! has_command vim; then
  alias vim='nvim'
  alias vimdiff='nvim -d'
fi

if has_command batman; then
  alias man=batman
fi


### semantic shell integration

export POWERLEVEL9K_TERM_SHELL_INTEGRATION=true


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
  ensure_command cht.sh
  cht.sh "$*?style=rrt"
}

function frg {
  ensure_command bat rg fzf
  local result file linenumber
  result=$(rg --ignore-case --color=always --line-number --no-heading "$@" |
  fzf --ansi \
      --color 'hl:-1:underline,hl+:-1:underline:reverse' \
      --delimiter ':' \
      --preview "bat --color=always {1} --highlight-line {2}" \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
  file="${result%%:*}"
  linenumber="$(echo "${result}" | cut -d: -f2)"
  if [[ -n "$file" ]]; then
    "$EDITOR" +"${linenumber}" "$file"
  fi
}

function imgcat {
  ensure_command img2sixel
  local input mime opts=()
  zparseopts -D -E -F -- {w,-width}:=opts {h,-height}:=opts || return 1
  for input in "$@"; do
    mime="$(file -b --mime-type "$input")"
    case "$mime" in
      ('image/svg+xml')
        ensure_command magick
        magick -background none "$input" png:- | img2sixel $opts;;
      (*)
        img2sixel "$input" $opts;;
    esac
  done
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

