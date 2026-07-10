#!/usr/bin/env bash
# Create a new window, name it claude-<prompt>, and launch yolo with the prompt

PURPLE='\033[1;35m'
CYAN='\033[1;36m'
GRAY='\033[0;37m'
RESET='\033[0m'

tmux display-popup -E -w 50% -h 30% "bash -c '
trap \"exit 0\" INT

echo -e \"${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\"
echo -e \"  ${CYAN}New Claude Window${RESET}\"
echo -e \"${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\"
echo \"\"
echo -e \"  ${GRAY}Press Ctrl+C to cancel${RESET}\"
echo \"\"
echo -ne \"${CYAN}Prompt:${RESET} \"

if read -e prompt; then
  if [ -n \"\$prompt\" ]; then
    slug=\$(echo \"\$prompt\" | tr -cs \"a-zA-Z0-9\" \"-\" | tr \"[:upper:]\" \"[:lower:]\" | sed \"s/^-//;s/-$//\" | cut -c1-40)
    window_name=\"claude-\$slug\"
    tmux new-window -n \"\$window_name\" -c \"#{pane_current_path}\"
    tmux send-keys \"yolo \\\"\$prompt\\\"\" Enter
  fi
fi
'"
