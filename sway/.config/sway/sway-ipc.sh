# shellcheck shell=sh
# Shared Sway IPC helpers for startup scripts.

sway_ipc_available() {
    command -v swaymsg >/dev/null 2>&1 && command -v jq >/dev/null 2>&1
}

sway_outputs_json() {
    swaymsg -t get_outputs 2>/dev/null || printf '[]\n'
}

sway_workspaces_json() {
    swaymsg -t get_workspaces 2>/dev/null || printf '[]\n'
}

sway_active_output_count() {
    sway_outputs_json | jq '[.[] | select(.active == true)] | length'
}

sway_workspace_output() {
    workspace=$1

    sway_workspaces_json | jq -r --argjson workspace "$workspace" '
        .[]
        | select(.num == $workspace)
        | .output
    ' | head -n1
}

sway_focused_output() {
    sway_outputs_json | jq -r '
        .[]
        | select(.focused == true)
        | .name
    ' | head -n1
}

sway_active_outputs_except() {
    excluded_output=$1

    sway_outputs_json | jq -r --arg excluded_output "$excluded_output" '
        .[]
        | select(.active == true and .name != $excluded_output)
        | .name
    '
}

sway_wait_for_ipc() {
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

sway_wait_for_workspace_output() {
    workspace=$1

    i=0
    while [ "$i" -lt 40 ]; do
        output="$(sway_workspace_output "$workspace" || true)"
        if [ -n "$output" ] && [ "$output" != "null" ]; then
            printf '%s\n' "$output"
            return 0
        fi
        i=$((i + 1))
        sleep 0.25
    done
    return 1
}

sway_preferred_output_for_workspace() {
    workspace=$1
    output=""

    if sway_wait_for_ipc; then
        output="$(sway_wait_for_workspace_output "$workspace" || true)"
    fi

    if [ -z "$output" ] || [ "$output" = "null" ]; then
        output="$(sway_focused_output || true)"
    fi

    if [ -n "$output" ] && [ "$output" != "null" ]; then
        printf '%s\n' "$output"
        return 0
    fi

    return 1
}
