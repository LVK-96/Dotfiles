#!/usr/bin/env bash
set -euo pipefail

status=$(playerctl status 2>/dev/null || true)
if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
    playerctl play-pause
else
    pavucontrol
fi
