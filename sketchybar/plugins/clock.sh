#!/usr/bin/env bash
# Date + 24h time, matching the European format used elsewhere in the repo.
sketchybar --set "$NAME" label="$(date '+%a %d %b %H:%M')"
