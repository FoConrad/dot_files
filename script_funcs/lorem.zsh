#!/usr/bin/env zsh

# FIXME: This script is noticeably slow, but scales linearly in the number of
# words. Also the random selection is with replacement, and important feature
# of generating English sentences

usage() {
    cat << EOF 
Gerate place holder text from actual english words. The usage below would create 
a sentace with <n> words.

Usagee: ./lorem.zsh <n>

To specify location of the dictionary of words:

DICTIONARY_FILE=/custom/dict/path/wods ./lorem.zsh <n>
EOF
exit 1
}

DICTIONARY_FILE="/usr/share/dict/words"

lorem() {
    local nwords="$1"
    sed -E 's/^(.)(.*)( )$/\U\1\2./' <(repeat "${nwords}"  echo -n "$(shuf -n 1 ${DICTIONARY_FILE}) ")
}

[ "$#" -eq 1 ] || usage "Wrong argument count"
lorem "$@"
