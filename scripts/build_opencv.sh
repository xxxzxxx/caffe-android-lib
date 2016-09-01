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
OPENCV_ROOT=${WD}/opencv
BUILD_DIR=$OPENCV_ROOT/platforms/build_android
INSTALL_DIR=${WD}/android_lib
N_JOBS=${N_JOBS:-4}

if [ "${ANDROID_ABI}" = "armeabi" ]; then
    API_LEVEL=19
else
    API_LEVEL=21
fi

ANDROID_ABIS=(`echo $ANDROID_ABI | tr -s ',' ' '`)
BUILD_ABI=""
for ABI in ${ANDROID_ABIS[@]}; do

    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}"

    cd "${BUILD_DIR}"
    if [ "${ABI}" = "armeabi-v7a" ]; then
        BUILD_ABI="armeabi-v7a-hard-softfp with NEON"
    else
        BUILD_ABI=${ABI}
    fi
    echo "ABI=${ABI}"
    echo "BUILD_ABI=${BUILD_ABI}"

    cmake -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
        -DCMAKE_TOOLCHAIN_FILE="${WD}/android-cmake/android.toolchain.cmake" \
        -DANDROID_NDK="${NDK_ROOT}" \
        -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
        -DANDROID_ABI="${BUILD_ABI}" \
        -D WITH_CUDA=OFF \
        -D WITH_MATLAB=OFF \
        -D BUILD_WITH_STATIC_CRT=ON \
        -D BUILD_SHARED_LIBS=OFF \
        -D BUILD_opencv_java=OFF \
        -D BUILD_opencv_python=OFF \
        -D BUILD_ANDROID_EXAMPLES=OFF \
        -D BUILD_DOCS=OFF \
        -D BUILD_PERF_TESTS=OFF \
        -D BUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/opencv/${ABI}" \
        ../..

    make -j${N_JOBS}
    rm -rf "${INSTALL_DIR}/opencv/${ABI}"
    make install/strip

    cd "${WD}"
    rm -rf "${BUILD_DIR}"
done
