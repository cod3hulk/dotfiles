#!/usr/bin/env bash
# Create a new window and launch the agent's session resume/picker.
# Usage: agent-resume-window.sh <pi|hermes>

AGENT="${1:?agent name required (pi|hermes)}"

case "$AGENT" in
  # `pi --resume` opens an interactive session picker.
  # `hermes sessions browse` is an interactive picker: browse, search, resume.
  pi)     launch_cmd="pi --resume" ;;
  hermes) launch_cmd="hermes sessions browse" ;;
  *) echo "Unknown agent: $AGENT" >&2; exit 1 ;;
esac

tmux new-window -n "${AGENT}-resume" -c "#{pane_current_path}" "$launch_cmd"
