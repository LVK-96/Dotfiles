#!/usr/bin/env bash
set -euo pipefail

# Get default sink name
default_sink=$(pactl info | awk -F': ' '/Default Sink/{print $2}')

# Get volume, mute, and description from the sink block
sink_block=$(pactl list sinks | awk -v RS='\n\n' -v sink="$default_sink" '$0 ~ "Name: " sink {print}')

mute=$(echo "$sink_block" | awk '/^\s*Mute:/ {print $2; exit}')
vol=$(echo "$sink_block" | awk '/^\s*Volume:/ {for(i=1;i<=NF;i++) if(match($i, /^[0-9]+%$/)) {print $i; exit}}')
desc=$(echo "$sink_block" | sed -n 's/^\s*Description: //p' | head -n1)

vol=${vol%%%}

# Choose volume icon
if [ "$mute" = "yes" ]; then
  icon="󰝟"
elif [ "${vol:-0}" -le 30 ]; then
  icon="󰕿"
elif [ "${vol:-0}" -le 70 ]; then
  icon="󰖀"
else
  icon="󰕾"
fi

# Build tooltip
tooltip="${desc} ${vol}%"

# Append media info if available
if command -v playerctl >/dev/null 2>&1; then
  status=$(playerctl status 2>/dev/null || true)
  if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
    artist=$(playerctl metadata artist 2>/dev/null || true)
    title=$(playerctl metadata title 2>/dev/null || true)
    if [ "$status" = "Playing" ]; then
      icon_media=""
    else
      icon_media=""
    fi
    tooltip="${tooltip}"$'\n'"${icon_media} ${artist} — ${title}"
  fi
fi

# Output as JSON via Python for proper escaping
export ICON="$icon"
export TOOLTIP="$tooltip"
python3 - <<'PY'
import json, os
print(json.dumps({"text": os.environ["ICON"], "tooltip": os.environ["TOOLTIP"]}))
PY
