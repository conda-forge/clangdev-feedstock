#!/bin/bash
set -x -e
cd ${SRC_DIR}/build
make install
cd $PREFIX
rm -rf lib/cmake include
