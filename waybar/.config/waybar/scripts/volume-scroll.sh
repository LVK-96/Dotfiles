#!/usr/bin/env bash
set -euo pipefail

sink=$(pactl info | awk -F': ' '/Default Sink/{print $2}')
case "${1:-}" in
  up)   pactl set-sink-volume "$sink" +5% ;;
  down) pactl set-sink-volume "$sink" -5% ;;
esac
