#!/bin/sh
set -eu

if ! pgrep -x udiskie >/dev/null 2>&1; then
    udiskie -t >/dev/null 2>&1 &
fi

pkill -x mako >/dev/null 2>&1 || true
mako >/dev/null 2>&1 &

pkill -x waybar >/dev/null 2>&1 || true
waybar >/dev/null 2>&1 &

"$HOME/.config/sway/idle.sh" &
"$HOME/.config/sway/wlsunset-toggle.sh" start
