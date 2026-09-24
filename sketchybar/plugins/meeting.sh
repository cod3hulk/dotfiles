#!/usr/bin/env bash
# Next calendar meeting, read from EventKit via icalBuddy.
#
# Reads the same calendars macOS Calendar sees, which is NOT where MeetingBar
# gets its data — MeetingBar talks to the Google Calendar API directly. For the
# work calendar to appear here it must be added under
# System Settings -> Internet Accounts (see sketchybar/README.md). Until then
# this item simply hides itself, and MeetingBar keeps working unchanged.
#
# Colour escalates as the meeting approaches: white -> orange (<=15min)
# -> red (<=5min), so a glance at the bar conveys urgency.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

LOOKAHEAD_HOURS=12
# Keep showing a meeting this long after it started, then move to the next one.
STALE_AFTER_MIN=15
# Truncate long meeting titles so one bad invite can't push the clock offscreen.
MAX_TITLE_LEN=28

ICALBUDDY="$(command -v icalBuddy || echo /opt/homebrew/bin/icalBuddy)"
if [ ! -x "$ICALBUDDY" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

end_time="$(date -v+${LOOKAHEAD_HOURS}H '+%Y-%m-%d %H:%M')"

# -npn drops property names, -ea excludes all-day events, -nc drops calendar
# names, -eed excludes end datetimes. Fetch several events so stale in-progress
# ones can be skipped.
#
# In -ps the pipes are delimiters, not part of the separator, so "|@@|" yields a
# literal "@@" between title and datetime. Events are prefixed with <<<E>>> via
# -b, a marker chosen not to collide with event text.
raw="$("$ICALBUDDY" -npn -nc -nrd -ea -eed -li 5 \
  -b "<<<E>>>" -ss "" \
  -df "%Y-%m-%d" -tf "%H:%M" \
  -iep "title,datetime" \
  -ps "|@@|" \
  eventsFrom:"now" to:"$end_time" 2>/dev/null)"

if [ -z "$raw" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

now_epoch="$(date +%s)"
title=""
mins_until=""

# Each event begins with the <<<E>>> marker; title and datetime are separated
# by the |@@| property separator.
while IFS= read -r event; do
  [ -z "$event" ] && continue

  event_title="${event%%@@*}"
  datetime="${event#*@@}"
  # Trim surrounding whitespace.
  event_title="$(echo "$event_title" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  # icalBuddy renders datetime as "2026-09-24 at 13:57", so date and time are
  # extracted independently rather than parsed as one string. A missing time
  # means an all-day event, which is skipped.
  event_date="$(echo "$datetime" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)"
  event_time="$(echo "$datetime" | grep -oE '[0-9]{2}:[0-9]{2}' | head -1)"
  [ -z "$event_date" ] || [ -z "$event_time" ] && continue

  event_epoch="$(date -j -f '%Y-%m-%d %H:%M' "$event_date $event_time" '+%s' 2>/dev/null)"
  [ -z "$event_epoch" ] && continue

  delta_min=$(((event_epoch - now_epoch) / 60))

  # Skip meetings that started more than STALE_AFTER_MIN ago.
  if [ "$delta_min" -lt "-$STALE_AFTER_MIN" ]; then
    continue
  fi

  title="$event_title"
  mins_until="$delta_min"
  break
done <<EOF
$(printf '%s' "${raw//<<<E>>>/$'\n'}")
EOF

if [ -z "$title" ] || [ -z "$mins_until" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "${#title}" -gt "$MAX_TITLE_LEN" ]; then
  title="${title:0:$MAX_TITLE_LEN}…"
fi

# Relative time reads faster than a clock time for imminent meetings.
if [ "$mins_until" -le 0 ]; then
  when="now"
  color="$RED"
elif [ "$mins_until" -le 5 ]; then
  when="${mins_until}m"
  color="$RED"
elif [ "$mins_until" -le 15 ]; then
  when="${mins_until}m"
  color="$ORANGE"
elif [ "$mins_until" -lt 60 ]; then
  when="${mins_until}m"
  color="$WHITE"
else
  hours=$((mins_until / 60))
  mins=$((mins_until % 60))
  if [ "$mins" -eq 0 ]; then
    when="${hours}h"
  else
    when="${hours}h${mins}m"
  fi
  color="$WHITE"
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon="$ICON_CALENDAR" \
  icon.color="$color" \
  label="$title · $when" \
  label.color="$color"
