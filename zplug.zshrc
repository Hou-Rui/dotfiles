# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### plugins

source ~/.zplug/init.zsh

function has_command {
  command -v "$*" &> /dev/null
}

zplug "robbyrussell/oh-my-zsh", use:"lib/*.zsh", defer:0
zplug "plugins/command-not-found", from:oh-my-zsh, defer:1
zplug "plugins/dirhistory", from:oh-my-zsh, defer:1
zplug "agkozak/zsh-z"
zplug "le0me55i/zsh-extract"
zplug "ael-code/zsh-colored-man-pages"
zplug "zdharma-continuum/fast-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug 'knu/zsh-manydots-magic', use:manydots-magic, defer:3
zplug "romkatv/powerlevel10k", use:powerlevel10k.zsh-theme
zplug "MichaelAquilina/zsh-auto-notify", if:"has_command notify-send"

export PATH="$HOME/.wine/drive_c/windows:$PATH"
export PATH="$HOME/.wine/drive_c/windows/system32:$PATH"

if [[ "$TERM" == 'linux' ]]; then
    export TERM=linux-16color
fi

# if has_command notify-send; then
#   zplug 'MichaelAquilina/zsh-auto-notify'
# fi

zplug load


### environment variables

export EDITOR='nvim'
export VISUAL='nvim'
export HISTFILE=~/.zhistory
export HISTSIZE=50000
export SAVEHIST=50000
export COLORTERM=truecolor
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export GROFF_NO_SGR=1
export WINEDEBUG=-all

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

### Auto rehash executable completion

zstyle ':completion:*' rehash true
zstyle ':completion:*:functions' ignored-patterns '_*'

### Speed up copy & paste

pasteinit() {
    OLD_SELF_INSERT="${${(s.:.)widgets[self-insert]}[2,3]}"
    zle -N self-insert url-quote-magic
}

pastefinish() {
    zle -N self-insert "$OLD_SELF_INSERT"
}

zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

### functions

function zshrc {
  "$EDITOR" "$HOME/.zshrc"
}
function vimrc {
  "$EDITOR" "$HOME/.config/nvim/init.lua"
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
  history | grep "$*" -
}

function killregex {
    local regex="$1"; shift
    local args="$@"
    for p in $(ps -A | grep "$regex" | awk '{print $1}'); do
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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
