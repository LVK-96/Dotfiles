#!/usr/bin/env bash
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

wait_for_sway_ipc() {
    i=0
    while [ "$i" -lt 40 ]; do
        if swaymsg -t get_workspaces >/dev/null 2>&1; then
            return 0
        fi
        i=$((i + 1))
        sleep 0.25
    done
    return 1
}

wait_for_workspace_output() {
    i=0
    while [ "$i" -lt 40 ]; do
        main_output="$(workspace_output || true)"
        if [ -n "$main_output" ] && [ "$main_output" != "null" ]; then
            printf '%s\n' "$main_output"
            return 0
        fi
        i=$((i + 1))
        sleep 0.25
    done
    return 1
}

main_output=""
if wait_for_sway_ipc; then
    main_output="$(wait_for_workspace_output || true)"
fi

if [ -z "$main_output" ] || [ "$main_output" = "null" ]; then
    main_output="$(focused_output || true)"
fi

if [ -z "$main_output" ] || [ "$main_output" = "null" ]; then
    echo "waybar: could not determine main output; starting without output filtering" >&2
    exec waybar -c "$template" -s "$style"
fi

template_content="$(<"$template")"
rendered_content="${template_content//__WAYBAR_MAIN_OUTPUT__/$main_output}"
printf '%s\n' "$rendered_content" > "$rendered_config"

exec waybar -c "$rendered_config" -s "$style"
