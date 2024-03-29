#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

./build.sh

VOLUME_SUFFIX=$(dd if=/dev/urandom bs=32 count=1 | md5sum | cut --delimiter=' ' --fields=1)

MEM_LIMIT="4g"

docker volume create uls23-output-$VOLUME_SUFFIX

# Do not change any of the parameters to docker run, these are fixed
docker run --rm \
        --memory="${MEM_LIMIT}" \
        --memory-swap="${MEM_LIMIT}" \
        --network="none" \
        --cap-drop="ALL" \
        --security-opt="no-new-privileges" \
        --shm-size="128m" \
        --pids-limit="256" \
        -v $SCRIPTPATH/test/:/input/ \
        -v uls23-output-$VOLUME_SUFFIX:/output/ \
        uls23

docker run --rm \
        -v uls23-output-$VOLUME_SUFFIX:/output/ \
        python:3.10-slim cat /output/metrics.json | python -m json.tool



docker volume rm uls23-output-$VOLUME_SUFFIX
