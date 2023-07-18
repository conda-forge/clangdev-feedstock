#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
mv ${PREFIX}/bin/clang-format ${PREFIX}/bin/clang-format-${MAJOR_VERSION}

if [[ "$PKG_NAME" == "clang-format" ]]; then
  ln -sf $PREFIX/bin/clang-format-${MAJOR_VERSION} $PREFIX/bin/clang-format
fi
