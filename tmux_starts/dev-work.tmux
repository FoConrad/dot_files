#!/bin/bash

if [[ "$#" -gt 0 && "$1" == "clone" ]]; then 
    echo "There are $# args with first $1"
    START_DIR="/Users/conrad/work/rockerbox/clone/rockerbox-metrics"
    SESS_NAME="devel-rb-clone"
else
    echo "(else) There are $# args with first $1"
    START_DIR="/Users/conrad/work/rockerbox/rockerbox-metrics"
    SESS_NAME="devel-rb-orig"
fi

if tmux has-session -t "${SESS_NAME}"; then
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
    select-pane -U \; \
    send-keys 'vim build.sh' Enter
