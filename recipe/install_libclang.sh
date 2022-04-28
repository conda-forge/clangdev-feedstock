#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

cd $PREFIX
rm -rf libexec share bin include
mv lib lib2
mkdir lib

if [[ "$PKG_NAME" == "libclang" ]]; then
    mv lib2/${PKG_NAME}${SHLIB_EXT} lib/
else
    mv lib2/libclang.*.* lib/
fi
rm -rf lib2
