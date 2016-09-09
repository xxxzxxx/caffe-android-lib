#!/usr/bin/env bash
set -e

if [ -z "$NDK_ROOT" ]; then
    echo "Either NDK_ROOT should be set or provided as argument"
    echo "e.g., 'export NDK_ROOT=/path/to/ndk' or"
    exit 1
fi

WD=$(readlink -f "$(dirname "$0")")
cd "${WD}"

export EXPORT_TARGET_API_LEVEL="${1:-"21"}"
TARGET_ABI=${2:-"armeabi-v7a,arm64-v8a,x86,x86_64"}
N_JOBS=${3:-"16"}
#export EXPORT_TARGET_API_LEVEL="${EXPORT_TARGET_API_LEVEL:"21"}"
#export EXPORT_TARGET_API_LEVEL="${3:"14"}"
TARGET_API_LEVEL=${EXPORT_TARGET_API_LEVEL}
USE_BLAS=
if [ "${TARGET_API_LEVEL}" = "21" ]; then
    USE_BLAS="open"
else
#    TARGET_ABI="${1:-"armeabi-v7a,x86"}"
    USE_BLAS="eigen"
fi

echo "---------------------------------------"
echo "${0}"
echo "EXPORT_TARGET_API_LEVEL:${EXPORT_TARGET_API_LEVEL}"
echo "TARGET_API_LEVEL:${TARGET_API_LEVEL}"
echo "USE_BLAS:${USE_BLAS}"
echo "TARGET_ABI:${TARGET_ABI}"
echo "N_JOBS:${N_JOBS}"
echo "---------------------------------------"

echo "./scripts/build_protobuf_host.sh ${N_JOBS}"
./scripts/build_protobuf_host.sh ${N_JOBS}
echo "./scripts/build_protobuf.sh ${TARGET_ABI} ${N_JOBS}"
./scripts/build_protobuf.sh ${TARGET_ABI} ${N_JOBS}
echo "./scripts/build_gflags.sh ${TARGET_ABI} ${N_JOBS}"
./scripts/build_gflags.sh ${TARGET_ABI} ${N_JOBS}

if [ "${EXPORT_TARGET_API_LEVEL}" = "21" ]; then
#echo "./scripts/build_glog.sh ${TARGET_ABI} ${N_JOBS}"
#./scripts/build_glog.sh ${TARGET_ABI} ${N_JOBS}
    echo "./scripts/build_lmdb.sh ${TARGET_ABI} ${N_JOBS}"
    ./scripts/build_lmdb.sh ${TARGET_ABI} ${N_JOBS}
fi

if [ "${USE_BLAS}" = "open" ]; then
    echo "./scripts/build_openblas.sh ${TARGET_ABI} ${N_JOBS}"
    if ! ./scripts/build_openblas.sh ${TARGET_ABI} ${N_JOBS} ; then
        echo "Failed to build OpenBLAS"
        exit 1
    fi
else
    echo "./scripts/get_eigen.sh"
    ./scripts/get_eigen.sh
fi

echo "./scripts/build_boost.sh ${TARGET_ABI} ${N_JOBS}"
./scripts/build_boost.sh ${TARGET_ABI} ${N_JOBS}
echo "./scripts/build_opencv.sh ${TARGET_ABI} ${N_JOBS}"
./scripts/build_opencv.sh ${TARGET_ABI} ${N_JOBS}

echo "DONE!!"
