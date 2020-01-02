#!/usr/bin/env zsh

LINE_WIDTH=80

usage() {
    local short="Usage: $0 [<s>]"
    if [[ "$#" -eq 1 && "$1" =~ "^-?[sS]" ]]; then
        echo  "$short"
        return
    fi
    cat << EOF
Console stopwatch to keep time for <s> seconds or repeatedly just
keep the running time.

$short
EOF
}

die() {
    [[ "$#" -gt 0 ]] && echo "$@"
    usage -s
    exit 1
}

DATE_CMD="date"

if [[  "$OSTYPE" =~ "darwin.*" ]]; then
    command -v gdate >/dev/null || die "With mac must have gnu date as 'gdate'"
    DATE_CMD="gdate"
fi

ns() {
    eval "${DATE_CMD}" +"%s%N"
}

# Args are: elapsed [limit]
times_up() {
    [[ "$#" -lt 2 || -z "$2" ]] && return 1

    [[ "${1}" -ge "${2}" ]]; return $?
}

repeatc() {
    [[ "$2" -gt 0 ]] && printf "${1}%.0s" {1..$2}
}

keep_time() {
    local lim="$1"
    local start="$(ns)"
    local elapsed="$(bc -l <<< "($(ns) - ${start}) / 10^9")"

    until times_up $elapsed $lim; do
        local formatted="$(printf "%0.3f" "${elapsed}")"

        if [[ "$lim" ]]; then
            formatted=" ${formatted} "

            integer local hashes="$(bc -l <<< "($elapsed / $lim) * $LINE_WIDTH")"
            integer local spaces="$(( $LINE_WIDTH - $hashes ))"

            local prog_str="[$(repeatc '#' $hashes)$(repeatc ' ' $spaces)]\r"
            local half_len="$(( (${#prog_str}-${#formatted}) / 2 ))"

            echo -n "$prog_str\r"
            echo -n "${prog_str:0:$half_len}"
        fi

        echo -n "$formatted\r"
        elapsed="$(bc -l <<< "($(ns) - ${start}) / 10^9")"
    done
}

_restore_cursor() {
    tput cnorm
    echo
    exit 0
}

# Hide cursor during timer
tput civis

trap _restore_cursor INT TERM # Don't leave the invokee cursorless if they ^c
keep_time $1

_restore_cursor
