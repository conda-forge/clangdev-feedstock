#!/bin/bash

set -ex

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
ln -s $PREFIX/bin/clang-${MAJOR_VERSION}  $PREFIX/bin/clang++
