#!/bin/bash

# Firrst case special beacuse PATH is
if [[ "$#" -eq 0 || "$1" == "orig" ]]; then 
    START_DIR="/Users/conradchristensen/vise/code/orig/vise"
    SESS_NAME="devel-rb-orig"
else
    START_DIR="/Users/conradchristensen/vise/code/${1}/vise"
    SESS_NAME="devel-rb-${1}"
fi

if [[ ! -d ${START_DIR} ]]; then
    >&2 echo "Unknown repo clone '$START_DIR'. Currently accpets clone, copy3, "
    >&2 echo "copy4, and orig (default when no arg)."
    exit 1
fi

if tmux has-session -t "${SESS_NAME}" 2>/dev/null; then
    eval exec tmux a -t "${SESS_NAME}"
fi

WIN_NAME="vise"
if [[ "$#" -eq 2 ]]; then
    WIN_NAME="$2"
fi

tmux -2 new-session -s ${SESS_NAME} -c ${START_DIR} \; \
    split-window -v -p 30 \; \
    select-pane -U \; \
    split-window -h -p 30 \; \
    select-pane -D \; \
    split-window -h \; \
    send-keys 'gcur' Enter \; \
    select-pane -L \; \
    send-keys 'export PATH=$(pyenv root)/shims:$PATH' Enter \; \
    send-keys 'clear;echo "Python version $(python -c '"'"'import sys; print(".".join(map(str, sys.version_info[:3])))'"'"') at $(which python)"' Enter \; \
    send-keys 'ipython' Enter \; \
    select-pane -U \; \
    send-keys 'vim -R README.md' Enter \; \
    rename-window "${WIN_NAME}"

