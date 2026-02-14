#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: update-all-packages.sh [OPTIONS]

Detect common package managers and update globally installed packages.

Options:
  -l, --list       List discovered package managers and exit
  -n, --dry-run    Show what would run without executing updates
  -o, --only LIST  Comma-separated manager allowlist (e.g. apt,npm,uv)
  -s, --skip LIST  Comma-separated manager skip list
  -h, --help       Show this help message

Examples:
  update-all-packages.sh --list
  update-all-packages.sh --dry-run --only apt,paru,pixi
  update-all-packages.sh --skip uv,npm
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
  if (( EUID == 0 )); then
    run_cmd "$@"
    return
  fi

  if have_cmd sudo; then
    run_cmd sudo "$@"
  else
    log WARN "sudo is not available; cannot run privileged command: $*"
    return 1
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

  have_cmd cargo && managers+=(cargo)
  have_cmd nix && managers+=(nix)
  have_cmd flatpak && managers+=(flatpak)
  have_cmd snap && managers+=(snap)
  have_cmd brew && managers+=(brew)
  have_cmd dnf && managers+=(dnf)
  have_cmd zypper && managers+=(zypper)

  if ((${#managers[@]} > 0)); then
    printf '%s\n' "${managers[@]}"
  fi
}

csv_contains() {
  local csv="$1"
  local value="$2"
  [[ ",$csv," == *",$value,"* ]]
}

sanitize_csv() {
  local csv="$1"
  # Normalize common user input like "apt, npm,uv".
  csv="${csv// /}"
  csv="${csv//,,/,}"
  csv="${csv#,}"
  csv="${csv%,}"
  printf '%s\n' "$csv"
}

filter_managers() {
  local managers=("$@")
  local filtered=()
  local manager

  for manager in "${managers[@]}"; do
    if [[ -n "$ONLY_CSV" ]] && ! csv_contains "$ONLY_CSV" "$manager"; then
      continue
    fi

    if [[ -n "$SKIP_CSV" ]] && csv_contains "$SKIP_CSV" "$manager"; then
      continue
    fi

    filtered+=("$manager")
  done

  if ((${#filtered[@]} > 0)); then
    printf '%s\n' "${filtered[@]}"
  fi
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
      run_privileged npm update -g
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
    flatpak)
      run_cmd flatpak update -y
      ;;
    snap)
      run_privileged snap refresh
      ;;
    brew)
      run_cmd brew update
      run_cmd brew upgrade
      run_cmd brew cleanup -s
      ;;
    dnf)
      run_privileged dnf upgrade --refresh -y
      ;;
    zypper)
      run_privileged zypper refresh
      run_privileged zypper update -y
      ;;
    *)
      log WARN "Unknown package manager: $manager"
      ;;
  esac
}

LIST_ONLY=false
DRY_RUN=false
ONLY_CSV=""
SKIP_CSV=""

while (($#)); do
  case "$1" in
    -l|--list)
      LIST_ONLY=true
      ;;
    -n|--dry-run)
      DRY_RUN=true
      ;;
    -o|--only)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log WARN "--only requires a comma-separated value"
        exit 1
      fi
      ONLY_CSV=$(sanitize_csv "$2")
      [[ -z "$ONLY_CSV" ]] && { log WARN "--only requires at least one manager"; exit 1; }
      shift
      ;;
    -s|--skip)
      if [[ $# -lt 2 || "${2:-}" == -* ]]; then
        log WARN "--skip requires a comma-separated value"
        exit 1
      fi
      SKIP_CSV=$(sanitize_csv "$2")
      [[ -z "$SKIP_CSV" ]] && { log WARN "--skip requires at least one manager"; exit 1; }
      shift
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
mapfile -t discovered < <(filter_managers "${discovered[@]}")

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
  if ! (set -Eeuo pipefail; update_manager "$manager"); then
    log WARN "Update failed for $manager (continuing)"
  fi
done

log INFO "Finished update pass"
