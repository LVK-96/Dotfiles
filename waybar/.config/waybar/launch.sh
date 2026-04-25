#!/usr/bin/env bash
set -eu

config_dir="$HOME/.config/waybar"
template="$config_dir/config.jsonc"
style="$config_dir/style.css"
rendered_config="${XDG_RUNTIME_DIR:-/tmp}/waybar-config.jsonc"
ipc_lib="${XDG_CONFIG_HOME:-$HOME/.config}/sway/sway-ipc.sh"
main_workspace=1

main_output=""
if [ -r "$ipc_lib" ]; then
    # shellcheck source=/dev/null
    . "$ipc_lib"

    if sway_ipc_available; then
        main_output="$(sway_preferred_output_for_workspace "$main_workspace" || true)"
    fi
fi

if [ -z "$main_output" ] || [ "$main_output" = "null" ]; then
    echo "waybar: could not determine main output; starting without output filtering" >&2
    exec waybar -c "$template" -s "$style"
fi

template_content="$(<"$template")"
rendered_content="${template_content//__WAYBAR_MAIN_OUTPUT__/$main_output}"
printf '%s\n' "$rendered_content" > "$rendered_config"

exec waybar -c "$rendered_config" -s "$style"
