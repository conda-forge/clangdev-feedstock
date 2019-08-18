#!/bin/bash
set -x -e
source $RECIPE_DIR/osx_hack.sh
cd ${SRC_DIR}/build
make install
cd $PREFIX
rm -rf lib/libclang*.a lib/clang/${PKG_VERSION} lib/cmake libexec share bin include
