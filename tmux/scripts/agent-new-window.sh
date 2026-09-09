#!/usr/bin/env bash
# Create a new window, name it <agent>-<prompt-slug>, and launch the agent
# seeded with the given prompt.
# Usage: agent-new-window.sh <pi|hermes>

AGENT="${1:?agent name required (pi|hermes)}"

if [ "$2" != "--popup" ]; then
  exec tmux display-popup -E -w 50% -h 30% "$0 $AGENT --popup"
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
printf '  %sNew %s Window%s\n' "$CYAN" "$AGENT" "$RESET"
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
    window_name="${AGENT}-${slug}"
    case "$AGENT" in
      pi)     launch_cmd="pi \"$prompt\"" ;;
      hermes) launch_cmd="hermes chat -q \"$prompt\"" ;;
      *) echo "Unknown agent: $AGENT" >&2; exit 1 ;;
    esac
    tmux new-window -n "$window_name" -c "#{pane_current_path}" "$launch_cmd"
  fi
fi
