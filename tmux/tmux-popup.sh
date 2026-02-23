#!/usr/bin/env bash

PREFIX="popup-"
CURRENT=$(tmux display-message -p -F "#{session_name}")
NAME="$PREFIX$CURRENT"

if [[ "$CURRENT" == ${PREFIX}* ]]; then
    tmux detach-client
else
    tmux popup -d '#{pane_current_path}' -xC -yC -w80% -h80% -E "tmux attach -t $NAME || tmux new -s $NAME"
fi
