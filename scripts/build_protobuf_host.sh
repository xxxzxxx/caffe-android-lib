#!/usr/bin/env sh
set -e

WD=$(readlink -f "`dirname $0`/..")
PROTOBUF_ROOT=${WD}/protobuf
BUILD_DIR=${PROTOBUF_ROOT}/build_protobuf_hot
INSTALL_DIR=${WD}/android_lib
N_JOBS=${N_JOBS:-4}

if [ -f "${INSTALL_DIR}/protobuf_host/bin/protoc" ]; then
    echo "Found host protoc"
    exit 0
fi

ANDROID_ABIS=(`echo $ANDROID_ABI | tr -s ',' ' '`)
BUILD_ABI=""
for ABI in ${ANDROID_ABIS[@]}; do
    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"

    if [ "${ABI}" = "armeabi-v7a" ]; then
        BUILD_ABI="armeabi-v7a-hard-softfp with NEON"
    else
        BUILD_ABI=${ABI}
    fi

    cmake -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/protobuf_host/${ABI}" \
        -Dprotobuf_BUILD_TESTS=OFF \
        ../cmake

    make -j${N_JOBS}
    rm -rf "${INSTALL_DIR}/protobuf_host/${ABI}"
    make install/strip

    cd "${WD}"
    rm -rf "${BUILD_DIR}"

done