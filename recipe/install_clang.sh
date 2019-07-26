#!/bin/bash
set -x -e
cd ${SRC_DIR}/build
make install
cd $PREFIX
rm -rf lib/libclang* lib/cmake libexec share include
mv bin bin2
mkdir -p bin
cp bin2/clang-${PKG_VERSION:0:1} bin/
rm -rf bin2

ln -s bin/clang-${PKG_VERSION:0:1} bin/clang-cl
ln -s bin/clang-${PKG_VERSION:0:1} bin/clang-cpp
ln -s bin/clang-${PKG_VERSION:0:1} bin/clang
