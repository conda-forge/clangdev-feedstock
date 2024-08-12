#!/bin/bash

ln -s $PREFIX/bin/clang  $PREFIX/bin/clang++

if [[ "$variant" == "hcc" ]]; then
  ln -s $PREFIX/bin/clang++  $PREFIX/bin/hcc
fi

if [[ "$target_platform" == "linux-"* ]]; then
  source ${RECIPE_DIR}/get_cpu_triplet.sh
  CHOST=$(get_triplet $target_platform)
  ln -s "${PREFIX}/bin/clang++" "${PREFIX}/bin/${CHOST}-clang++"
  # In the cross compiling case, we set CONDA_BUILD_SYSROOT to host platform
  # which makes compiling for build platform not work correctly.
  # The following overrides CONDA_BUILD_SYSROOT, so that a clang for a given
  # CHOST will always use the appropriate sysroot. In particular, this means
  # that a clang in the build environment will work correctly for its native
  # architecture also in cross compilation scenarios.
  echo "--sysroot ${PREFIX}/${CHOST}/sysroot" >> ${PREFIX}/bin/${CHOST}-clang++.cfg
fi
