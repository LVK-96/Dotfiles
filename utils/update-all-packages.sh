#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: update-all-packages.sh [OPTIONS]

Detect common package managers and update globally installed packages.

Options:
  -l, --list       List discovered package managers and exit
  -n, --dry-run    Show what would run without executing updates
  -h, --help       Show this help message
USAGE
}

log() {
  printf '[%s] %s\n' "$1" "$2"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log DRY-RUN "$*"
    return 0
  fi

  log RUN "$*"
  "$@"
}

run_privileged() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log DRY-RUN "$*"
    return 0
  fi

  if (( EUID == 0 )); then
    run_cmd "$@"
    return 0
  fi

  if have_cmd sudo; then
    run_cmd sudo "$@"
  else
    log WARN "sudo is not available; cannot run privileged command: $*"
  fi
}

detect_managers() {
  local managers=()

  have_cmd apt && managers+=(apt)
  have_cmd paru && managers+=(paru)
  have_cmd yay && managers+=(yay)

  # Skip pacman if an AUR helper is available because paru/yay already update repo packages.
  if have_cmd pacman && ! have_cmd paru && ! have_cmd yay; then
    managers+=(pacman)
  fi

  have_cmd pixi && managers+=(pixi)
  have_cmd npm && managers+=(npm)
  have_cmd pnpm && managers+=(pnpm)
  have_cmd bun && managers+=(bun)
  have_cmd mise && managers+=(mise)
  have_cmd uv && managers+=(uv)

  if have_cmd pipx; then
    managers+=(pipx)
  fi

  if have_cmd pip3; then
    managers+=(pip3)
  elif have_cmd pip; then
    managers+=(pip)
  fi

  have_cmd cargo && managers+=(cargo)
  have_cmd nix && managers+=(nix)

  printf '%s\n' "${managers[@]}"
}

update_pip() {
  local pip_bin="$1"

  run_cmd "$pip_bin" install --upgrade pip

  if ! have_cmd python3; then
    log WARN "python3 is not available; cannot parse outdated package list for $pip_bin"
    return 0
  fi

  local outdated
  outdated="$($pip_bin list --outdated --format=json 2>/dev/null | python3 -c 'import json,sys; data=json.load(sys.stdin); print("\n".join(pkg["name"] for pkg in data))' || true)"

  if [[ -z "$outdated" ]]; then
    log INFO "No outdated packages found for $pip_bin"
    return 0
  fi

  while IFS= read -r package; do
    [[ -z "$package" ]] && continue
    run_cmd "$pip_bin" install --upgrade "$package"
  done <<< "$outdated"
}

update_manager() {
  local manager="$1"

  case "$manager" in
    apt)
      run_privileged apt update
      run_privileged apt upgrade -y
      run_privileged apt autoremove -y
      ;;
    pacman)
      run_privileged pacman -Syu --noconfirm
      ;;
    paru)
      run_cmd paru -Syu --noconfirm
      ;;
    yay)
      run_cmd yay -Syu --noconfirm
      ;;
    pixi)
      run_cmd pixi global update
      ;;
    npm)
      run_cmd npm update -g
      ;;
    pnpm)
      run_cmd pnpm update -g
      ;;
    bun)
      run_cmd bun upgrade
      ;;
    mise)
      run_cmd mise self-update || true
      run_cmd mise plugins update
      run_cmd mise upgrade
      ;;
    uv)
      run_cmd uv self update || true
      run_cmd uv tool upgrade --all
      ;;
    pipx)
      run_cmd pipx upgrade-all
      ;;
    pip)
      update_pip pip
      ;;
    pip3)
      update_pip pip3
      ;;
    cargo)
      if have_cmd cargo-install-update; then
        run_cmd cargo install-update -a
      else
        log WARN "cargo-install-update is not installed; skipping Cargo crate updates"
      fi
      ;;
    nix)
      run_cmd nix profile upgrade '.*'
      ;;
    *)
      log WARN "Unknown package manager: $manager"
      ;;
  esac
}

LIST_ONLY=false
DRY_RUN=false

while (($#)); do
  case "$1" in
    -l|--list)
      LIST_ONLY=true
      ;;
    -n|--dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log WARN "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

mapfile -t discovered < <(detect_managers)

if ((${#discovered[@]} == 0)); then
  log WARN "No supported package managers were detected on this system"
  exit 0
fi

if [[ "$LIST_ONLY" == "true" ]]; then
  printf '%s\n' "${discovered[@]}"
  exit 0
fi

log INFO "Discovered package managers: ${discovered[*]}"

for manager in "${discovered[@]}"; do
  log INFO "Updating via $manager"
  if ! update_manager "$manager"; then
    log WARN "Update failed for $manager (continuing)"
  fi
done

log INFO "Finished update pass"
