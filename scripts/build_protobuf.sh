#!/usr/bin/env sh
set -e

if [ -z "$NDK_ROOT" ] && [ "$#" -eq 0 ]; then
    echo 'Either $NDK_ROOT should be set or provided as argument'
    echo "e.g., 'export NDK_ROOT=/path/to/ndk' or"
    echo "      '${0} /path/to/ndk'"
    exit 1
else
    NDK_ROOT="${1:-${NDK_ROOT}}"
fi

ANDROID_ABI=${ANDROID_ABI:-"armeabi-v7a with NEON"}
WD=$(readlink -f "`dirname $0`/..")
PROTOBUF_ROOT=${WD}/protobuf
BUILD_DIR=${PROTOBUF_ROOT}/build_protobuf
INSTALL_DIR=${WD}/android_lib
N_JOBS=${N_JOBS:-4}

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

    cmake -DCMAKE_TOOLCHAIN_FILE="${WD}/android-cmake/android.toolchain.cmake" \
        -DANDROID_NDK=${NDK_ROOT} \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_ABI="${BUILD_ABI}" \
        -DANDROID_NATIVE_API_LEVEL=21 \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}/protobuf/${ABI} \
        -Dprotobuf_BUILD_TESTS=OFF \
        ../cmake

    make -j${N_JOBS}
    rm -rf "${INSTALL_DIR}/protobuf/${ABI}"
    make install/strip

    cd "${WD}"
    rm -rf ${BUILD_DIR}
done