#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
    echo "      '${0} armeabi-v7a,arm64-v8a,x86,x86_64'"
    exit 1
elif [ -z "$NDK_ROOT" ]; then
    echo 'Either $NDK_ROOT should be set or provided as argument'
    echo "e.g., 'export NDK_ROOT=/path/to/ndk' or"
    exit 1
fi

TARGET_ABI=${1:-"armeabi-v7a,arm64-v8a,x86,x86_64"}
N_JOBS=${2:-"16"}
TARGET_ABIS=$(echo $TARGET_ABI | tr -s ',' ' ')
TARGET_API_LEVEL=${EXPORT_TARGET_API_LEVEL:-"21"}

WD=$(readlink -f "`dirname $0`/..")
BOOST_ROOT=${WD}/boost
INSTALL_DIR=${WD}/3rdparty/android-${TARGET_API_LEVEL}

cd "${BOOST_ROOT}"
./get_boost.sh
cd "${WD}"

BUILD_ABI=""
for ABI in ${TARGET_ABIS[@]}; do
    BUILD_DIR=${BOOST_ROOT}/build_android
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"

    if [ "${ABI}" = "armeabi-v7a" ]; then
        BUILD_ABI="armeabi-v7a-hard-softfp with NEON"
    else
        BUILD_ABI=${ABI}
    fi

    cmake -DCMAKE_TOOLCHAIN_FILE="${WD}/android-cmake/android.toolchain.cmake" \
        -DANDROID_NDK="${NDK_ROOT}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_ABI="${BUILD_ABI}" \
        -DANDROID_NATIVE_API_LEVEL=${TARGET_API_LEVEL} \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/boost/${ABI}" \
        ..

    make -j${N_JOBS}
    rm -rf "${INSTALL_DIR}/boost/${ABI}"
    make install/strip

    cd "${WD}"
    rm -rf "${BUILD_DIR}"
done
