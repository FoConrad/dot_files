#!/bin/sh

CONTAINER_BRANCH="feature_webhook_testing_script_merge"
SESS_NAME="pipeline_f"
PIPELINE_ROOT="${HOME}/work/rockerbox/clone"

if tmux has-session -t "${SESS_NAME}"; then
    eval exec tmux a -t "${SESS_NAME}"
fi

# TODO: There should the rockerbox repo at ${PIPELINE_ROOT}/rockerbox-metrics,
# so if it't not their, clone it


# TODO: There should be the following directory structure, if it's not made,
# make it
# ${PIPELINE_ROOT}/{var,etc,srv,sandbox}
# ${PIPELINE_ROOT}/etc/{systemd,nginx}
# ${PIPELINE_ROOT}/srv/metrics/current
# ${PIPELINE_ROOT}/var/log/nginx

# TODO: Build containers without push

    #send-keys 'docker run --rm  --name kafka_bridge  -e TOPIC="test_webhook_events" $(kslaves -nz)  $(kslaves) -it rickotoole/rockerbox-metrics:webhook-kafka-bridge-'$CONTAINER_BRANCH Enter \; \

tmux new-session -s "${SESS_NAME}" -c "${PIPELINE_ROOT}/mnt" \; \
    send-keys 'docker run --rm  --name kafka_bridge  -e TOPIC="test_webhook_events" $(kslaves -nz)  $(kslaves) -it rickotoole/rockerbox-metrics:webhook-kafka-bridge-'$CONTAINER_BRANCH \; \
    split-window -v -p 75 \; \
    split-window -v -p 66 \; \
    split-window -v -p 50 #\; \
