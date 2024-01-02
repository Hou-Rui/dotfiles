#### Powerlevel10k init
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#### Oh-My-Zsh plugins ####
plugins=(
    # builtin plugins
    command-not-found colored-man-pages dirhistory fancy-ctrl-z fd extract z
    # custom plugins
    auto-notify  # https://github.com/MichaelAquilina/zsh-auto-notify
    zsh-autosuggestions  # https://github.com/zsh-users/zsh-autosuggestions
    zsh-completions  # https://github.com/zsh-users/zsh-completions
    fast-syntax-highlighting  # https://github.com/zdharma-continuum/fast-syntax-highlighting
    custom-completions  # Home-made, no remote
)


#### Oh-My-Zsh config ####
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="$ZSH/cache/.zcompdump-$HOST"
export ZSH_THEME='powerlevel10k/powerlevel10k'
export HYPHEN_INSENSITIVE='true'
export DISABLE_AUTO_UPDATE='true'
export ENABLE_CORRECTION='false'
export PKGFILE_PROMPT_INSTALL_MISSING=1
export GROFF_NO_SGR=1
export CORRECT_IGNORE_FILE='.*'
source "$ZSH/oh-my-zsh.sh"


#### Environment Config ####
setopt no_nomatch
autoload -U zmv
export EDITOR='vim'  # symlink to `nvim`
export DIFFPROG='vimdiff'  # symlink to `nvim -d`
export SUDO='sudo'
export ARCHFLAGS='-arch x86_64'
export SAVEHIST=9999999


#### Search Paths ####
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.node_modules/bin:$PATH"
export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"
export PATH="/opt/android-sdk/cmdline-tools/latest/bin:$PATH"


#### Self-used environment variables ####
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_CONFIG_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"


#### General aliases ####
alias cls='clear'
alias py='python'
alias py3='python3'
alias ipy='ipython3'
alias ipython='ipython3'
alias exa='eza'
alias l='exa --long --all --header --git --icons'
alias la='l'
alias ls='exa'
alias tree='exa --tree --icons'
alias bc='bc -l'
alias ccat='bat'
alias src='omz reload'
alias mmv='noglob zmv -W'
alias tldr='cht.sh'
alias grep='rg'
alias rrm='trash-put'


#### XDG options ####
export ZSHZ_DATA="$XDG_DATA_HOME/zsh-z/.z"
compinit -d "$ZSH_COMPDUMP"


#### Package manager helper functions ####
makepkgclean() {
    if ! [[ -e 'PKGBUILD' ]]; then
        echo "PKGBUILD not detected."
        return 1
    fi
    for file in *; do
        [[ "$file" = 'PKGBUILD' ]] && continue
        echo "Removing $file..."
        rm -rf "$file"
    done
}

#### Editor shortcuts ####
zshrc()        { "$EDITOR" "$HOME/.zshrc" }
ohmyzsh()      { "$EDITOR" "$ZSH" }
vimrc()        { "$EDITOR" "$XDG_CONFIG_HOME/nvim/init.lua" }
omwcfg()       { "$EDITOR" "$XDG_CONFIG_HOME/openmw/openmw.cfg" }
omwsettings()  { "$EDITOR" "$XDG_CONFIG_HOME/openmw/settings.cfg" }


#### Locale shortcuts ####
alias zh='LC_ALL=zh_CN.utf-8'
alias jp='LC_ALL=ja_JP.utf-8'


#### Auto notification config ####
export AUTO_NOTIFY_THRESHOLD=30
export AUTO_NOTIFY_IGNORE=(
    'vim' 'zshrc' 'ohmyzsh' 'vimrc' 'vimplug'
    'omwcfg' 'omwsettings'
    'zsh' 'bash'
    'man' 'more' 'less'
)


#### History ####
hgrep() { history | rg "$*" }


#### Auto rehash executable completion ####
zstyle ':completion:*' rehash true
autoload -Uz compinit
compinit


#### Speed up copy & paste ####
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
    OLD_SELF_INSERT="${${(s.:.)widgets[self-insert]}[2,3]}"
    zle -N self-insert url-quote-magic
}

pastefinish() {
    zle -N self-insert "$OLD_SELF_INSERT"
}

zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish


#### Zsh help documentation ####
# https://wiki.archlinux.org/title/Zsh#Help_command
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help='run-help '


#### Process management
killregex() {
    local regex="$1"; shift
    local args="$@"
    for p in $(ps -A | grep "$regex" | awk '{print $1}'); do
        kill $args $p
    done
}


#### TTY TERM settings
if [[ "$TERM" == 'linux' ]]; then
    export TERM=linux-16color
fi


#### Powerlevel10k customization
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

