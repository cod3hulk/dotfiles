#!/usr/bin/env bash
# Battery percentage with a Nerd Font icon ramp; colour warns only when low so
# the bar stays visually quiet in normal use.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

battery_info="$(pmset -g batt)"
percentage="$(echo "$battery_info" | grep -Eo '[0-9]+%' | head -1 | cut -d% -f1)"
charging="$(echo "$battery_info" | grep 'AC Power')"

# Desktop / no battery reported: hide the item entirely.
if [ -z "$percentage" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ -n "$charging" ]; then
  icon="$BATT_CHARGING"
  color="$GREEN"
else
  case "${percentage}" in
    9[0-9] | 100) icon="$BATT_100" ;;
    [6-8][0-9]) icon="$BATT_75" ;;
    [3-5][0-9]) icon="$BATT_50" ;;
    [1-2][0-9]) icon="$BATT_25" ;;
    *) icon="$BATT_0" ;;
  esac

  if [ "$percentage" -le 10 ]; then
    color="$RED"
  elif [ "$percentage" -le 20 ]; then
    color="$ORANGE"
  else
    color="$WHITE"
  fi
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon="$icon" \
  icon.color="$color" \
  label="${percentage}%"
