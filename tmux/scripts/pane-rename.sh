#!/usr/bin/env bash
# Popup-based pane rename (pane title) for tmux which-key

current_name=$(tmux display-message -p '#T')

# Dracula theme colors
PURPLE='\033[1;35m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
GRAY='\033[0;37m'
RESET='\033[0m'

tmux display-popup -E -w 40% -h 30% "bash -c '
# Trap Ctrl+C to exit cleanly
trap \"exit 0\" INT

echo -e \"${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\"
echo -e \"  ${CYAN}Rename Pane${RESET}\"
echo -e \"${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\"
echo -e \"\"
echo -e \"  Current: ${GREEN}$current_name${RESET}\"
echo -e \"\"
echo -e \"  ${GRAY}Press Ctrl+C to cancel${RESET}\"
echo -e \"${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\"
echo \"\"
echo -ne \"${CYAN}New name:${RESET} \"

# Read with interrupt handling
if read -e new_name; then
  if [ -n \"\$new_name\" ]; then
    tmux select-pane -T \"\$new_name\"
  fi
fi
'"
