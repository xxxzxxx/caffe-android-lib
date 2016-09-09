#!/usr/bin/env sh
set -e

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
TARGET_ABIS=(`echo $TARGET_ABI | tr -s ',' ' '`)
TARGET_API_LEVEL=${EXPORT_TARGET_API_LEVEL:-"21"}

WD=$(readlink -f "`dirname $0`/..")
OPENCV_ROOT=${WD}/opencv
BUILD_DIR=$OPENCV_ROOT/platforms/build_android
INSTALL_DIR=${WD}/3rdparty/android-${TARGET_API_LEVEL}

#if [ "${ANDROID_ABI}" = "armeabi" ]; then
#    API_LEVEL=19
#else
#    API_LEVEL=21
#fi

BUILD_ABI=""
for ABI in ${TARGET_ABIS[@]}; do

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
        -DANDROID_NATIVE_API_LEVEL=${TARGET_API_LEVEL} \
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
