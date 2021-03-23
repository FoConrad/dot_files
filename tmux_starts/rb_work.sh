#!/usr/bin/env bash

SESS_PREFIX="devel-rb-"
WORK_SESS_NAMES=( orig clone copy3 copy4 sdsad )

CDIR="$(pwd)"
DIR_PREFIX="${HOME}/work/rockerbox"

HEADER="Arg\tTmux sess\tGit branch"

err() {
    >&2 echo "$@"
    exit 1
}

_get_branch() {
    local dir="$DIR_PREFIX"
    [[ "$1" != "orig" ]] && dir="${dir}/$1"
    dir="${dir}/rockerbox-metrics"

    cd $dir
    git branch | grep '^\*' | cut -f2 -d' '
    cd $CDIR
}

_is_running() {
    tmux ls | grep "$1" >/dev/null
    return $?
}

show_list() {
    local INDEX=1
    echo -e "$HEADER"
    for sess in "${WORK_SESS_NAMES[@]}"; do
        sess_name="${SESS_PREFIX}${sess}"

        if _is_running "${sess_name}" ; then
            BRANCH_OFF="$(_get_branch $sess)"

            # Put asterisk by name of currently attached session
            [[ -n "$TMUX" && "$(tmux display-message -p '#S')" = "$sess_name" ]] && \
                sess_name="*${sess_name}"

            echo -e "${INDEX}\t${sess_name}\t${BRANCH_OFF}"
        fi
        INDEX=$((INDEX+1))
    done
}

if [[ "$#" -ne 1 ]]; then
    show_list
    exit 0
fi

ind="$1"
ind="$((ind-1))"
opts_len="${#WORK_SESS_NAMES}"

[[ "$ind" -lt 0 || "$ind" -ge "${#WORK_SESS_NAMES}" ]] && \
    err "Selection must be from set [1 .. ${#WORK_SESS_NAMES}]"

chosen="${WORK_SESS_NAMES[$ind]}"
_is_running "${SESS_PREFIX}${chosen}" || err "Choice $chosen not in session"

${HOME}/config/tmux_starts/dev-work.tmux $chosen
