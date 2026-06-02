#!/usr/bin/env bash
# FZF-based window search for tmux which-key
tmux display-popup -E -w 60% -h 40% "tmux list-windows -F '#{window_name}' | fzf | xargs -I {} tmux select-window -t {}"
