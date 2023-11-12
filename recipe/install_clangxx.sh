#!/bin/bash

ln -s $PREFIX/bin/clang  $PREFIX/bin/clang++
ln -s $PREFIX/bin/clang  $PREFIX/bin/$HOST-clang++

if [[ "$variant" == "hcc" ]]; then
  ln -s $PREFIX/bin/clang++  $PREFIX/bin/hcc
fi

if [[ "$target_platform" == "linux-"* ]]; then
  source ${RECIPE_DIR}/get_cpu_triplet.sh
  CHOST=$(get_triplet $target_platform)
  ln -s "${PREFIX}/bin/clang++" "${PREFIX}/bin/${CHOST}-clang++"
  # In cross compiling case we set CONDA_BUILD_SYSROOT to host platform
  # which makes compiling for build platform not work correctly.
  # This overrides CONDA_BUILD_SYSROOT so that native compilation
  # works correctly in cross compilation scenarios.
  echo "--sysroot ${PREFIX}/${CHOST}/sysroot" >> ${PREFIX}/bin/${CHOST}-clang++.cfg
fi
