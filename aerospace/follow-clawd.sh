#!/bin/bash
# Keep the Clawd avatar and its paired interaction window on the active
# AeroSpace workspace. AeroSpace has no native sticky-window support.
set -u

focused_workspace="${AEROSPACE_FOCUSED_WORKSPACE:-}"
[[ -n "$focused_workspace" ]] || exit 0

aerospace_bin="/opt/homebrew/bin/aerospace"
[[ -x "$aerospace_bin" ]] || exit 0

# Query by bundle ID, not window title: Clawd owns a render window and a hit
# target window, and both must move together for the avatar to remain usable.
"$aerospace_bin" list-windows --monitor all --app-bundle-id com.clawd.on-desk --format '%{window-id}' |
while IFS= read -r window_id; do
  [[ -n "$window_id" ]] || continue
  "$aerospace_bin" move-node-to-workspace --window-id "$window_id" "$focused_workspace" >/dev/null 2>&1 || true
done
