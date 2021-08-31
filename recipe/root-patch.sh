#!/bin/bash
set -ex

if [[ "$variant" == "root"* ]]; then
  # Cling needs some minor patches to the LLVM sources
  sed -i "s@LLVM_LINK_LLVM_DYLIB yes@LLVM_LINK_LLVM_DYLIB no@g" "${LIBRARY_PREFIX:-$PREFIX}/lib/cmake/llvm/LLVMConfig.cmake"
  cd "${LIBRARY_PREFIX:-$PREFIX}"
  patch -p1 < "${RECIPE_DIR}/patches/root/llvm/0001-Fix-the-compilation.patch"
  patch -p1 < "${RECIPE_DIR}/patches/root/llvm/0002-Make-datamember-protected.patch"
  cd -
fi


