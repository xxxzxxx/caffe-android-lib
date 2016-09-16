#!/usr/bin/env bash

if [ -z "$NDK_ROOT" ]; then
    echo "Either NDK_ROOT should be set or provided as argument"
    echo "e.g., 'export NDK_ROOT=/path/to/ndk' or"
    exit 1
fi

WD=$(readlink -f "$(dirname "$0")")
cd "${WD}"

TARGET_ABI=${2:-"armeabi-v7a,arm64-v8a,x86,x86_64"}
N_JOBS=${3:-"16"}
TARGET_API_LEVELS="${1:-"14,21"}"
TARGET_API_LEVELS=(`echo $TARGET_API_LEVELS | tr -s ',' ' '`)
for TARGET_API_LEVEL in ${TARGET_API_LEVELS[@]}; do
    export EXPORT_TARGET_API_LEVEL=${TARGET_API_LEVEL}

    echo "---------------------------------------"
    echo "${0}"
    echo "EXPORT_TARGET_API_LEVEL:${EXPORT_TARGET_API_LEVEL}"
    echo "TARGET_API_LEVEL:${TARGET_API_LEVEL}"
    echo "TARGET_ABI:${TARGET_ABI}"
    echo "N_JOBS:${N_JOBS}"
    echo "---------------------------------------"
    if [ -e "./3rdparty/android-${TARGET_API_LEVEL}" ]; then
        echo "skip build 3rdparty"
    else
        echo "./build_3rdparty.sh ${TARGET_API_LEVEL} ${TARGET_ABI} ${N_JOBS}"
        ./build_3rdparty.sh ${TARGET_API_LEVEL}  ${TARGET_ABI} ${N_JOBS}
    fi
    echo "./scripts/build_caffe.sh ${TARGET_ABI} ${N_JOBS}"
    ./scripts/build_caffe.sh ${TARGET_ABI} ${N_JOBS}
done

echo "DONE!!"
