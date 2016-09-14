#!/bin/sh


function copy_module() {
    TARGET_MODULE=$1
    TARGET_DIRECTORY=$2
    mkdir -p 3rdparty/${TARGET_MODULE}
    TARGET_ARCH=arm64-v8a
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/include ./3rdparty/${TARGET_MODULE}/include
    mkdir -p 3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/lib/** ./3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    TARGET_ARCH=armeabi-v7a
    mkdir -p 3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/lib/** ./3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    TARGET_ARCH=x86
    mkdir -p 3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/lib/** ./3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    TARGET_ARCH=x86_64
    mkdir -p 3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/lib/** ./3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
}

function copy_opencv() {
    TARGET_MODULE=opencv
    TARGET_DIRECTORY=$1
    mkdir -p 3rdparty/${TARGET_MODULE}
    TARGET_ARCH=arm64-v8a
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/sdk/native/jni/include ./3rdparty/${TARGET_MODULE}/include
    mkdir -p 3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/sdk/native/libs/${TARGET_ARCH}/** ./3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    TARGET_ARCH=armeabi-v7a
    mkdir -p 3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/sdk/native/libs/armeabi-v7a-hard/** ./3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    TARGET_ARCH=x86
    mkdir -p 3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/sdk/native/libs/${TARGET_ARCH}/** ./3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    TARGET_ARCH=x86_64
    mkdir -p 3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
    cp -fR ${TARGET_DIRECTORY}/${TARGET_MODULE}/${TARGET_ARCH}/sdk/native/libs/${TARGET_ARCH}/** ./3rdparty/${TARGET_MODULE}/libs/${TARGET_ARCH}
}

copy_module boost android_lib
copy_module lmdb android_lib
copy_module gflags android_lib
copy_module glog android_lib
copy_module protobuf android_lib
copy_module protobuf_host android_lib
copy_module openblas android_lib
copy_opencv android_lib
copy_module caffe android_lib
