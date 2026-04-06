#!/bin/sh
set -eu

lock_cmd="$HOME/.config/sway/lock.sh lock"

pkill -x swayidle >/dev/null 2>&1 || true

exec swayidle -w \
    timeout 300 "$lock_cmd" \
    timeout 600 'swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
    before-sleep "$lock_cmd" \
    after-resume 'swaymsg "output * power on"' \
    lock "$lock_cmd"
