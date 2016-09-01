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
N_JOBS=${N_JOBS:-4}
CAFFE_ROOT=${WD}/caffe

ANDROID_LIB_ROOT=${WD}/android_lib

ANDROID_ABIS=(`echo $ANDROID_ABI | tr -s ',' ' '`)

BUILD_DIR=${CAFFE_ROOT}/build_android
GFLAGS_HOME=
BUILD_ABI=""
for ABI in ${ANDROID_ABIS[@]}; do
    BOOST_HOME=${ANDROID_LIB_ROOT}/boost/${ABI}
    GFLAGS_HOME=${ANDROID_LIB_ROOT}/gflags/${ABI}
    GLOG_ROOT=${ANDROID_LIB_ROOT}/glog/${ABI}
    OPENCV_ROOT=${ANDROID_LIB_ROOT}/opencv/${ABI}/sdk/native/jni
    PROTOBUF_ROOT=${ANDROID_LIB_ROOT}/protobuf/${ABI}
    export LMDB_DIR=${ANDROID_LIB_ROOT}/lmdb/${ABI}
    export OpenBLAS_HOME="${ANDROID_LIB_ROOT}/openblas/${ABI}"

    rm -rf "${BUILD_DIR}"
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
        -DANDROID_NATIVE_API_LEVEL=21 \
        -DANDROID_USE_OPENMP=ON \
        -DADDITIONAL_FIND_PATH="${ANDROID_LIB_ROOT}" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_python=OFF \
        -DBUILD_docs=OFF \
        -DCPU_ONLY=ON \
        -DUSE_LMDB=ON \
        -DUSE_LEVELDB=OFF \
        -DUSE_HDF5=OFF \
        -DBLAS=open \
        -DBOOST_ROOT="${BOOST_HOME}" \
        -DGFLAGS_INCLUDE_DIR="${GFLAGS_HOME}/include" \
        -DGFLAGS_LIBRARY="${GFLAGS_HOME}/lib/libgflags.a" \
        -DGLOG_INCLUDE_DIR="${GLOG_ROOT}/include" \
        -DGLOG_LIBRARY="${GLOG_ROOT}/lib/libglog.a" \
        -DOpenCV_DIR="${OPENCV_ROOT}" \
        -DPROTOBUF_PROTOC_EXECUTABLE="${ANDROID_LIB_ROOT}/protobuf_host/${ABI}/bin/protoc" \
        -DPROTOBUF_INCLUDE_DIR="${PROTOBUF_ROOT}/include" \
        -DPROTOBUF_LIBRARY="${PROTOBUF_ROOT}/lib/libprotobuf.a" \
        -DCMAKE_INSTALL_PREFIX="${ANDROID_LIB_ROOT}/caffe/${ABI}" \
        ..

    make -j${N_JOBS}
    rm -rf "${ANDROID_LIB_ROOT}/caffe/${ABI}"
    make install/strip

    cd "${WD}"

done