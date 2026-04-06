#!/bin/sh
set -eu

mode="${1:-area}"
dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
timestamp="$(date +%Y-%m-%dT%H-%M-%S)"
file="$dir/$timestamp.png"

mkdir -p "$dir"

case "$mode" in
    area)
        geometry="$(slurp)" || exit 0
        grim -g "$geometry" "$file"
        ;;
    screen)
        grim "$file"
        ;;
    *)
        printf 'usage: %s [area|screen]\n' "$0" >&2
        exit 2
        ;;
esac

wl-copy < "$file"

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot saved" "$file"
fi
