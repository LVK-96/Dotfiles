#!/bin/sh
set -eu

config_dir="$HOME/.config/waybar"
template="$config_dir/config.jsonc"
style="$config_dir/style.css"
rendered_config="${XDG_RUNTIME_DIR:-/tmp}/waybar-config.jsonc"

workspace_output() {
    swaymsg -t get_workspaces 2>/dev/null |
        jq -r '.[] | select(.num == 1) | .output' |
        head -n1
}

focused_output() {
    swaymsg -t get_outputs 2>/dev/null |
        jq -r '.[] | select(.focused == true) | .name' |
        head -n1
}

main_output=""
i=0
while [ "$i" -lt 40 ]; do
    main_output="$(workspace_output || true)"
    if [ -n "$main_output" ] && [ "$main_output" != "null" ]; then
        break
    fi
    i=$((i + 1))
    sleep 0.25
done

if [ -z "$main_output" ] || [ "$main_output" = "null" ]; then
    main_output="$(focused_output || true)"
fi

if [ -z "$main_output" ] || [ "$main_output" = "null" ]; then
    echo "waybar: could not determine main output; starting without output filtering" >&2
    exec waybar -c "$template" -s "$style"
fi

python3 - "$template" "$rendered_config" "$main_output" <<'PY'
from pathlib import Path
import sys

template, rendered, main_output = sys.argv[1:]
Path(rendered).write_text(
    Path(template).read_text().replace("__WAYBAR_MAIN_OUTPUT__", main_output),
    encoding="utf-8",
)
PY

exec waybar -c "$rendered_config" -s "$style"
