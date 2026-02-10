#!/usr/bin/env bash

path="$1"

if [[ -z "$path" || "$path" == "/" ]]; then
  printf "/"
  exit 0
fi

# Expand home path to a visible '~' prefix.
if [[ -n "$HOME" && "$path" == "$HOME"* ]]; then
  path="~${path#$HOME}"
fi

IFS='/' read -r -a parts <<< "$path"
out=""
last_idx=$((${#parts[@]} - 1))

for i in "${!parts[@]}"; do
  part="${parts[$i]}"
  [[ -z "$part" ]] && continue

  if [[ "$i" -eq "$last_idx" ]]; then
    token="$part"
  else
    if [[ "$part" == "~" ]]; then
      token="~"
    else
      token="${part:0:1}"
    fi
  fi

  if [[ -z "$out" ]]; then
    out="$token"
  else
    out="$out/$token"
  fi
done

if [[ "$path" == /* ]]; then
  printf "/%s" "$out"
else
  printf "%s" "$out"
fi
