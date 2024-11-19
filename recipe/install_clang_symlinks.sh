#!/bin/bash
set -ex

maj_version="${PKG_VERSION%%.*}"
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang-cl"
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang-cpp"
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang"
