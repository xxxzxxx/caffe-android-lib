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
GLOG_ROOT=${WD}/glog
BUILD_DIR=${GLOG_ROOT}/build/
ANDROID_LIB_ROOT=${WD}/android_lib
N_JOBS=${N_JOBS:-4}

ANDROID_ABIS=(`echo $ANDROID_ABI | tr -s ',' ' '`)

GFLAGS_HOME=
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

    GFLAGS_HOME=${ANDROID_LIB_ROOT}/gflags/${ABI}

    cmake -DCMAKE_TOOLCHAIN_FILE="${WD}/android-cmake/android.toolchain.cmake" \
        -DANDROID_NDK="${NDK_ROOT}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_ABI="${BUILD_ABI}" \
        -DANDROID_NATIVE_API_LEVEL=21 \
        -DGFLAGS_INCLUDE_DIR="${GFLAGS_HOME}/include" \
        -DGFLAGS_LIBRARY="${GFLAGS_HOME}/lib/libgflags.a" \
        -DCMAKE_INSTALL_PREFIX="${ANDROID_LIB_ROOT}/glog/${ABI}" \
        ..

    make -j${N_JOBS}
    rm -rf "${ANDROID_LIB_ROOT}/glog/${ABI}"
    make install/strip

    cd "${WD}"
done
