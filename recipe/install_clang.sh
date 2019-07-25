#!/bin/bash
cd ${SRC_DIR}
make install
cd $PREFIX
rm -rf lib/libclang* lib/cmake libexec share include
mv bin bin2
cp bin2/clang bin2/clang-cl bin2/clang-cpp bin2/clang-${PKG_VERSION:0:1} bin/
rm -rf bin2
