#!/bin/bash

SESS_NAME="sicp"
BASE_DIR="/Users/conrad/projects/sicp"
#wmctrl -r ":ACTIVE:" -b toggle,fullscreen
if tmux has-session -t "${SESS_NAME}" 2>/dev/null; then
    tmux a -t "${SESS_NAME}"
    exit 0
fi

tmux new-session -s "${SESS_NAME}" -c "${BASE_DIR}" \; \
    split-window -v -p 30 \; \
    select-pane -U # \; \
    #send-keys 'touch play.py ; vim play.py' Enter \; \
    #select-pane -D \; \
    #send-keys 'python3 -mvenv venv ; source ./venv/bin/activate ; ls play.py | entr python play.py' Enter \; \
    #select-pane -U \; \
    #send-keys 'iprint("Hello world")kj:w' Enter
