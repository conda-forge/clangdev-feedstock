#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")

if [[ "$PKG_NAME" == "clang-format" ]]; then
  # this branch gets executed _after_ the one below,
  # so there's a versioned binary to symlink to
  rm ${PREFIX}/bin/clang-format
  ln -sf $PREFIX/bin/clang-format-${MAJOR_VERSION} $PREFIX/bin/clang-format
else
  mv ${PREFIX}/bin/clang-format ${PREFIX}/bin/clang-format-${MAJOR_VERSION}
fi
