#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

usage() {
    local short_usage=( '$(/path/to/kslaves.sh [-nv] [-k <kfile>] [-Z <zfile>])' '$(kslaves [-nv] [-k <kfile>] [-Z <zfile>])' )

    if [[ "$#" -eq 1 && "$1" == "-s" ]]; then
        echo "Usage: docker run ${short_usage[0]} ..."
        return
    fi

    # > docker run $(/path/to/kslaves.sh [-nv]) IMAGE
    # > docker run $(kslaves [-nv]) IMAGE
    cat << EOF
$0: output docker formatted arguments for adding kafka broker hosts, and
optionally zookeper as well.

Usage:
    > docker run ${short_usage[0]} IMAGE

Or by adding alias to shell RC file (alias kslaves='/path/to/kslaves.sh') the
usage can be reduced to:
    > docker run ${short_usage[1]} IMAGE

Options:
    -h          Display this help menu
    -z          Add zookeper host in addition to kafka brokers
    -n          Use kafka brokers of new version 2.3 cluster (slaves 99-101)
    -k <file>   Specify kafka brokers file, formated <host_name>:<ip> delimited
                by whitespace
    -Z <file>   Specify zookeeper file, formated <host_name>:<ip> delimited
                by whitespace
EOF
}

die() {
    [[ "$#" -gt 0 ]]  && echo "$1"
    usage -s
    exit 1
}

SLAVE_FILE="${DIR}/kslaves"
ZOOKEEPER_FILE=""

while getopts ":hnzk:Z:" opt; do
    case ${opt} in
        h ) usage
            exit 0
            ;;
        n ) SLAVE_FILE="${DIR}/kslaves_new"
            ;;
        z ) ZOOKEEPER_FILE="${DIR}/zkeep"
            ;;
        k ) SLAVE_FILE="$OPTARG"
            ;;
        Z ) ZOOKEEPER_FILE="$OPTARG"
            ;;
        \? ) die "Invalid option -$OPTARG"
            ;;
        : ) die "Bad usage, -$OPTARG requres argument"
            ;;
    esac
done

host_prefix() {
    for host in $(cat $1); do
        echo -n "--add-host $host "
    done
}

host_prefix $SLAVE_FILE
[[ "${ZOOKEEPER_FILE}" ]] && host_prefix $ZOOKEEPER_FILE
