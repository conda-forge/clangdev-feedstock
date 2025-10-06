#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
RESOURCE_DIR=${PREFIX}/lib/clang/${MAJOR_VERSION}
if [[ ! -d ${RESOURCE_DIR}/include ]]; then
  echo "${RESOURCE_DIR}/include not found"
  exit 1
fi
# Make sure omp.h from conda environment is found by clang
ln -sf $PREFIX/include/omp.h ${RESOURCE_DIR}/include/

ln -s "${PREFIX}/bin/clang-${MAJOR_VERSION}" "${PREFIX}/bin/clang++-${MAJOR_VERSION}"

if [[ "$target_platform" == "$build_platform" ]]; then
  RESOURCE_DIR_REF=$(${PREFIX}/bin/clang-${MAJOR_VERSION} -print-resource-dir)
  if [[ "${RESOURCE_DIR_REF}" != ${RESOURCE_DIR_REF} ]]; then
    echo "resource dir ${RESOURCE_DIR_REF} does not match expected ${RESOURCE_DIR}"
    exit 1
  fi
fi
