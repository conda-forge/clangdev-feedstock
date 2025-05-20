#!/bin/bash

set -ex

maj_version="${PKG_VERSION%%.*}"

ln -s $PREFIX/bin/clang  $PREFIX/bin/clang++
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang++-${maj_version}"
