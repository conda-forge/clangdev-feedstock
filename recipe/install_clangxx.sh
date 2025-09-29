#!/bin/bash

set -ex

maj_version="${PKG_VERSION%%.*}"

ln -s $PREFIX/bin/clang  $PREFIX/bin/clang++
