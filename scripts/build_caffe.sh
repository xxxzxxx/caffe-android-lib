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
WD=$(readlink -f "`dirname $0`/..")

TARGET_ABI=${1:-"armeabi-v7a,arm64-v8a,x86,x86_64"}
N_JOBS=${2:-"16"}
TARGET_ABIS=(`echo $TARGET_ABI | tr -s ',' ' '`)
TARGET_API_LEVEL=${EXPORT_TARGET_API_LEVEL:-"21"}

TPART_DIR=${WD}/3rdparty
TARGET_LIB_DIR=${TPART_DIR}/android-${TARGET_API_LEVEL}
INSTALL_DIR=${WD}/CaffeMobile/android-${TARGET_API_LEVEL}
CAFFE_ROOT=${WD}/caffe
BUILD_DIR=${CAFFE_ROOT}/build_android
USE_LMDB=
USE_BLAS=
if [ "${EXPORT_TARGET_API_LEVEL}" = "21" ]; then
    USE_LMDB="ON"
    USE_BLAS="open"
else
    USE_BLAS="eigen"
    USE_LMDB="OFF"
    export EIGEN_HOME="${TARGET_LIB_DIR}/eigen3"
fi
BUILD_ABI=""
for ABI in ${TARGET_ABIS[@]}; do
    BOOST_HOME=${TARGET_LIB_DIR}/boost/${ABI}
    GFLAGS_HOME=${TARGET_LIB_DIR}/gflags/${ABI}
#    GLOG_ROOT=${TARGET_LIB_DIR}/glog/${ABI}
    OPENCV_ROOT=${TARGET_LIB_DIR}/opencv/${ABI}/sdk/native/jni
    PROTOBUF_ROOT=${TARGET_LIB_DIR}/protobuf/${ABI}

    export OpenBLAS_HOME="${TARGET_LIB_DIR}/openblas/${ABI}"
    export LMDB_DIR=${TARGET_LIB_DIR}/lmdb/${ABI}

    rm -rf "${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"

    cd "${BUILD_DIR}"
    BUILD_ABI=${ABI}
    if [ "${ABI}" = "armeabi-v7a" ]; then
        BUILD_ABI="armeabi-v7a-hard-softfp with NEON"
    fi
    echo "-----------------------------------------------"
    echo "TARGET_LIB_DIR      :${TARGET_LIB_DIR}"
    echo "NDK_ROOT            :${NDK_ROOT}"
    echo "USE_BLAS            :${USE_BLAS}"
    echo "BUILD_ABI           :${BUILD_ABI}"
    echo "BOOST_HOME          :${BOOST_HOME}"
    echo "GFLAGS_HOME         :${GFLAGS_HOME}"
    echo "GLOG_ROOT           :${GLOG_ROOT}"
    echo "OPENCV_ROOT         :${OPENCV_ROOT}"
    echo "PROTOBUF_ROOT       :${PROTOBUF_ROOT}"
    echo "EIGEN_HOME          :${EIGEN_HOME}"
    echo "-----------------------------------------------"
    cmake -DCMAKE_TOOLCHAIN_FILE="${WD}/android-cmake/android.toolchain.cmake" \
        -DANDROID_NDK="${NDK_ROOT}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_ABI="${BUILD_ABI}" \
        -DANDROID_NATIVE_API_LEVEL=${TARGET_API_LEVEL} \
        -DANDROID_USE_OPENMP=ON \
        -DADDITIONAL_FIND_PATH="${TARGET_LIB_DIR}" \
        -DBUILD_SHARED_LIBS=ON \
        -DBUILD_python=OFF \
        -DBUILD_docs=OFF \
        -DCPU_ONLY=ON \
        -DUSE_LMDB=${USE_LMDB} \
        -DUSE_GLOG=OFF \
        -DUSE_LEVELDB=OFF \
        -DUSE_HDF5=OFF \
        -DBLAS=${USE_BLAS} \
        -DBOOST_ROOT="${BOOST_HOME}" \
        -DBoost_INCLUDE_DIR="${BOOST_HOME}/include" \
        -DGFLAGS_INCLUDE_DIR="${GFLAGS_HOME}/include" \
        -DGFLAGS_LIBRARY="${GFLAGS_HOME}/lib/libgflags.a" \
        -DOpenCV_DIR="${OPENCV_ROOT}" \
        -DPROTOBUF_PROTOC_EXECUTABLE="${TPART_DIR}/host/protobuf_host/bin/protoc" \
        -DPROTOBUF_INCLUDE_DIR="${PROTOBUF_ROOT}/include" \
        -DPROTOBUF_LIBRARY="${PROTOBUF_ROOT}/lib/libprotobuf.a" \
        -DCMAKE_INSTALL_PREFIX="${TARGET_LIB_DIR}/caffe/${ABI}" \
        ..

#        -DGLOG_INCLUDE_DIR="${GLOG_ROOT}/include" \
#        -DGLOG_LIBRARY="${GLOG_ROOT}/lib/libglog.a" \

    make -j${N_JOBS}
    rm -rf "${INSTALL_DIR}/libs/${ABI}"
    make install/strip
    mkdir -p "${INSTALL_DIR}/libs/${ABI}" 
    cp -f "${BUILD_DIR}/lib/libcaffe.so" "${INSTALL_DIR}/libs/${ABI}" 
    cp -f "${BUILD_DIR}/lib/libcaffe_jni.so" "${INSTALL_DIR}/libs/${ABI}" 
    cd "${WD}"
done