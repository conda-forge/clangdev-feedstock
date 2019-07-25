#!/bin/bash
cd ${SRC_DIR}
make install
cd $PREFIX
rm -rf lib include
