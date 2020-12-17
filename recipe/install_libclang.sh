#!/bin/bash
set -x -e
cd ${SRC_DIR}/build
make install

cd $PREFIX
rm -rf libexec share bin include
mv lib lib2
mkdir lib
cp lib2/${PKG_NAME}.* lib/
rm -rf lib2

