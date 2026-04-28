#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

if [[ "${target_platform}" == "linux-64" ]]; then
  TARGET=x86_64-conda-linux-gnu
elif [[ "${target_platform}" == "linux-ppc64le" ]]; then
  TARGET=powerpc64le-conda-linux-gnu
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

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")

if [[ ! -x ${PREFIX}/bin/clang-scan-deps ]]; then
  echo "${PREFIX}/bin/clang-scan-deps not found"
  exit 1
fi

mv ${PREFIX}/bin/clang-scan-deps ${PREFIX}/bin/clang-scan-deps-${MAJOR_VERSION}
ln -s ${PREFIX}/bin/clang-scan-deps-${MAJOR_VERSION} ${PREFIX}/bin/clang-scan-deps
ln -s ${PREFIX}/bin/clang-scan-deps ${PREFIX}/bin/${TARGET}-clang-scan-deps
