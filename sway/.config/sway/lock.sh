#!/bin/sh
set -eu

lock_args='-f -c 4c7899 --ignore-empty-password --show-failed-attempts'

lock() {
    # shellcheck disable=SC2086
    exec swaylock $lock_args
}

screen_off() {
    # shellcheck disable=SC2086
    swaylock $lock_args &
    lock_pid=$!
    sleep 1
    swaymsg "output * power off"
    wait "$lock_pid"
}

case "${1:-lock}" in
    lock)
        lock
        ;;
    screen-off)
        screen_off
        ;;
    *)
        printf 'usage: %s [lock|screen-off]\n' "$0" >&2
        exit 2
        ;;
esac
