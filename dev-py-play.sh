#!/bin/bash

SESS_NAME="pyplay"
#wmctrl -r ":ACTIVE:" -b toggle,fullscreen
if tmux has-session -t "${SESS_NAME}"; then
    tmux a -t "${SESS_NAME}"
    exit 0
fi

rm -rf "${HOME}/tmp/${SESS_NAME}"
mkdir -p "${HOME}/tmp/${SESS_NAME}"

tmux new-session -s "${SESS_NAME}" -c "${HOME}/tmp/${SESS_NAME}" \; \
    split-window -v -p 30 \; \
    select-pane -U \; \
    send-keys 'touch play.py ; vim play.py' Enter \; \
    select-pane -D \; \
    send-keys 'python3 -mvenv venv ; source ./venv/bin/activate ; ls play.py | entr python play.py' Enter \; \
    select-pane -U \; \
    send-keys 'iprint("Hello world")kj:w' Enter
