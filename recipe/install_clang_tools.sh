#!/bin/bash
set -x -e
cd ${SRC_DIR}/build
make install
cd $PREFIX
rm -rf lib/cmake include lib/lib*.a
MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
for f in ${PREFIX}/bin/clang-*; do
    ln -s $f $(basename $f)-${MAJOR_VERSION};
done
