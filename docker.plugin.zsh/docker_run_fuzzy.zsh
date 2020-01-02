#!/usr/bin/env zsh


# TODO: Add port flag?

# Try and grab local rockerbox-metrics current path else use preset
if [[ "$(pwd)" =~ ".*rockerbox-metrics.*" ]]; then
    LOCAL_RB_PATH="$(pwd | sed -E 's/(rockerbox-metrics).*$/\1/')"
else
    # NOTE: Set default value here
    LOCAL_RB_PATH="${HOME}/work/rockerbox/rockerbox-metrics"
fi

CONTR_RB_PATH="/root/rockerbox-metrics"

usage () {
    if [[ "$#" -eq 1 && "$1" == "-s" ]]; then
        echo "Usage: drf [flags] <docker image-hint> [<command>]"
        return
    fi

    cat << EOF
$0: execute 'docker run' with fuzzy image name matching and other command line
argument abbreviations.

Usage:
    drf [-h | -ydk] [-s | -S args] [-m size] [-n name] [-e envstr] [-v paths] \\
        [-a "args"] image-hint [command [arg1 [arg2 ...]]]

Options:
      -h                    to display this message and ignore all else
      -y                    to do a dry run my printing docker command instead
                            of executing it
      -d                    to use flags -itd instead of -it
      -k                    ommit using --rm
      -s                    to add output of \$(kslave)
      -S <args>             to add output of \$(kslave -<args>) (only leading 
                            '-' is provided), commans  replaced with  spaces
      -m <size>             for --shm-size <size>
      -n <name>             for giving the image a name instead of first  3 and
                            last 2 letters of the docker image name (after the 
                            repo name, terminated by ':' ) 
      -e <var=val,vr2=vl2>  for adding -e var=val -e vr2=vl2 to command

      -v <comma,sep,sub/paths>    to pass (note 'rbm means rockerbox-metrics):
                                    -v /cur/local/'rbm/comma:/root/'rbm/comma
                                    -v /cur/local/'rbm/sep:/root/'rbm/sep
                                    -v /cur/local/'rbm/sub/path:/root/'rbm/sub/path

      -a "<--non-delim --sep custom --args>"    to pass as:
                                                --non-delim --sep custom args

Arguments:
      <docker-image-hint>           to compare fuzzily backwards over all
                                    recently referenced images in docker
                                    commands for first match
      <command> [<c_arg1 [...]]]    (*optional) to have the comtainer run this
                                    command instead of the build CMD
EOF
}

die() {
    [[ "$#" -gt 0 ]]  && echo "$1"
    usage -s
    exit 1
}

# Zsh-ism
DIR="$(dirname $0:A)"

DRY_RUN="false"
MODE_FLAGS=" -it"
RM_FLAG=" --rm"
HOST_FLAGS=""
SHM_SIZE=""
NAME=""
ENV_MAPPING=""
VOL_MAPPING=""
RAW_ARGS=""
IMG_NAME=""
IMG_CMD=""

set_host() {
    [[ -n "${HOST_FLAGS}" && "${HOST_FLAGS}" != " " ]] && \
        die  "Cannot use -s and -S"

    if [[ "$#" -gt 0 ]]; then
        local argstr="$(echo $@ | tr ',' ' ')"
        HOST_FLAGS=" $(${DIR}/rbutil/kslaves.sh -${argstr})"
    else
        HOST_FLAGS=" $(${DIR}/rbutil/kslaves.sh)"
    fi
}

set_env() {
    local mappings=(${(s:,:)1})
    for env_var in $mappings; do
        ENV_MAPPING="${ENV_MAPPING} -e ${env_var}"
    done
}

set_vol() {
    local mappings=(${(s:,:)1})
    for vol_var in $mappings; do
        VOL_MAPPING="${VOL_MAPPING} -v ${LOCAL_RB_PATH}/${vol_var}:${CONTR_RB_PATH}/${vol_var}"
    done
}

rev_find_name() {
    # Potentially useful commands for implementing this
    # history | fzf --no-sort --filter="ls"
    # history | pcregrep -o '^ *[0-9]+\*? +\Kdocker [^ ]+' | sort -u 
    IMG_NAME=" NAME-$1"
}

while getopts ":hydksS:m:n:e:v:a:" opt; do
    case ${opt} in
        h ) usage
            exit 0
            ;;
        y ) DRY_RUN="true"
            ;;
        d ) MODE_FLAGS="${MODE_FLAGS}d"
            ;;
        k ) RM_FLAG=""
            ;;
        s ) set_host
            ;;
        S ) set_host "${OPTARG}"
            ;;
        m ) SHM_SIZE=" --shm-size ${OPTARG}"
            ;;
        n ) NAME=" --name ${OPTARG}"
            ;;
        e ) set_env "${OPTARG}"
            ;;
        v ) set_vol "${OPTARG}"
            ;;
        a ) RAW_ARGS=" ${OPTARG}"
            ;;
        \? ) die "Invalid option -$OPTARG"
            ;;
        : ) die "Bad usage, -$OPTARG requres argument"
            ;;
    esac
done

shift $((OPTIND-1))

[[ "$#" -gt 0 ]] || die "Must pass image name hint"
rev_find_name $1 ; shift

#[[ -n "${NAME}" ]] && mk_name $IMG_NAME

[[ "$#" -gt 0 ]] && IMG_CMD=" $@"

CMD="docker run${MODE_FLAGS}${RM_FLAG}${HOST_FLAGS}${SHM_SIZE}${NAME}"
CMD="${CMD}${ENV_MAPPING}${VOL_MAPPING}${RAW_ARGS}${IMG_NAME}${IMG_CMD}"

if [[ "${DRY_RUN}" == "true" ]]; then
    echo "${CMD}"
else
    echo "eval ${CMD}"
fi
