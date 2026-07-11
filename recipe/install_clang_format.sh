#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
mv ${PREFIX}/bin/clang-format ${PREFIX}/bin/clang-format-${MAJOR_VERSION}

if [[ "$PKG_NAME" == "clang-format" ]]; then
  ln -sf $PREFIX/bin/clang-format-${MAJOR_VERSION} $PREFIX/bin/clang-format
fi

# Install git-clang-format
if [[ "$PKG_NAME" == "clang-format" ]]; then
  cp ${SRC_DIR}/clang/tools/clang-format/git-clang-format ${PREFIX}/bin/
  chmod +x ${PREFIX}/bin/git-clang-format
fi
