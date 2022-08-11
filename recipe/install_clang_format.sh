#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

cd $PREFIX
rm -rf lib/cmake include lib/lib*.a libexec share

mv bin bin2
mkdir -p bin

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
cp bin2/clang-format bin/clang-format-${MAJOR_VERSION}
rm -rf bin2

if [[ "$PKG_NAME" == "clang-format" ]]; then
  ln -sf $PREFIX/bin/clang-format-${MAJOR_VERSION} $PREFIX/bin/clang-format
fi
