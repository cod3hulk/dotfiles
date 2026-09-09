#!/usr/bin/env bash
# Smart pane navigation for herdr, replicating tmux's vim-tmux-navigator.
#
# Bound to ctrl+h/j/k/l in herdr/config.toml as `type = "shell"` entries.
# Herdr sits upstream of every pane, so it intercepts ctrl+hjkl before the
# focused program sees it. This wrapper decides what to do:
#
#   * If the focused pane is running Neovim/Vim, forward the key to that pane
#     with `herdr pane send-keys`. nvim's own navigator (nvim/lua/user/navigator.lua)
#     then moves its window cursor, or — at a window edge — calls
#     `herdr pane focus` to switch herdr panes.
#   * Otherwise, focus the neighbouring herdr pane directly.
#
# This is exactly the tmux `is_vim` check, implemented as a detached herdr
# shell command. Herdr gives the command HERDR_ACTIVE_PANE_ID, HERDR_BIN_PATH,
# and HERDR_SOCKET_PATH.
set -euo pipefail

DIR="${1:?direction required (left|down|up|right)}"
KEY="${2:?key required (e.g. ctrl+h)}"
PANE="${HERDR_ACTIVE_PANE_ID:-}"
HERDR="${HERDR_BIN_PATH:-herdr}"

[ -n "$PANE" ] || { printf 'navigate: no HERDR_ACTIVE_PANE_ID\n' >&2; exit 0; }

# Read the focused pane's foreground process. foreground_processes is a list;
# take the first entry's argv0/name. A fresh pane may briefly report `env` or
# the shell launcher, which is fine: it is not an editor, so we fall through to
# pane focus, which is a no-op when there is no neighbour.
proc=$("$HERDR" pane process-info --pane "$PANE" 2>/dev/null | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("")
    sys.exit(0)
ps = d.get("result", {}).get("process_info", {}).get("foreground_processes", [])
if not ps:
    print("")
    sys.exit(0)
p = ps[0]
name = (p.get("argv0") or p.get("name") or "").rsplit("/", 1)[-1]
print(name)
' 2>/dev/null || true)

case "$proc" in
  nvim|nvim.bin|vim|vim.bin|vi|nvim-open-term)
    # Editor owns intra-window ctrl+hjkl; let it decide, including edge handoff.
    "$HERDR" pane send-keys "$PANE" "$KEY" >/dev/null 2>&1 || true
    ;;
  *)
    # Not an editor: move focus to the neighbouring herdr pane.
    "$HERDR" pane focus --pane "$PANE" --direction "$DIR" >/dev/null 2>&1 || true
    ;;
esac

exit 0
