#!/usr/bin/env zsh

# FIXME: This script is noticeably slow, but scales linearly in the number of
# words. Also the random selection is with replacement, and important feature
# of generating English sentences

usage() {
    cat << EOF 
Gerate place holder text from actual english words. Must provide the number of
words per line, and can optionally provide the number of lines, which defaults
to one. 

Usagee: ./lorem.zsh <words_per_line> [<lines>=1]

To specify location of the dictionary of words:

DICTIONARY_FILE=/custom/dict/path/wods ./lorem.zsh <n>
EOF
exit 1
}

DICTIONARY_FILE="/usr/share/dict/words"
SED_PROGRAM="sed"

set_sed() {
    if ! "${SED_PROGRAM}" --version 2>&1 | grep -q GNU; then

        if [[ "${SED_PROGRAM}" =~ ^g ]]; then
            # >&2 echo "No GNU SED :("
            # usage "No GNU sed to capitalize first letter of sentence"
        fi

        SED_PROGRAM="g${SED_PROGRAM}"
        set_sed
    fi
}

lorem() {
    # One sentance per line (from the newline at the end of the sed command).
    # TODO: Make the presence of newlines controllable by an argument
    local nwords="$1"
    local nlines="$2"

    for line in $(seq "$nlines"); do
        "${SED_PROGRAM}" -E 's/^(.)(.*)( )$/\u\1\2.\n/' <(repeat "${nwords}"  echo -n "$(shuf -n 1 ${DICTIONARY_FILE}) ")
    done
}

[[ "$#" -eq 1 || "$#" -eq 2 ]] || usage "Wrong argument count"

nwords="$1"
[[ "$#" -eq 2 ]] && nlines="$2" || nlines=1

set_sed

lorem "$nwords" "$nlines"
