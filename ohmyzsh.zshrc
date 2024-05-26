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

plugins=(
  command-not-found colored-man-pages dirhistory
  fancy-ctrl-z fd extract python z
)

function {
  local path plugin
  for path in "$ZSH/custom/plugins/"*; do
    plugin="$(/usr/bin/basename $path)"
    [[ $plugin != example ]] && plugins+=("$plugin")
  done
}

source "$ZSH/oh-my-zsh.sh"


#### Environment config ####
setopt no_nomatch
autoload -U zmv
autoload -Uz run-help
unalias run-help  # by default run-help alias to man
export EDITOR='nvim'
export VISUAL='nvim'
export DIFFPROG='nvim -d'
export SUDO='sudo'
export SAVEHIST=9999999
export ZSHZ_DATA="$XDG_DATA_HOME/zsh-z/.z"
compinit -d "$ZSH_COMPDUMP"

if [[ "$TERM" == 'linux' ]]; then
  export TERM=linux-16color  # use 16-color in TTY mode
fi


#### Helper functions ####
function has_command {
  command -v "$*" &> /dev/null
}

function makepkgclean {
  if ! [[ -f PKGBUILD ]]; then
    echo "PKGBUILD not detected."
    return 1
  fi
  for file in *; do
    [[ $file == PKGBUILD ]] && continue
    echo "Removing $file..."
    rm -rf "$file"
  done
}

function killregex {
  local regex="$1"; shift
  local args="$@"
  for p in $(ps -A | grep "$regex" | awk '{print $1}'); do
    kill $args $p
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

if has_command bat; then
  alias ccat='bat'
fi

if has_command rg; then
  alias rg='noglob rg'
  alias grep='rg'
  alias hgrep='history | noglob rg'
else
  alias hgrep='history | noglob grep'
fi

if has_command trash-put; then
  alias rrm='trash-put'
fi

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
  [[ -f $p10k_config ]] && source "$p10k_config"
}
