#!/usr/bin/env bash
# FZF-based session search for tmux which-key.
# Centered popup; enter=switch, ctrl-x=kill.
tmux display-popup -E -w 60% -h 40% "
  target=\$(tmux list-sessions -F '#{session_name}' |
    fzf --prompt='Session> ' \
        --header='enter: switch  ctrl-x: kill' \
        --bind='ctrl-x:execute-silent(tmux kill-session -t {1})+reload(tmux list-sessions -F #{session_name} 2>/dev/null)')
  [ -n \"\$target\" ] && tmux switch-client -t \"\$target\"
"
