#!/bin/bash
set -eu

CURDIR="$(dirname "$(readlink -f "$0")")"
REMOTE=

cd "$CURDIR"

home_ins() {
  local SRC DEST

  for f in "$@"; do
    echo "Installing $f"
    SRC="$CURDIR/$f" DEST="$HOME/$f"
    mkdir -p "$(dirname "$DEST")"
    if [ -e "$DEST" ]; then
      rm -rf -- "$DEST"
    fi
    cp -a -- "$SRC" "$DEST"
    if [ -n "$REMOTE" ]; then
      scp -r "$SRC" "$REMOTE:~/$f"
    fi
  done
}

home_ins_local() {
  local saved_remote="$REMOTE"
  REMOTE=
  home_ins "$@"
  REMOTE="$saved_remote"
}

refresh_font_cache() {
  if command -v fc-cache >/dev/null 2>&1; then
    echo "Refreshing the local font cache"
    fc-cache -f
  else
    echo "Warning: fc-cache is unavailable; refresh the font cache manually" >&2
  fi

  if [ -n "$REMOTE" ]; then
    ssh "$REMOTE" 'if command -v fc-cache >/dev/null 2>&1; then fc-cache -f; else echo "Warning: fc-cache is unavailable; refresh the font cache manually" >&2; fi'
  fi
}

font_ins() {
  if [ -n "$REMOTE" ]; then
    ssh "$REMOTE" mkdir -p -- .config/fontconfig/conf.d .local/share/fonts
  fi

  home_ins \
    '.config/fontconfig/conf.d/10-fonts.conf' \
    '.config/fontconfig/conf.d/50-default.conf' \
    '.config/fontconfig/conf.d/60-iosevka-custom.conf' \
    '.config/fontconfig/conf.d/99-cjk.conf' \
    '.local/share/fonts/IosevkaCustom' \
    '.local/share/fonts/MWCustom' \
    '.local/share/fonts/harmonyos-sans'
  refresh_font_cache
}

home_ins_targets() {
  for target in "$@"; do
    case "$target" in
      ('zsh')  home_ins '.zshrc' '.p10k.zsh';;
      ('nvim') home_ins '.config/nvim'/**;;
      ('gtk4') home_ins_local '.config/gtk-4.0'/**;;
      ('kate') home_ins_local '.config/kate'/**;;
      ('xres') home_ins_local '.Xresources';;
      ('fonts') font_ins;;
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
shift $((OPTIND - 1))

if [ "$#" -eq 0 ]; then
  home_ins_targets 'zsh' 'nvim' 'kate' 'xres' 'gtk4' 'fonts'
else
  home_ins_targets "$@"
fi

