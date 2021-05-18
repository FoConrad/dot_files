
START_DIR="/Users/conradchristensen/vise/code/orig/vise"

check_start() {
    START_DIR="/Users/conradchristensen/vise/code/orig/vise"

    SESS=$([[ -n "$TMUX" ]] && tmux display-message -p '#S' || echo)

    if [[ "$SESS" = "devel-rb-orig" ]]; then
        START_DIR="/Users/conradchristensen/vise/code/orig/vise"
        return 0
    elif [[ "$SESS" = "devel-rb-clone" ]]; then
        START_DIR="/Users/conradchristensen/vise/code/clone/vise"
        return 0
    elif [[ "$SESS" = "devel-rb-copy3" ]]; then
        START_DIR="/Users/conradchristensen/vise/code/copy3/vise"
        return 0
    elif
        [[ "$SESS" = "devel-rb-copy4" ]]; then
        START_DIR="/Users/conradchristensen/vise/code/copy4/vise"
        return 0
    fi

    return 1
}

# Call `newsplit_t` in a terminal within a tmux sess and a new window is
# created and split. Call `newsplit_t -n` in a fresh window within a tmux sess
# and the current window will be split
newsplit_t() {
    if [[ -z "$TMUX" ]]; then
        >&2 echo "Only call from within tmux sess!"
        return -2
    fi

    if ! check_start; then
        START_DIR="$(pwd)"
    fi

    if [[ ! "${@: -1}" =~ "-" ]]; then
        local sfx="${@: -1}"
        if [[ "$sfx" =~ "^(api|web)$" ]]; then
            START_DIR="${START_DIR}/ts/${sfx}"
        elif [[ "$sfx" =~ "^pce2?$" ]]; then
            START_DIR="${START_DIR}/python/${sfx}"
        fi
    fi

    if [[ "$#" -gt 0 && "$1" = "-n" ]]; then
        if  [[ "$(tmux list-panes | wc -l | xargs)" != "1" ]]; then
            >&2 echo "Only call this on window w/ one pane"
            return -1
        fi
    else
        tmux new-window -c ${START_DIR} 
    fi

    tmux split-window -c ${START_DIR} -v -p 30 \; \
    select-pane -U \; \
    split-window -h -p 30 -c ${START_DIR} \; \
    select-pane -D \; \
    split-window -h -c ${START_DIR} \; \
    send-keys 'gcur' Enter \; \
    select-pane -L \; \
    send-keys 'export PATH=$(pyenv root)/shims:$PATH' Enter \; \
    send-keys 'clear;echo "Python version $(python -c '"'"'import sys; print(".".join(map(str, sys.version_info[:3])))'"'"') at $(which python)"' Enter \; \
    send-keys 'ipython' Enter \; \
    select-pane -U \; \
    send-keys 'vim -R README.md' Enter

    if [[ ! "${@: -1}" =~ "-" ]]; then
        tmux rename-window "${@: -1}"
    fi
}

