#!/usr/bin/env bash
set -euo pipefail

calendar="${WAYBAR_GCALCLI_CALENDAR:-}"
range_start="now"
range_end="7d"

text=$(date '+%d-%m-%Y  %H:%M')
calendar_text=$(cal)

calendar_args=()
if [ -n "$calendar" ]; then
  calendar_args=(--calendar "$calendar")
fi

if ! agenda_output=$(gcalcli --nocolor --lineart unicode agenda "${calendar_args[@]}" --nodeclined "$range_start" "$range_end" 2>&1); then
  events="gcalcli not configured. Run: gcalcli init"
else
  trimmed=$(printf '%s' "$agenda_output" | sed '/^[[:space:]]*$/d')
  if [ -z "$trimmed" ]; then
    events="No upcoming events"
  else
    events="$agenda_output"
  fi
fi

tooltip=$(printf '%s\n\n%s' "$calendar_text" "$events")

export TEXT="$text"
export TOOLTIP="$tooltip"
python3 - <<'PY'
import html
import json
import os

text = os.environ["TEXT"]
tooltip = "<tt>" + html.escape(os.environ["TOOLTIP"]) + "</tt>"
print(json.dumps({"text": text, "tooltip": tooltip}))
PY
