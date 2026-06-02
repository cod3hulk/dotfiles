#!/usr/bin/env bash
# FZF-based session search for tmux which-key
tmux display-popup -E -w 60% -h 40% "tmux list-sessions -F '#{session_name}' | fzf | xargs tmux switch-client -t"
