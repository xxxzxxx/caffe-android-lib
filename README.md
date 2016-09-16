Caffe-Android-Lib
===============
## Goal
Porting [caffe](https://github.com/BVLC/caffe) to android platform

### Support
* Up-to-date caffe ([d91572d](https://github.com/BVLC/caffe/commit/d91572da2ea5e63c9eaacaf013dfbcbc0ada5f67))
* CPU only
* Without support for some IO libs (leveldb and hdf5)
* Switching BLAS type  open or eigen

## Build
Tested with Android NDK r10e and cmake 3.4.2 on OSX and Ubuntu 14.04

### Setup
android ndk has been installed

```shell
export NDK_ROOT="<android-ndk-root-path>"
```

### Setup OSX

Create a symbolic link of greadlink named readlink
```shell
brew install coreutils gnu-sed gawk
cd /usr/local/bin
ln -s greadlink readlink
```

### Run Build script

```shell
cd <path/to/sourcedir>
git clone --recursive https://github.com/xxxzxxx/caffe-android-lib.git
cd caffe-android-lib
./build_caffe.sh <android-api-level 14 or 21> <architecture armeabi-v7a,arm64-v8a,x86,x86_64> build_jobs<number>
```

## Issues

Any comments, issues or PRs are welcomed.
Thanks.

## TODO
- [ ] integrate using CMake's ExternalProject
- [ ] add IO dependency support (i.e., leveldb and hdf5)
- [ ] OpenCL support
- [ ] CUDA suuport

