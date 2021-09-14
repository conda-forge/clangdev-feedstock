#!/bin/bash
set -x -e
cd ${SRC_DIR}/build
make install
cd $PREFIX
rm -rf lib/cmake include lib/lib*.a
MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
for f in ${PREFIX}/bin/clang-*; do
    rm -f $(basename $f)-${MAJOR_VERSION}
    mv $f $(basename $f)-${MAJOR_VERSION};
    ln -s $(basename $f)-${MAJOR_VERSION} $f;
done
