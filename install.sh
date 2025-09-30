#!/bin/sh
set -eu

CURDIR="$(dirname "$(readlink -f "$0")")"

home_ins() {
  for f in "$@"; do
    SRC="$CURDIR/$1" DEST="$HOME/$1"
    ln -sf "$SRC" "$DEST"
  done
}

home_ins_targets() {
  for target in "$@"; do
    case "$target" in
      ('zsh')  home_ins '.zshrc' '.p10k.zsh';;
      ('nvim') home_ins '.config/nvim/init.lua';;
      ('gtk4') home_ins '.config/gtk-4.0/gtk.css';;
      (*) echo "Unknown target $target"; exit 1
    esac
  done
}

if [ $# -eq 0 ]; then
  home_ins_targets 'zsh' 'nvim' 'gtk4'
else
  home_ins_targets "$@"
fi

