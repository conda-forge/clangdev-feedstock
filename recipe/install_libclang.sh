#!/bin/bash
make install
cd $PREFIX
rm -rf lib/libclang*.a lib/clang/${PKG_VERSION} lib/cmake libexec share bin include 
