#!/usr/bin/env zsh

usage() {
    cat << EOF
Git staging script which displays the changes made to each modified file and
decide individually whether to stage it.

Usage (anywhere is git repo)
 > gdiff_add [-c|-C [-a -m <message>]]

Options:
    -c      after choosiung which files to stage, commit them
    -C      same as -c but suppress warning for the presence 
            of staged files
    -a      make commit --amend the previous instead of
            craeting a new one (adds --no-edit unless -m is
            provided)
    -m <mg> Use the commit message <mg> 
            
EOF
}

die() {
    [[ "$#" -gt 0 ]]  && echo "$1"
    exit 1
}

grep --version | grep -q GNU && local GREP_C=:'grep -P' || local  GREP_C='pcregrep'
echo "$GREP_C '(?<=^ABC)DE' <<< 'ABCDE'" || die "Grep command or PCRE addition failure"

confirm_stage() {
    local resp=''
    read -q "resp?Stage file [y/N]: " ; echo
    [[ "$resp" =~ [yY] ]] && return  0 || return 1
}

stage_files() {
    local mfiles=( $(git status -uno | pcregrep -o '\s+modified:\s+\K[^ ]+') )

    for efile in $mfiles ; do
        echo "File $efile has been modified, inspecting the diff"
        git diff $efile

        if confirm_stage $efile ; then
            echo "git add $efile" | bash -x
        fi
    done
}

commit_files() {
    local args=""
    [[ -n "${COMMIT_MSG}" ]] && args="${args} -m ${COMMIT_MSG}"
    [[ "${AMMEND}" == "true" ]] && args="${args} --amend"
    [[ "${AMMEND}" == "true" && -z "${COMMIT_MSG}" ]] && args="${args} --no-edit"
    echo "git commit ${args}"
}

AMMEND="false"
COMMIT="false"
COMMIT_MSG=""

while getopts ":hcam:" opt; do
    case ${opt} in
        h ) usage
            exit 0
            ;;
        c ) git diff --cached --quiet || \
                die "Commit staged or use -C"
            COMMIT="true"
            ;;
        C ) COMMIT="true"
            ;;
        a ) AMMEND="true"
            ;;
        m ) COMMIT_MSG="${OPTARG}"
            ;;
        \? ) die "Invalid option -$OPTARG"
            ;;
        : ) die "Bad usage, -$OPTARG requres argument"
            ;;
    esac
done
 
stage_files  && [[ "${COMMIT}" == "true" ]] && commit_files
