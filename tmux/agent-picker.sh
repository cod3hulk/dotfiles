#!/usr/bin/env bash
# Fuzzy picker for tmux panes with agents in needs-input or done state.
# Reads state from TMUX_AGENT_PANE_<id>_STATE env vars set by tmux-agent-indicator.

set -u

state_icon() {
  case "$1" in
    needs-input) printf '🔴' ;;
    done)        printf '🟢' ;;
    running)     printf '🟡' ;;
    *)           printf '⚪' ;;
  esac
}

state_rank() {
  case "$1" in
    needs-input) printf '0' ;;
    done)        printf '1' ;;
    *)           printf '2' ;;
  esac
}

rows=""
while IFS= read -r line; do
  [ -n "$line" ] || continue
  key="${line%%=*}"
  state="${line#*=}"
  pane="${key#TMUX_AGENT_PANE_}"
  pane="${pane%_STATE}"

  case "$state" in needs-input|done) ;; *) continue ;; esac

  info=$(tmux display-message -p -t "$pane" \
    '#{session_name}'$'\t''#{window_id}'$'\t''#{window_index}'$'\t''#{window_name}' \
    2>/dev/null) || continue
  [ -n "$info" ] || continue

  agent_line=$(tmux show-environment -g "TMUX_AGENT_PANE_${pane}_AGENT" 2>/dev/null) || agent_line=""
  agent="${agent_line#*=}"
  [ "$agent" = "$agent_line" ] && agent="?"

  rank=$(state_rank "$state")
  icon=$(state_icon "$state")
  IFS=$'\t' read -r session window_id window_index window_name <<<"$info"

  display=$(printf '%s  %-7s %s:%s %s' "$icon" "$agent" "$session" "$window_index" "$window_name")
  rows+="${rank}"$'\t'"${pane}"$'\t'"${session}"$'\t'"${window_id}"$'\t'"${display}"$'\n'
done < <(tmux show-environment -g 2>/dev/null | grep '^TMUX_AGENT_PANE_.*_STATE=')

if [ -z "$rows" ]; then
  echo "No agents need attention."
  sleep 1.2
  exit 0
fi

selection=$(printf '%s' "$rows" \
  | sort -t$'\t' -k1,1 \
  | fzf --ansi --with-nth=5 -d $'\t' --no-sort \
        --header='enter: jump  ·  esc: cancel' \
        --preview='tmux capture-pane -p -t {2} | tail -40' \
        --preview-window=down:60%:wrap) || exit 0

IFS=$'\t' read -r _ pane session window_id _ <<<"$selection"
[ -n "$pane" ] || exit 0

tmux switch-client -t "$session"
tmux select-window -t "$window_id"
tmux select-pane -t "$pane"
