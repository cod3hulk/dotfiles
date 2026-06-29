#!/usr/bin/env bash
# FZF-based session search for tmux which-key.
# Centered popup; on selection switch the client to the chosen session.
tmux display-popup -E -w 60% -h 40% '
  target=$(tmux list-sessions -F "#{session_name}" | fzf --prompt="Session> ")
  [ -n "$target" ] && tmux switch-client -t "$target"
'
