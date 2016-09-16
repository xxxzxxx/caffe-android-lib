#!/usr/bin/env bash

N_JOBS=${1:-"16"}

WD=$(readlink -f "`dirname $0`/..")
PROTOBUF_ROOT=${WD}/protobuf
BUILD_DIR=${PROTOBUF_ROOT}/build_protobuf_hot
INSTALL_DIR=${WD}/3rdparty/host

if [ -f "${INSTALL_DIR}/protobuf_host/bin/protoc" ]; then
    echo "Found host protoc"
    exit 0
fi

BUILD_ABI=""
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

cmake -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/protobuf_host" \
    -Dprotobuf_BUILD_TESTS=OFF \
    ../cmake

make -j${N_JOBS}
rm -rf "${INSTALL_DIR}/protobuf_host"
make install/strip

cd "${WD}"
rm -rf "${BUILD_DIR}"
