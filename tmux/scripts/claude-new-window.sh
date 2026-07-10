#!/usr/bin/env bash
# Create a new window, name it claude-<prompt>, and launch yolo with the prompt

if [ "$1" != "--popup" ]; then
  exec tmux display-popup -E -w 50% -h 30% "$0 --popup"
fi

# Dracula theme colors
PURPLE=$'\033[1;35m'
CYAN=$'\033[1;36m'
GRAY=$'\033[0;37m'
RESET=$'\033[0m'

# Readline-safe wrappers so `read -e` computes prompt width correctly
RL_CYAN=$'\001\033[1;36m\002'
RL_RESET=$'\001\033[0m\002'

trap "exit 0" INT

printf '%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n' "$PURPLE" "$RESET"
printf '  %sNew Claude Window%s\n' "$CYAN" "$RESET"
printf '%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n' "$PURPLE" "$RESET"
printf '\n'
printf '\n'  # reserved: readline input line
printf '\n'
printf '  %sPress Ctrl+C to cancel%s\n' "$GRAY" "$RESET"
# Move cursor back up to the reserved input line (3 lines up from below the hint)
printf '\033[3A'

if read -e -p "${RL_CYAN}Prompt:${RL_RESET} " prompt; then
  if [ -n "$prompt" ]; then
    slug=$(echo "$prompt" | tr -cs "a-zA-Z0-9" "-" | tr "[:upper:]" "[:lower:]" | sed "s/^-//;s/-$//" | cut -c1-40)
    window_name="claude-$slug"
    tmux new-window -n "$window_name" -c "#{pane_current_path}" "claude --dangerously-skip-permissions --remote-control --permission-mode plan \"$prompt\""
  fi
fi
