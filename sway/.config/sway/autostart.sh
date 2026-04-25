#!/bin/sh
set -eu

if ! pgrep -x udiskie >/dev/null 2>&1; then
    udiskie -t >/dev/null 2>&1 &
fi

if command -v kanshi >/dev/null 2>&1; then
    pkill -x kanshi >/dev/null 2>&1 || true
    kanshi >/dev/null 2>&1 &
fi

if [ -x "$HOME/.config/sway/startup-workspaces.sh" ]; then
    "$HOME/.config/sway/startup-workspaces.sh"
fi

pkill -x mako >/dev/null 2>&1 || true
mako >/dev/null 2>&1 &

pkill -x waybar >/dev/null 2>&1 || true
"$HOME/.config/waybar/launch.sh" >/dev/null 2>&1 &

"$HOME/.config/sway/idle.sh" &
"$HOME/.config/sway/wlsunset-toggle.sh" start
