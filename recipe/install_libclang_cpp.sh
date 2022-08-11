#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install VERBOSE=1

cd $PREFIX
rm -rf libexec share bin include
mv lib lib2
mkdir lib

if [[ "$PKG_NAME" == "libclang-cpp" ]]; then
    mv lib2/${PKG_NAME}${SHLIB_EXT} lib/
else
    mv lib2/libclang-cpp.*.* lib/
fi
rm -rf lib2
