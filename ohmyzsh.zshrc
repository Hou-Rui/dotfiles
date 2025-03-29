# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#### Self-used environment variables ####
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"


#### PowerLevel 10K instant prompt ####
function {
  local p10k_inst="$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
  [[ -r $p10k_inst ]] && source "$p10k_inst"
}


#### Oh-My-Zsh config ####
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="$ZSH/cache/.zcompdump-$HOST"
export ZSH_THEME='powerlevel10k/powerlevel10k'
export HYPHEN_INSENSITIVE=true
export DISABLE_AUTO_UPDATE=true
export ENABLE_CORRECTION=false
export PKGFILE_PROMPT_INSTALL_MISSING=1
export GROFF_NO_SGR=1
export CORRECT_IGNORE_FILE='.*'
export PYTHON_AUTO_VRUN=true

plugins=(command-not-found dirhistory fancy-ctrl-z extract python z)

function {
  local path plugin
  for path in "$ZSH/custom/plugins/"*; do
    plugin="$(/usr/bin/basename $path)"
    if [[ $plugin != example ]]; then
      plugins+=("$plugin")
    fi
  done
}

source "$ZSH/oh-my-zsh.sh"


#### Helper functions ####
function has_command {
  command -v "$*" &> /dev/null
}

function add_path {
  if ! [[ $PATH =~ .*"$*".* ]]; then
    export PATH="$*:$PATH"
  fi
}


#### Environment config ####
setopt no_nomatch extended_glob
autoload -Uz zmv run-help
unalias run-help  # by default run-help alias to man
export EDITOR='nvim'
export DIFFPROG='nvim -d'
export VISUAL="$EDITOR"
export SUDO='sudo'
export SAVEHIST=9999999
export ZSHZ_DATA="$XDG_DATA_HOME/zsh-z/.z"
export WORDCHARS='-'

if [[ $TERM == linux ]]; then
  export TERM=linux-16color  # use 16-color in TTY mode
fi

add_path "$HOME/.local/bin"

#### aliases ####
alias cls='clear'
alias py='python'
alias py3='python3'
alias bc='bc -l'
alias src='omz reload'
alias mmv='noglob zmv -W'
alias zh='LC_ALL=zh_CN.utf-8'
alias jp='LC_ALL=ja_JP.utf-8'
alias help='run-help '

if has_command ipython; then
  alias ipy='ipython'
  alias ipython='ipython'
fi

if has_command eza; then
  alias exa='eza'
  alias l='exa --long --all --header --git --icons'
  alias ls='exa'
  alias tree='exa --tree --icons'
fi

if has_command rg; then
  alias rg='noglob rg'
  alias hgrep='history | noglob rg'
else
  alias hgrep='history | noglob grep'
fi

if has_command trash-put; then
  alias rrm='trash-put'
fi

if has_command go-task; then
  alias task='go-task'
fi

if has_command batman; then
  alias man='batman'
fi

#### utility functions ####

function makepkgclean {
  if ! [[ -f PKGBUILD ]]; then
    echo "PKGBUILD not detected."
    return 1
  fi
  for file in *; do
    if [[ $file == PKGBUILD ]]; then
      continue
    fi
    echo "Removing $file..."
    rm -rf "$file"
  done
}

function killregex {
  local regex="$1"; shift
  local args="$@"
  for p in $(pgrep "$regex"); do
    kill "$args[@]" "$p"
  done
}

function zshrc {
  "$EDITOR" "$HOME/.zshrc"
}

function vimrc {
  case "$EDITOR" in
    (nvim) "$EDITOR" "$XDG_CONFIG_HOME/nvim/init.lua";;
    (vim)  "$EDITOR" "$HOME/.vimrc";;
    (*)    echo "vim not detected."; return 1;;
  esac
}

function tldr {
  cht.sh "$*?style=rrt"
}

function wman {
  local url="https://man.archlinux.org/man/$*.raw"
  local tmpfile="$(mktemp)"
  local resp="$(curl -sL -o "$tmpfile" -w "%{response_code}" "$url")"
  local ret=0
  if (( resp >= 400 )); then
    echo "Failed to fetch online man page for $* (response code: $resp)"
    ret=1
  else
    man -l "$tmpfile"
    ret=$?
  fi
  rm "$tmpfile"
  return $ret
}


#### Auto notification config ####
export AUTO_NOTIFY_THRESHOLD=30
export AUTO_NOTIFY_IGNORE=(
  'vim' 'zshrc' 'ohmyzsh' 'vimrc' 'vimplug'
  'omwcfg' 'omwsettings'
  'zsh' 'bash'
  'man' 'more' 'less'
)
export AUTO_NOTIFY_ICON_SUCCESS='/usr/share/icons/breeze/status/64/dialog-positive.svg'
export AUTO_NOTIFY_ICON_FAILURE='/usr/share/icons/breeze/status/64/dialog-error.svg'


#### Auto rehash executable completion ####
zstyle ':completion:*' rehash true
autoload -Uz compinit
compinit


#### Speed up copy & paste ####
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
function pasteinit {
  OLD_SELF_INSERT="${${(s.:.)widgets[self-insert]}[2,3]}"
  zle -N self-insert url-quote-magic
}

function pastefinish {
  zle -N self-insert "$OLD_SELF_INSERT"
}

zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish


#### Custom PowerLevel 10K settings ####
function {
  local p10k_config="$HOME/.p10k.zsh"
  if [[ -f $p10k_config ]]; then
    source "$p10k_config"
  fi
}

