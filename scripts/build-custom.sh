#!/bin/bash

set -ex

export CMAKE_EXPORT_COMPILE_COMMANDS=ON
export CMAKE_GENERATOR=Ninja
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export CMAKE_C_COMPILER_LAUNCHER=ccache

VER=${1-24.4}
MAJ=${VER//\.*/}
DYN=${2-ON}
SRC=/workspace/protobuf
BLD=/workspace/build-pb-${VER}
LOG=/workspace/logs/build-custom-${VER}-${DYN}.txt

get_pb() {
    if [ ! -d ${SRC} ] ; then
        git clone --recurse-submodules https://github.com/protocolbuffers/protobuf.git ${SRC}
    fi
    pushd ${SRC}
    git clean -dfx
    git reset --hard
    git checkout ${VER}
    git clean -dfx
    git submodule update --recursive --checkout
    popd
}

build_pb() {
    D=${BLD}
    if [ ${MAJ} = "v3" ] ; then
        [ ${DYN} = "ON" ] && OPT=(--enable-shared=yes --enable-static=no) || OPT=(--enable-shared=no --enable-static=yes)
        pushd ${SRC}
        ./autogen.sh
        ./configure --prefix=${BLD}/install ${OPT[@]}
        make -j10 install
        popd
    else
        mkdir -p ${D}
        pushd ${D} && rm -rf *
        cmake -GNinja \
            -DCMAKE_BUILD_TYPE=Release \
            -Dprotobuf_BUILD_TESTS=OFF \
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DCMAKE_INSTALL_PREFIX=install \
            -Dprotobuf_BUILD_SHARED_LIBS=${DYN} \
            ${SRC}
        ninja install
        popd
    fi
}

build_opencv() {
    export LD_LIBRARY_PATH=${BLD}/install/lib:${LD_LIBRARY_PATH}
    D=/workspace/build-${VER}-${DYN}
    mkdir -p ${D}
    pushd ${D} && rm -rf *
    [ ${MAJ} = "v3" ] && OPT=() || OPT=(-Dprotobuf_MODULE_COMPATIBLE=ON -DCMAKE_CXX_STANDARD=17)
    cmake -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_PROTOBUF=ON \
        -DBUILD_PROTOBUF=OFF \
        -DCMAKE_PREFIX_PATH=${BLD}/install \
        -DPROTOBUF_UPDATE_FILES=ON \
        ${OPT[@]} \
        -DWITH_OPENCL=OFF \
        /opencv \
            | tee ${LOG/.txt/-cfg.txt}
    ninja \
        | tee ${LOG/.txt/-bld.txt}
    popd
}

get_pb
build_pb
build_opencv
