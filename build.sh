#!/usr/bin/env bash
set -e

if [ -z "$NDK_ROOT" ]; then
    echo "Either NDK_ROOT should be set or provided as argument"
    echo "e.g., 'export NDK_ROOT=/path/to/ndk' or"
    echo "      '${0} /path/to/ndk'"
    exit 1
else
    NDK_ROOT=$(readlink -f "${1:-${NDK_ROOT}}")
    export NDK_ROOT="${NDK_ROOT}"
fi

WD=$(readlink -f "$(dirname "$0")")
cd "${WD}"
export ANDROID_ABI="${ANDROID_ABI:-"armeabi-v7a,arm64-v8a,x86,x86_64"}"
export N_JOBS=${N_JOBS:-1}
if ! ./scripts/build_openblas.sh ; then
    echo "Failed to build OpenBLAS"
    exit 1
fi
./scripts/build_gflags.sh
./scripts/build_glog.sh
./scripts/build_lmdb.sh
./scripts/build_protobuf_host.sh
./scripts/build_protobuf.sh
./scripts/build_boost.sh
./scripts/build_opencv.sh
./scripts/build_caffe.sh

echo "DONE!!"
