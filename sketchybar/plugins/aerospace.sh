#!/usr/bin/env bash
# Repaints every AeroSpace workspace item in one pass.
#
# Deliberately NOT a per-item script. Each `aerospace` CLI call costs ~45ms, so
# the original design — one script invocation per workspace item, each making its
# own `list-workspaces --focused` and `list-windows --count` calls — cost ~1.3s
# per workspace switch on a 16-workspace setup and felt visibly laggy.
#
# This version makes two aerospace calls total (or one when the focused
# workspace arrives via $FOCUSED_WORKSPACE) and sends a single batched
# sketchybar message, bringing a switch to well under 100ms.

source "$HOME/.config/sketchybar/colors.sh"

# AeroSpace passes $AEROSPACE_FOCUSED_WORKSPACE through exec-on-workspace-change,
# which sketchybarrc forwards as FOCUSED_WORKSPACE. on-focus-changed sends no env
# var, so fall back to querying.
focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

# One call yields the workspace of every window; counting duplicates gives the
# per-workspace window count without a query per workspace.
occupied=" $(aerospace list-windows --all --format '%{workspace}' 2>/dev/null \
  | sort -u | tr '\n' ' ')"

# Build one message so the bar repaints atomically instead of item by item.
args=()
for sid in $(aerospace list-workspaces --all); do
  if [ "$sid" = "$focused" ]; then
    # Focused: always visible, ACTIVE fill (matches borders active_color).
    args+=(--set "space.$sid"
      drawing=on
      icon.color="$BAR_COLOR"
      background.color="$ACTIVE"
      background.drawing=on)
  elif [[ "$occupied" == *" $sid "* ]]; then
    # Occupied but not focused: visible, no fill.
    args+=(--set "space.$sid"
      drawing=on
      icon.color="$WHITE"
      background.color="$TRANSPARENT")
  else
    # Empty and unfocused: hidden, so 16 persistent workspaces don't crowd the
    # bar. Reset colours too, otherwise a workspace that was focused when it
    # emptied keeps a stale ACTIVE fill and flashes purple when it reappears.
    args+=(--set "space.$sid"
      drawing=off
      icon.color="$WHITE"
      background.color="$TRANSPARENT")
  fi
done

sketchybar "${args[@]}"
