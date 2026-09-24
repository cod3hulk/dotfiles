#!/usr/bin/env bash
# Highlights the focused AeroSpace workspace and hides empty, unfocused ones.
# $1 = workspace id this item represents (passed from sketchybarrc).
#
# Runs once per workspace item per event. With 16 workspaces that means 16
# invocations, so this stays a single aerospace call plus one sketchybar call.

source "$HOME/.config/sketchybar/colors.sh"

sid="$1"
[ -z "$sid" ] && exit 0

# Prefer the env var AeroSpace passes with exec-on-workspace-change (no
# subprocess), fall back to querying for events that don't provide it
# (front_app_switched, the initial trigger).
focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

# --count is cheaper than listing windows and counting lines.
window_count="$(aerospace list-windows --workspace "$sid" --count 2>/dev/null || echo 0)"

if [ "$sid" = "$focused" ]; then
  # Focused: always visible, ACTIVE background (matches borders active_color).
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color="$BAR_COLOR" \
    background.color="$ACTIVE" \
    background.drawing=on
elif [ "$window_count" -gt 0 ]; then
  # Occupied but not focused: visible, dimmed, no background fill.
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color="$WHITE" \
    background.color="$TRANSPARENT"
else
  # Empty and unfocused: hidden. Keeps the bar short despite 16 persistent
  # workspaces — they reappear the moment a window lands on them.
  # Reset the background too, otherwise a workspace that was focused when it
  # emptied keeps a stale ACTIVE fill and flashes purple when it reappears.
  sketchybar --set "$NAME" \
    drawing=off \
    icon.color="$WHITE" \
    background.color="$TRANSPARENT"
fi
