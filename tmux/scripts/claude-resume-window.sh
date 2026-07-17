#!/usr/bin/env bash
# Create a new window and launch yolo with --resume to open the resume dialog

tmux new-window -n "claude-resume" -c "#{pane_current_path}" "claude --dangerously-skip-permissions --remote-control --permission-mode plan --resume"
