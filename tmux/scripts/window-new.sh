#!/usr/bin/env bash
# Popup-based new window creation for tmux which-key

# Get the next window index
next_index=$(tmux display-message -p '#{session_windows}')
next_index=$((next_index + 1))
default_name="window-$next_index"

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
echo -e \"  ${CYAN}Create New Window${RESET}\"
echo -e \"${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\"
echo -e \"\"
echo -e \"  Default: ${GREEN}$default_name${RESET}\"
echo -e \"\"
echo -e \"  ${GRAY}Press Enter for default, Ctrl+C to cancel${RESET}\"
echo -e \"${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\"
echo \"\"
echo -ne \"${CYAN}Window name:${RESET} \"

# Read with interrupt handling
if read -e window_name; then
  # Use default if empty
  if [ -z \"\$window_name\" ]; then
    window_name=\"$default_name\"
  fi
  tmux new-window -c ~ -n \"\$window_name\"
fi
'"
