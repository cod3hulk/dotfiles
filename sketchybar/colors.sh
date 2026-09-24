#!/usr/bin/env bash
# Dracula palette — the repo-wide theme (see CLAUDE.md).
# ACTIVE/INACTIVE intentionally mirror borders/bordersrc so window borders and
# the bar highlight the same focus state in the same colours.

export TRANSPARENT=0x00000000

# Bar surface
export BAR_COLOR=0xe61e1f29       # Dracula bg, ~90% opaque
export BAR_BORDER_COLOR=0xff44475a

# Foreground
export WHITE=0xfff8f8f2           # Dracula foreground
export COMMENT=0xff6272a4         # Dracula comment — dimmed text

# Accents
export PURPLE=0xffbd93f9          # matches borders active_color
export CYAN=0xff8be9fd
export GREEN=0xff50fa7b
export ORANGE=0xffffb86c
export PINK=0xffff79c6
export RED=0xffff5555
export YELLOW=0xfff1fa8c

# Semantic aliases — use these in plugins so a palette tweak is one-line.
export ACTIVE=$PURPLE             # borders active_color
export INACTIVE=$COMMENT          # borders inactive_color
export ITEM_BG=0xff282a36         # Dracula current-line, for item backgrounds
