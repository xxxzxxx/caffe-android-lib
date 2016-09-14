#!/usr/bin/env sh
[[ -n $DEBUG_BUILD ]] && set -x

EIGEN_VER1=3
EIGEN_VER2=2
EIGEN_VER3=7

EIGEN_DOWNLOAD_LINK="http://bitbucket.org/eigen/eigen/get/${EIGEN_VER1}.${EIGEN_VER2}.${EIGEN_VER3}.tar.bz2"
EIGEN_TAR="eigen_${EIGEN_VER1}.${EIGEN_VER2}.${EIGEN_VER3}.tar.bz2"
EIGEN_DIR=eigen3

WD=$(readlink -f "`dirname $0`/..")

TARGET_API_LEVEL=${EXPORT_TARGET_API_LEVEL:-"21"}
EIGEN_DOWNLOAD_DIR=${WD}/download
EIGEN_INSTALL_DIR=${WD}/3rdparty/android-${TARGET_API_LEVEL}



[ ! -d ${EIGEN_INSTALL_DIR} ] && mkdir -p ${EIGEN_INSTALL_DIR}
[ ! -d ${EIGEN_DOWNLOAD_DIR} ] && mkdir -p ${EIGEN_DOWNLOAD_DIR}

cd "${EIGEN_DOWNLOAD_DIR}"
if [ ! -f ${EIGEN_TAR} ]; then
    wget -O ${EIGEN_TAR} ${EIGEN_DOWNLOAD_LINK}
fi

if [ ! -d "${EIGEN_INSTALL_DIR}/${EIGEN_DIR}" ]; then
    tar -jxf ${EIGEN_TAR}
    mv eigen-eigen-*/ "${EIGEN_INSTALL_DIR}/${EIGEN_DIR}"
fi

cd "${WD}"