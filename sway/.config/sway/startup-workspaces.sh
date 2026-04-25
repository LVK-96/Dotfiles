#!/bin/sh
set -eu

# Sway may create an initial empty workspace on each active output before the
# workspace-to-output rules are applied. Normalize the visible workspaces after
# outputs have appeared: keep the output currently showing workspace 1 as the
# primary output, move other visible outputs to the secondary workspace range,
# then return focus to workspace 1.
main_workspace="1"
secondary_workspace_start=6
ipc_lib="${XDG_CONFIG_HOME:-$HOME/.config}/sway/sway-ipc.sh"

if [ ! -r "$ipc_lib" ]; then
    exit 0
fi

# shellcheck source=/dev/null
. "$ipc_lib"

if ! sway_ipc_available; then
    exit 0
fi

focus_output_workspace() {
    output=$1
    workspace=$2

    swaymsg -- "focus output \"$output\"; workspace $workspace" >/dev/null 2>&1 || true
}

primary_output="$(sway_preferred_output_for_workspace "$main_workspace" || true)"
if [ -z "$primary_output" ] || [ "$primary_output" = "null" ]; then
    exit 0
fi

secondary_workspace=$secondary_workspace_start
sway_active_outputs_except "$primary_output" | while IFS= read -r output; do
    [ -n "$output" ] || continue
    focus_output_workspace "$output" "$secondary_workspace"
    secondary_workspace=$((secondary_workspace + 1))
done

focus_output_workspace "$primary_output" "$main_workspace"
