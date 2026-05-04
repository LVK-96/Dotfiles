#!/usr/bin/env bash
set -euo pipefail

calendar="${WAYBAR_GCALCLI_CALENDAR:-}"
range_start="now"
range_end="7d"

calendar_args=()
if [ -n "$calendar" ]; then
  calendar_args=(--calendar "$calendar")
fi

if ! agenda_output=$(gcalcli --nocolor --lineart unicode agenda "${calendar_args[@]}" --nodeclined "$range_start" "$range_end" 2>&1); then
  tooltip="gcalcli not configured. Run: gcalcli init"
else
  trimmed=$(printf '%s' "$agenda_output" | sed '/^[[:space:]]*$/d')
  if [ -z "$trimmed" ]; then
    tooltip="No upcoming events"
  else
    tooltip="$agenda_output"
  fi
fi

export TOOLTIP="$tooltip"
python3 - <<'PY'
import json
import os

print(json.dumps({"text": "", "tooltip": os.environ["TOOLTIP"]}))
PY
