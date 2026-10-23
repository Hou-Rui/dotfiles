# Dotfiles

Personal Linux desktop configuration and fonts.

## Included configuration

- Zsh (including Powerlevel10k)
- KDE Plasma color schemes
- Neovim (0.12+)
- XTerm
- GTK 4
- Visual Studio Code
- Kate
- fontconfig defaults and CJK fallback configuration

## Included fonts

- Iosevka Custom
- HarmonyOS Sans
- MWCustom

The fonts are installed in `~/.local/share/fonts`, so installing them does not
require root privileges. The fontconfig files are installed in
`~/.config/fontconfig/conf.d`.

## Installation

Run the installer with no arguments to install all default targets, including
the bundled fonts and fontconfig files:

```sh
./install.sh
```

To install only the fonts and font configuration:

```sh
./install.sh fonts
```

The installer refreshes the fontconfig cache with `fc-cache` after installing
the fonts. Individual configuration groups can also be selected by passing one
or more targets: `zsh`, `nvim`, `kate`, `xres`, `gtk4`, or `fonts`.

