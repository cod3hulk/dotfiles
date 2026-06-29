#!/usr/bin/env bash
# FZF-based window search for tmux which-key.
# Centered popup; searches windows across all sessions and switches on selection.
tmux display-popup -E -w 60% -h 40% '
  target=$(tmux list-windows -a -F "#{session_name}:#{window_index}  #{window_name}" \
    | fzf --prompt="Window> " | cut -d" " -f1)
  if [ -n "$target" ]; then
    session=${target%%:*}
    tmux switch-client -t "$session" \; select-window -t "$target"
  fi
'
