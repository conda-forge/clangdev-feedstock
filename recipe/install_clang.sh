#!/bin/bash
set -x -e
source $RECIPE_DIR/osx_hack.sh
cd ${SRC_DIR}/build
make install
cd "${PREFIX}"
rm -rf lib/libclang* lib/cmake libexec share include
mv bin bin2
mkdir -p bin
cp bin2/clang-${PKG_VERSION:0:1} bin/
rm -rf bin2

ln -s "${PREFIX}/bin/clang-${PKG_VERSION:0:1}" "${PREFIX}/bin/clang-cl"
ln -s "${PREFIX}/bin/clang-${PKG_VERSION:0:1}" "${PREFIX}/bin/clang-cpp"
ln -s "${PREFIX}/bin/clang-${PKG_VERSION:0:1}" "${PREFIX}/bin/clang"
