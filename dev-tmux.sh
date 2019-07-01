#!/bin/bash

#wmctrl -r ":ACTIVE:" -b toggle,fullscreen
printf '\33]50;%s\007' 'xft:DejaVu Sans Mono for Powerline:size=8'
tmux new-session -s dbsim -c /home/con/workspace/grad/research/rlcc/dbsim_v2 \; \
    split-window -h -p 20 \; \
    select-pane -L \; \
    split-window -v -p 30 \; \
    split-window -h \; \
    select-pane -U \; \
    new-window -c /home/con/workspace/grad/research/rlcc/dbsim_v2/rocksdb \; \
    split-window -h -p 20  -c /home/con/workspace/grad/research/rlcc/dbsim_v2/rocksdb \; \
    select-pane -L \; \
    split-window -v -p 30 -c /home/con/workspace/grad/research/rlcc/dbsim_v2/rocksdb \; \
    select-pane -U \; \
    next-window \; \
    send-keys 'vim'
#tmux new-session -s 'vim'
#tmux split-window -v
#tmux split-window -h
#tmux new-window
