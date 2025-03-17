#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
if [[ ! -d $PREFIX/lib/clang/${MAJOR_VERSION}/include ]]; then
  echo "$PREFIX/lib/clang/${MAJOR_VERSION}/include not found"
  exit 1
fi
# Make sure omp.h from conda environment is found by clang
ln -sf $PREFIX/include/omp.h $PREFIX/lib/clang/${MAJOR_VERSION}/include/
