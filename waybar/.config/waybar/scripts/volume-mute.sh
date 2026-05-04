#!/usr/bin/env bash
set -euo pipefail

sink=$(pactl info | awk -F': ' '/Default Sink/{print $2}')
pactl set-sink-mute "$sink" toggle
