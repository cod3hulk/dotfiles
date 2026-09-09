#!/usr/bin/env bash
# Create a new Herdr tab and launch a coding agent (pi or hermes) in it.
#
# Used two ways:
#   1. Detached, from a herdr-which-key overlay `shell` entry (no TTY, no prompt):
#        agent-new-tab.sh <pi|hermes>
#   2. From the interactive `prefix+shift+a` popup (agent-new-tab-prompt.sh),
#      which collects an agent and a prompt and hands them off here:
#        agent-new-tab.sh <pi|hermes> "<prompt>"
#
# When a prompt is supplied it is submitted to the agent after start via
# `herdr agent prompt` (without --wait) so the calling popup can close
# immediately while the agent runs in its new tab.
#
# Herdr gives popup/detached commands HERDR_ACTIVE_PANE_CWD and
# HERDR_ACTIVE_WORKSPACE_ID, so the new tab follows the origin pane's cwd and
# lands in the same workspace.
set -euo pipefail

AGENT="${1:?agent name required (pi|hermes)}"; shift || true
PROMPT="${1:-}"
case "$AGENT" in
  p|pi)     AGENT=pi ;;
  h|hermes) AGENT=hermes ;;
  *) printf 'agent-new-tab: unknown agent %s\n' "$AGENT" >&2; exit 1 ;;
esac

CWD="${HERDR_ACTIVE_PANE_CWD:-$PWD}"
WS="${HERDR_ACTIVE_WORKSPACE_ID:-}"
ws_flag=()
[ -n "$WS" ] && ws_flag=(--workspace "$WS")

if [ -n "$PROMPT" ]; then
  slug=$(printf '%s' "$PROMPT" | tr -cs 'a-zA-Z0-9' '-' \
         | tr '[:upper:]' '[:lower:]' | sed 's/^-//;s/-$//' | cut -c1-40)
  label="${AGENT}-${slug}"
else
  label="$AGENT"
fi

# Snapshot existing tabs before the create so we can identify the new tab
# regardless of the shape `herdr tab create` returns.
before=$(herdr tab list "${ws_flag[@]}" 2>/dev/null || true)

herdr tab create --cwd "$CWD" --label "$label" --focus "${ws_flag[@]}" >/dev/null

after=$(herdr tab list "${ws_flag[@]}" 2>/dev/null || true)
tab_id=$(python3 -c '
import json, sys
b = json.loads(sys.argv[1] or "{}").get("result", {}).get("tabs", [])
a = json.loads(sys.argv[2] or "{}").get("result", {}).get("tabs", [])
have = {t.get("tab_id") for t in b}
new = [t.get("tab_id") for t in a if t.get("tab_id") and t.get("tab_id") not in have]
print(new[0] if new else "")
' "$before" "$after")
if [ -z "$tab_id" ]; then
  printf 'agent-new-tab: could not locate the new tab\n' >&2
  exit 1
fi

# Find the single pane of the new tab.
pane_id=$(herdr pane list "${ws_flag[@]}" 2>/dev/null | python3 -c '
import json, sys
tid = sys.argv[1]
panes = json.load(sys.stdin).get("result", {}).get("panes", [])
print(next((p.get("pane_id") for p in panes if p.get("tab_id") == tid), ""))
' "$tab_id")
if [ -z "$pane_id" ]; then
  printf 'agent-new-tab: no pane found for tab %s\n' "$tab_id" >&2
  exit 1
fi

# `agent start` waits for the pane to reach interactive readiness (default 30s
# timeout), but it first checks the pane is an "available shell". A brand-new
# pane can fail that pre-check with `agent_pane_busy` if its shell has not
# finished spawning yet — a race that returns immediately, before the readiness
# wait begins. Retry a few times with a short backoff so the shell has a chance
# to come up. This is the tmux `new-window "<agent>"` equivalent.
#
# Agent names must be lowercase (letters, digits, '-', '_'); pane ids contain
# uppercase hex, so lowercase the suffix.
name="${AGENT}-$(printf '%s' "${pane_id#*:}" | tr '[:upper:]' '[:lower:]')"
start_ok=0
for attempt in 1 2 3 4 5 6; do
  out=$(herdr agent start "$name" --kind "$AGENT" --pane "$pane_id" 2>&1 || true)
  if printf '%s' "$out" | grep -q '"agent_started"'; then
    start_ok=1
    break
  fi
  if ! printf '%s' "$out" | grep -q 'agent_pane_busy'; then
    # A different error will not fix itself with a retry; report and bail.
    printf 'agent-new-tab: agent start failed: %s\n' "$out" >&2
    exit 1
  fi
  sleep 0.5
done
if [ "$start_ok" -ne 1 ]; then
  printf 'agent-new-tab: pane %s never became an available shell\n' "$pane_id" >&2
  exit 1
fi

if [ -n "$PROMPT" ]; then
  # Submit without --wait so we do not hold the popup open for the whole run.
  herdr agent prompt "$pane_id" "$PROMPT" >/dev/null
fi
