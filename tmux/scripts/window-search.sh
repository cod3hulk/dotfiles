#!/usr/bin/env bash
# FZF-based window search for tmux which-key.
# Centered popup; searches windows across all sessions; enter=switch, ctrl-x=kill.
tmux display-popup -E -w 60% -h 40% "
  target=\$(tmux list-windows -a -F '#{session_name}:#{window_index}  #{window_name}' |
    fzf --prompt='Window> ' \
        --header='enter: switch  ctrl-x: kill' \
        --bind='ctrl-x:execute-silent(tmux kill-window -t {1})+reload(tmux list-windows -a -F \"#{session_name}:#{window_index}  #{window_name}\" 2>/dev/null)' |
    awk '{print \$1}')
  if [ -n \"\$target\" ]; then
    session=\${target%%:*}
    tmux switch-client -t \"\$session\" \; select-window -t \"\$target\"
  fi
"
