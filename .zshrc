### non-interative mode

[[ $- =~ .*i.* ]] || return


### utility functions

function add_path {
  local arg
  for arg in "$@"; do
    [[ :$PATH: != *:$arg:* ]] || continue
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


### Plugin manager
export ZCONFIGDIR="$XDG_CONFIG_HOME/zsh"
export ZPLUGINDIR="${ZPLUGINDIR:-$ZCONFIGDIR/plugins}"

function plugin-load {
  ensure_command git
  local plugin repo commitsha plugdir initfile initfiles=()
  : "$ZPLUGINDIR"
  for plugin in "$@"; do
    repo="$plugin"
    clone_args=(-q --depth 1 --recursive --shallow-submodules)
    if [[ "$plugin" == *'@'* ]]; then
      repo="${plugin%@*}"
      commitsha="${plugin#*@}"
      clone_args+=(--no-checkout)
    fi
    plugdir="$ZPLUGINDIR/${repo:t}"
    initfile="$plugdir/${repo:t}.plugin.zsh"
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone "$clone_args[@]" "https://github.com/$repo" "$plugdir"
      if [[ -n "$commitsha" ]]; then
        git -C "$plugdir" fetch -q origin "$commitsha"
        git -C "$plugdir" checkout -q "$commitsha"
      fi
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      if (( $#initfiles == 0 )); then
        print -u2 "No init file found '$repo'."
        continue
      fi
      ln -sf "$initfiles[1]" "$initfile"
    fi
    fpath+="$plugdir"
    (( $+functions[zsh-defer] )) && zsh-defer . "$initfile" || . "$initfile"
  done
}

function plugin-update {
  local d
  unsetopt MONITOR
  for d in "$ZPLUGINDIR"/*/.git(/); do
    echo "Updating ${d:h:t}..."
    ( git -C "${d:h}" pull \
      --ff --recurse-submodules --depth 1 --rebase --autostash ) &
  done
  wait
  setopt MONITOR
}

### powerlevel10k instant prompt

function {
  local prompt_script="$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
  [[ -r $prompt_script ]] && source "$prompt_script"
}


### load plugins

function {
  local plugins=(
    'romkatv/powerlevel10k'
    'romkatv/zsh-defer'
    'zsh-users/zsh-completions'
    'zsh-users/zsh-autosuggestions'
    'zsh-users/zsh-history-substring-search'
    'zdharma-continuum/fast-syntax-highlighting'
    'mmorys/dirhistory'
    'le0me55i/zsh-extract'
    'twang817/zsh-manydots-magic'
  )

  if has_command awk; then
    plugins+=('agkozak/zsh-z')
    export ZSHZ_DATA="$XDG_CONFIG_HOME/zsh/z"
    export ZSHZ_CASE='smart'
  fi

  # workaround zsh-auto-notify detecting notify-send
  if [[ -n $SSH_CLIENT ]]; then
    alias notify-send=
  fi

  if has_command awk notify-send; then
    plugins+=('MichaelAquilina/zsh-auto-notify')
    export AUTO_NOTIFY_ENABLE_SSH=1
    export AUTO_NOTIFY_THRESHOLD=30
    export AUTO_NOTIFY_ICON_SUCCESS='dialog-positive'
    export AUTO_NOTIFY_ICON_FAILURE='dialog-error'
  fi

  plugin-load "$plugins[@]"
}


### options & environment variables

setopt SHARE_HISTORY
setopt autocd globdots histignoredups
bindkey -e
bindkey "^[[A" history-substring-search-up
bindkey "^[OA" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey "^[OB" history-substring-search-down
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

zstyle ':completion:*' menu yes select
zstyle ':completion:*' rehash true
zstyle ':completion:*:functions' ignored-patterns '_*'

add_path "$HOME/.local/bin" \
         "$HOME/.ghcup/bin" \
         "$HOME/.rustup/bin"

export EDITOR="$(first_available nvim vim nano)"
export VISUAL="$EDITOR"
export HISTFILE="$ZCONFIGDIR/history"
export HISTSIZE=50000
export SAVEHIST=50000
export COMPDUMPFILE="$ZCONFIGDIR/compdump"
export COLORTERM=truecolor
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export DISABLE_UNTRACKED_FILES_DIRTY="true"
if [[ $TERM == linux ]]; then
  export TERM=linux-16color
fi

zmodload zsh/zutil
autoload -Uz compinit && compinit -d "$COMPDUMPFILE"

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
alias help='run-help'
alias history='history 0'

if has_command nvim && ! has_command vim; then
  alias vim='nvim'
  alias vimdiff='nvim -d'
fi

if has_command batman; then
  alias man='batman'
fi


### pkgfile as command-not-found handler
function {
  local handler='/usr/share/doc/pkgfile/command-not-found.zsh'
  [[ -e $handler ]] && . "$handler"
}


### disable slow highlighting

if ! [[ -z $FAST_HIGHLIGHT ]]; then
  FAST_HIGHLIGHT[chroma-make]=
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


### advanced move

autoload -Uz zmv
alias mmv='noglob zmv -W'

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
  {
    local url="https://man.archlinux.org/man/$*.raw"
    local tmpfile="$(mktemp)"
    local respcode="$(curl -o "$tmpfile" -sL "$url" -w '%{response_code}')"
    if (( respcode >= 400 )); then
      print -u2 "Failed to fetch man page for $* (response code: $respcode)"
      return 1
    fi
    man -l "$tmpfile"
  } always {
    rm "$tmpfile"
  }
}

### load powerlevel10k config

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

