#!/usr/bin/env bash
set -e -o pipefail

if [[ "${TRANSMISSION_DATA_DIR}" == "" ]]; then
    echo "TRANSMISSION_DATA_DIR environment variable cannot be empty"
    echo "Please set the path to the base dir for Transmission's data using this environment variable!"
    exit 1
fi

TRANSMISSION_HOME_DIR="${TRANSMISSION_DATA_DIR:?}/transmission-home"
TRANSMISSION_COMPLETED_DIR="${TRANSMISSION_DATA_DIR:?}/completed"
TRANSMISSION_INCOMPLETE_DIR="${TRANSMISSION_DATA_DIR:?}/incomplete"
TRANSMISSION_WATCH_DIR="${TRANSMISSION_DATA_DIR:?}/watch"

setup_transmission() {
    echo "Setting up transmission ..."

    mkdir -p \
        ${TRANSMISSION_HOME_DIR:?} \
        ${TRANSMISSION_COMPLETED_DIR:?} \
        ${TRANSMISSION_INCOMPLETE_DIR:?} \
        ${TRANSMISSION_WATCH_DIR:?}

    if [[ "${PRE_LAUNCH_HOOK}" != "" ]]; then
        echo "PRE_LAUNCH_HOOK is non-empty ..."
        echo "PRE_LAUNCH_HOOK=\"${PRE_LAUNCH_HOOK:?}\""
        echo "PRE_LAUNCH_HOOK_ARGS=\"${PRE_LAUNCH_HOOK_ARGS}\""
        echo -e "Invoking Pre-launch hook ...\n\n$(realpath ${PRE_LAUNCH_HOOK:?}) ${PRE_LAUNCH_HOOK_ARGS}\n\n"
        $(realpath ${PRE_LAUNCH_HOOK:?}) ${PRE_LAUNCH_HOOK_ARGS}
    fi

    echo
}

start_transmission() {
    echo "Starting transmission daemon ..."
    exec transmission-daemon --foreground --config-dir ${TRANSMISSION_HOME_DIR:?} --logfile /dev/stdout
}

setup_transmission
start_transmission
