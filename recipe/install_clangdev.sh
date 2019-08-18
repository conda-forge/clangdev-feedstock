#!/bin/bash
set -x -e
source $RECIPE_DIR/osx_hack.sh
cd ${SRC_DIR}/build
make install
