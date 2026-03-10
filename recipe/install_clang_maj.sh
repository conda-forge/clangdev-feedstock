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

# Create a link from versioned <PREFIX>/lib/libLTO.22.dylib (which
# is present in libllvm<major> that libclang<sover> depends on) to a
# versioned directory as the unversioned symlink <PREFIX>/lib/libLTO.dylib
# is only present in llvmdev, which may not be present when using clang.
# the patch 0010-Look-for-libLTO.dylib-in-the-versioned-ResourceDir.patch
# changes the diretory clang looks for it.
#
# We previously patched clang to use libLTO.22.dylib, and ld64 to
# accept a LTO library named libLTO.22.dylib, but sometimes clang uses the
# system linker when a different target tuple is given and the system
# linker rejects any library not named libLTO.dylib
#
# TODO: fix clang to use the correct linker regardless of the target
# tuple
#
# TODO: figure out what happens with LTO on Linux targetting Darwin
# It seems like this is not supported upstream.

if [[ "$target_platform" == "osx-"* ]]; then
  mkdir -p "${RESOURCE_DIR}/lib"
  IFS='.' read -r -a PKG_VER_ARRAY <<< "${PKG_VERSION}"
  # default SOVER for tagged releases is major.minor since LLVM 18
  SOVER_EXT="${PKG_VER_ARRAY[0]}.${PKG_VER_ARRAY[1]}"
  if [[ "${PKG_VERSION}" == *dev* ]]; then
      # otherwise with git suffix
      SOVER_EXT="${SOVER_EXT}git"
  fi
  ln -s "${PREFIX}/lib/libLTO.${SOVER_EXT}.dylib" "${RESOURCE_DIR}/lib/libLTO.dylib"
fi

if [[ "$target_platform" == "$build_platform" ]]; then
  RESOURCE_DIR_REF=$(${PREFIX}/bin/clang-${MAJOR_VERSION} -print-resource-dir)
  if [[ "${RESOURCE_DIR_REF}" != ${RESOURCE_DIR_REF} ]]; then
    echo "resource dir ${RESOURCE_DIR_REF} does not match expected ${RESOURCE_DIR}"
    exit 1
  fi
fi
