#!/usr/bin/env bash
# Shows the focused application name in the bar centre.
# $INFO is provided by sketchybar for the front_app_switched event.

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi
