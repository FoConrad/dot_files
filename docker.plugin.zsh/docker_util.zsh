#!/usr/bin/env zsh

# There are some zsh-isms in here, like using {} to group statements

DIR="$(dirname $0:A)"


die() {
    {
        echo -n "Bad usage, "
        type $1
        declare -f $1 || alias $1
    } >&2
    echo 1
} 

export DOCKER_PASSWORD_FILE="${HOME}/config/docker.plugin.zsh/docker_pass.gpg"
# Set this up so it does not trigger right away and sit there w/ sensitive
alias -g DP='DOCKER_PASSWORD=$(gpg -d $DOCKER_PASSWORD_FILE)'


# Simple aliases


alias dr='docker run'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias ds='docker stop'
alias dsp='docker system prune'

# Slightly in-depth functions

function docker_clean() {
    while read line; do
        SEP_STR=$(echo "$line" | awk '{print $1"|"$2"|"$3"|"$NF}')
        COLS=("${(@s/|/)SEP_STR}")

        [[ ! "${COLS[1]}" =~ "^rickotoole" ]] && echo -n "(from ${COLS[1]}). "
        read -q "resp?Free ${COLS[4]} space removing ${COLS[2]} [Y/n]: "; echo

        [[ "${resp}" == "y" ]] && echo "docker image rm ${COLS[3]}" | bash -x
    done < <(docker images | tail -n +2)
}

# docker exec bash
function deb() {
    [[ "$#" -ge 1 ]] || return $(die deb)
    [[ "$#" -gt 1 ]] || 2="/bin/bash"
    docker exec -it "$1" "${@:2}" 
}

# docker images [upstream]
function di() {
    [[ "$#" -le 1 ]] || return $(die di)

    local arg=""

    if [[ "$#" -eq 1 ]]; then 
        [[ "$1" =~ "^[uU]" ]] && arg="rickotoole/rockerbox-metrics" || \
            return $(die di)
    fi
    docker images $arg
}
function diu() {
    di u
}

# Very in depth functions they need their own scripts
alias kslave="${DIR}/rbutil/kslaves.sh"
alias kslaves="${DIR}/rbutil/kslaves.sh"

alias drf="${DIR}/docker_run_fuzzy.zsh"
