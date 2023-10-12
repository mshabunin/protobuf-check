#!/bin/bash

set -ex

export CMAKE_EXPORT_COMPILE_COMMANDS=ON
export CMAKE_GENERATOR=Ninja
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export CMAKE_C_COMPILER_LAUNCHER=ccache


build_opencv() {
    D=/workspace/build-own
    mkdir -p ${D}
    pushd ${D} && rm -rf *
    cmake -GNinja \
        -DWITH_PROTOBUF=ON \
        -DBUILD_PROTOBUF=ON \
        /opencv \
            | tee /workspace/logs/build-own-cfg.txt 2>&1
    ninja \
            | tee /workspace/logs/build-own-bld.txt 2>&1
    popd
}

build_opencv
