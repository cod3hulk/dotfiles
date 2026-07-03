#!/usr/bin/env bash
# FZF-based pane search for tmux which-key.
# Centered popup; searches panes across all sessions; enter=switch, ctrl-x=kill.
tmux display-popup -E -w 60% -h 40% "
  target=\$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index}  #{pane_current_command}  #{pane_title}' |
    fzf --prompt='Pane> ' \
        --header='enter: switch  ctrl-x: kill' \
        --bind='ctrl-x:execute-silent(tmux kill-pane -t {1})+reload(tmux list-panes -a -F \"#{session_name}:#{window_index}.#{pane_index}  #{pane_current_command}  #{pane_title}\" 2>/dev/null)' |
    awk '{print \$1}')
  if [ -n \"\$target\" ]; then
    session=\${target%%:*}
    window=\${target%.*}
    tmux switch-client -t \"\$session\" \; select-window -t \"\$window\" \; select-pane -t \"\$target\"
  fi
"
