#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install VERBOSE=1
