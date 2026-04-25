#!/usr/bin/env bash
set -euo pipefail

repo_root="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$repo_root/greetd/.config/greetd"

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    sudo_cmd=()
else
    sudo_cmd=(sudo)
fi

printf 'Installing greetd config from %s\n' "$source_dir"
"${sudo_cmd[@]}" install -Dm644 "$source_dir/config.toml" /etc/greetd/config.toml
printf 'Enabling greetd.service\n'
"${sudo_cmd[@]}" systemctl enable --now greetd.service

printf 'greetd cage + gtkgreet setup installed.\n'
