#!/usr/bin/env bash
# Wrapper script for Claude Code popup (toggle open/closed)
CURRENT_SESSION=$(tmux display-message -p '#{session_name}')

case "$CURRENT_SESSION" in
  claude-*)
    tmux detach-client
    ;;
  *)
    SESSION="claude-$(echo $1 | shasum | cut -c1-8)"
    tmux has-session -t "$SESSION" 2>/dev/null || \
      tmux new-session -d -s "$SESSION" -c "$1" "claude"
    tmux display-popup -w 80% -h 80% -E "tmux attach-session -t $SESSION"
    ;;
esac
