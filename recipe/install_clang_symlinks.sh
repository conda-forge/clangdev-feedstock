#!/bin/bash
set -ex

if [[ "${target_platform}" == "linux-64" ]]; then
  TARGET=x86_64-conda-linux-gnu
elif [[ "${target_platform}" == "linux-"* ]]; then
  TARGET=${target_platform/linux-/}-conda-linux-gnu
elif [[ "${target_platform}" == "osx-64" ]]; then
  TARGET=x86_64-apple-darwin13.4.0
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  TARGET=arm64-apple-darwin20.0.0
else
  echo "unknown target: ${target_platform}"
  exit 1
fi

maj_version="${PKG_VERSION%%.*}"

if [[ "${PKG_NAME}" == "clang" ]]; then
  ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang-cl"
  ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang-cpp"
  ln -s "${PREFIX}/bin/clang-${maj_version}" "${PREFIX}/bin/clang"
  source ${RECIPE_DIR}/install_clang_cfg.sh
elif [[ "${PKG_NAME}" == "clangxx" ]]; then
  ln -s "${PREFIX}/bin/clang-${maj_version}"  ${PREFIX}/bin/clang++
elif [[ "${PKG_NAME}" == "clangxx_impl_"* ]]; then
  ln -s "${PREFIX}/bin/clang-${maj_version}"  ${PREFIX}/bin/${TARGET}-clang++
elif [[ "${PKG_NAME}" == "clang_impl_"* ]]; then
  ln -s "${PREFIX}/bin/clang-${maj_version}"  ${PREFIX}/bin/${TARGET}-clang
  ln -s "${PREFIX}/bin/clang-${maj_version}"  ${PREFIX}/bin/${TARGET}-clang-cpp
fi
