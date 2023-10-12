#!/bin/bash

set -e

ROOT="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

mkdir -p "${ROOT}/workspace"
mkdir -p "${ROOT}/workspace/logs"

build_image(){
    TAG=$1
    DF=$2
    echo "Building ${TAG} => ${DF}"
    docker build -t ${TAG} -f ${DF} "${ROOT}"
}

run_image() {
    TAG=$1
    SCR=$2
    shift 2
    docker run -it \
        -v "${ROOT}/../opencv:/opencv" \
        -v "${ROOT}/../opencv_contrib:/opencv_contrib" \
        -v "${ROOT}/../opencv_extra:/opencv_extra" \
        -v "${ROOT}/scripts:/scripts:ro" \
        -v "${ROOT}/workspace:/workspace" \
        -u $(id -u):$(id -g) \
        -e CCACHE_DIR=/workspace/.ccache \
        ${TAG} \
        ${SCR} $@
}

build_image opencv-protobuf-check-base Dockerfile-base
build_image opencv-protobuf-check-system Dockerfile-system

run_image opencv-protobuf-check-system /scripts/build-system.sh
run_image opencv-protobuf-check-base /scripts/build-own.sh

# for v in v21.12 v3.20.3 ; do
for v in v24.4 v23.4 v22.5 v21.12 v3.20.3 ; do
for d in ON OFF ; do
run_image \
    opencv-protobuf-check-base \
    /scripts/build-custom.sh $v $d
done 
done

# run_image opencv-protobuf-check-system bash
