#!/bin/bash
set -ex

maj_version="${PKG_VERSION%%.*}"
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang-cl"
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang-cpp"
ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang"

if [[ "$target_platform" == "linux-"* ]]; then
  source ${RECIPE_DIR}/get_cpu_triplet.sh
  CHOST=$(get_triplet $target_platform)
  ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/${CHOST}-clang"
  # for background, see comment in install_clangxx.sh
  echo "--sysroot ${PREFIX}/${CHOST}/sysroot" >> ${PREFIX}/bin/${CHOST}-clang.cfg
fi
