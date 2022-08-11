#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

cd $PREFIX
rm -rf libexec share bin include
mv lib lib2
mkdir lib
mv lib2/${PKG_NAME}.* lib/
rm -rf lib2
