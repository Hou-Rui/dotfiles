#!/bin/bash
set -eu

CURDIR="$(dirname "$(readlink -f "$0")")"
REMOTE=

home_ins() {
  for f in "$@"; do
    echo "Installing $f"
    SRC="$CURDIR/$f" DEST="$HOME/$f"
    if [ -e "$DEST" ]; then
      rm -rf "$DEST"
    fi
    cp -rf "$SRC" "$DEST"
    if ! [ -z "$REMOTE" ]; then
      scp -r "$SRC" "$REMOTE:~/$f" 
    fi
  done
}

home_ins_targets() {
  for target in "$@"; do
    case "$target" in
      ('zsh')  home_ins '.zshrc' '.p10k.zsh';;
      ('nvim') home_ins '.config/nvim'/**;;
      ('gtk4') REMOTE= home_ins '.config/gtk-4.0'/**;;
      ('kate') REMOTE= home_ins '.config/kate'/**;;
      ('xres') REMOTE= home_ins '.Xresources';;
      (*) echo "Unknown target $target"; exit 1
    esac
  done
}

while getopts w: opt; do
  case "$opt" in
    (w) REMOTE="$OPTARG";;
    (?) echo "Unknown option $opt"; exit 2
  esac
done
shift $(($OPTIND - 1))

if [ $# -eq 0 ]; then
  home_ins_targets 'zsh' 'nvim' 'kate' 'xres' 'gtk4'
else
  home_ins_targets "$@"
fi

