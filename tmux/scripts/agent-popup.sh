#!/usr/bin/env bash
# Per-window agent popup (toggle open/closed), one detached session per tmux
# window so each window gets its own agent instance even when sharing a cwd.
# Usage: agent-popup.sh <pi|hermes> [cwd]

AGENT="${1:?agent name required (pi|hermes)}"
CWD="${2:-}"

CURRENT_SESSION=$(tmux display-message -p '#{session_name}')

case "$CURRENT_SESSION" in
  ${AGENT}-*)
    # Already inside the agent's popup session: pop back out.
    tmux detach-client
    ;;
  *)
    WINDOW_ID=$(tmux display-message -p '#{window_id}')
    SESSION="${AGENT}-${WINDOW_ID#@}"
    case "$AGENT" in
      pi)     launch_cmd="pi" ;;
      hermes) launch_cmd="hermes chat" ;;
      *) echo "Unknown agent: $AGENT" >&2; exit 1 ;;
    esac
    tmux has-session -t "$SESSION" 2>/dev/null || \
      tmux new-session -d -s "$SESSION" -c "$CWD" "$launch_cmd"
    tmux display-popup -w 80% -h 80% -E "tmux attach-session -t $SESSION"
    ;;
esac
