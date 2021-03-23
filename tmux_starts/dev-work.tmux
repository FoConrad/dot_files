#!/bin/bash

# Firrst case special beacuse PATH is
if [[ "$#" -eq 0 || "$1" == "orig" ]]; then 
    START_DIR="/Users/conrad/work/rockerbox/rockerbox-metrics"
    SESS_NAME="devel-rb-orig"
else
    START_DIR="/Users/conrad/work/rockerbox/${1}/rockerbox-metrics"
    SESS_NAME="devel-rb-${1}"
fi

if [[ ! -d ${START_DIR} ]]; then
    >2 echo "Unknown repo clone '$START_DIR'. Currently accpets clone, copy3, "
    >2 echo "copy4, and orig (default when no arg)."
    exit 1
fi

if tmux has-session -t "${SESS_NAME}" 2>/dev/null; then
    eval exec tmux a -t "${SESS_NAME}"
fi


tmux -2 new-session -s ${SESS_NAME} -c ${START_DIR} \; \
    split-window -h -p 20 \; \
    select-pane -L \; \
    split-window -v -p 30 \; \
    send-keys 'source ~/work/rockerbox/renv/bin/activate' Enter \; \
    send-keys 'ipython' Enter \; \
    split-window -h \; \
    send-keys 'source ~/work/rockerbox/renv/bin/activate' Enter \; \
    send-keys 'gcur' Enter \; \
    select-pane -U \; \
    send-keys 'vim build.sh' Enter
