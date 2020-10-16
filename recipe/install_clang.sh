#!/bin/bash
set -x -e
cd ${SRC_DIR}/build
make install
cd "${PREFIX}"
rm -rf libexec share include
mv bin bin2
mkdir -p bin
maj_version="${PKG_VERSION%%.*}"
cp bin2/clang-${maj_version} bin/
rm -rf bin2

mv lib lib2
mkdir -p lib
cp lib2/libclang-cpp.* lib/
rm lib/libclang-cpp${SHLIB_EXT}
cp -Rf lib2/clang lib/
rm -rf lib2

