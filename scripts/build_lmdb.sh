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

if [ "$(uname)" = "Darwin" ]; then
    OS=darwin
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
    OS=linux
elif [ "$(expr substr $(uname -s) 1 10)" = "MINGW32_NT" ||
       "$(expr substr $(uname -s) 1 9)" = "CYGWIN_NT" ]; then
    OS=windows
else
    echo "Unknown OS"
    exit 1
fi

if [ "$(uname -m)" = "x86_64"  ]; then
    BIT=x86_64
else
    BIT=x86
fi

WD=$(readlink -f "`dirname $0`/..")
LMDB_ROOT=${WD}/lmdb/libraries/liblmdb
INSTALL_DIR=${WD}/3rdparty/android-${TARGET_API_LEVEL}

BUILD_ABI=""
for ABI in ${TARGET_ABIS[@]}; do
    cd "${LMDB_ROOT}"
    echo "ABI=${ABI}"

    if [ "${ABI}" = "armeabi-v7a" ]; then
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/arm-linux-androideabi-gcc --sysroot=$NDK_ROOT/platforms/android-${TARGET_API_LEVEL}/arch-arm"
        AR=$TOOLCHAIN_DIR/arm-linux-androideabi-ar
    elif [ "${ABI}" = "armeabi" ]; then
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/arm-linux-androideabi-gcc --sysroot=$NDK_ROOT/platforms/android-${TARGET_API_LEVEL}/arch-arm"
        AR=$TOOLCHAIN_DIR/arm-linux-androideabi-ar
    elif [ "${ABI}" = "arm64-v8a" ]; then
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/aarch64-linux-android-gcc --sysroot=$NDK_ROOT/platforms/android-${TARGET_API_LEVEL}/arch-arm64"
        AR=$TOOLCHAIN_DIR/aarch64-linux-android-ar
    elif [ "${ABI}" = "x86" ]; then
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/x86-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/i686-linux-android-gcc --sysroot=$NDK_ROOT/platforms/android-${TARGET_API_LEVEL}/arch-x86"
        AR=$TOOLCHAIN_DIR/i686-linux-android-ar
    elif [ "${ABI}" = "x86_64" ]; then
        TOOLCHAIN_DIR=$NDK_ROOT/toolchains/x86_64-4.9/prebuilt/${OS}-${BIT}/bin
        CC="$TOOLCHAIN_DIR/x86_64-linux-android-gcc --sysroot=$NDK_ROOT/platforms/android-${TARGET_API_LEVEL}/arch-x86_64"
        AR=$TOOLCHAIN_DIR/x86_64-linux-android-ar
    else
        echo "Error: not support LMDB for ABI: ${ABI}"
        exit 1
    fi

    make clean
    make -j${N_JOBS} CC="${CC}" AR="${AR}" XCFLAGS="-DMDB_DSYNC=O_SYNC -DMDB_USE_ROBUST=0"

    rm -rf "$INSTALL_DIR/lmdb/${ABI}"
    make prefix="$INSTALL_DIR/lmdb/${ABI}" install

    cd "${WD}"
done
