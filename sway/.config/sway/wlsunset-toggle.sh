#!/bin/sh
set -eu

# Override these via environment if this laptop is not in Helsinki.
lat="${WLSUNSET_LAT:-60.1699}"
lon="${WLSUNSET_LON:-24.9384}"

start() {
    pkill -x wlsunset >/dev/null 2>&1 || true
    wlsunset -l "$lat" -L "$lon" >/dev/null 2>&1 &
}

stop() {
    pkill -x wlsunset >/dev/null 2>&1 || true
}

case "${1:-toggle}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    toggle)
        if pgrep -x wlsunset >/dev/null 2>&1; then
            notify-send 'wlsunset' 'Stopping wlsunset'
            stop
        else
            notify-send 'wlsunset' 'Starting wlsunset'
            start
        fi
        ;;
    *)
        printf 'usage: %s [start|stop|toggle]\n' "$0" >&2
        exit 2
        ;;
esac
