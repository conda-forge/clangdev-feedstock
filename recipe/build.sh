#!/bin/bash
set -x

IFS='.' read -r -a PKG_VER_ARRAY <<< "${PKG_VERSION}"

sed -i.bak "s/libLTO.dylib/libLTO.${PKG_VER_ARRAY[0]}.dylib/g" lib/Driver/ToolChains/Darwin.cpp

if [[ "$variant" == "hcc" ]]; then
  CMAKE_ARGS="$CMAKE_ARGS -DKALMAR_BACKEND=HCC_BACKEND_AMDGPU -DHCC_VERSION_STRING=2.7-19365-24e69cd8-24e69cd8-24e69cd8"
  CMAKE_ARGS="$CMAKE_ARGS -DHCC_VERSION_MAJOR=2 -DHCC_VERSION_MINOR=7 -DHCC_VERSION_PATCH=19365"
  CMAKE_ARGS="$CMAKE_ARGS -DKALMAR_SDK_COMMIT=24e69cd8 -DKALMAR_FRONTEND_COMMIT=24e69cd8 -DKALMAR_BACKEND_COMMIT=24e69cd8"
fi

if [[ "$variant" == "root"* ]]; then
  # Cling needs some minor patches to the LLVM sources
  sed -i "s@LLVM_LINK_LLVM_DYLIB yes@LLVM_LINK_LLVM_DYLIB no@g" "${PREFIX}/lib/cmake/llvm/LLVMConfig.cmake"
  cd "${PREFIX}"
  patch -p1 < "${RECIPE_DIR}/patches/root/llvm/0001-Fix-the-compilation.patch"
  patch -p1 < "${RECIPE_DIR}/patches/root/llvm/0002-Make-datamember-protected.patch"
  cd -

  # Hardcode the Linux sysroot as a fallback
  if [[ "$target_platform" == linux-* ]] && [[ "$cxx_compiler" == "gxx" ]]; then
      INSTALL_SYSROOT=$(python -c "import os; rel = os.path.relpath('$CONDA_BUILD_SYSROOT', '$CONDA_PREFIX'); assert not rel.startswith('.'); print(os.path.join('$PREFIX', rel))")
      echo "INSTALL_SYSROOT is ${INSTALL_SYSROOT}"
      sed -i.bak -e 's@SYSROOT_PATH_TO_BE_REPLACED_WITH_SED@'"${INSTALL_SYSROOT}"'@g' \
          lib/Driver/ToolChains/Linux_sysroot.cc && rm $_.bak

      sed -i.bak -e 's@AddPath("/usr/local/include", System, false);@AddPath("'"${INSTALL_SYSROOT}"'", System, false);@g' \
          lib/Frontend/InitHeaderSearch.cpp && rm $_.bak
  fi
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DLLVM_TABLEGEN_EXE=$BUILD_PREFIX/bin/llvm-tblgen -DNATIVE_LLVM_DIR=$BUILD_PREFIX/lib/cmake/llvm"
  CMAKE_ARGS="${CMAKE_ARGS} -DCROSS_TOOLCHAIN_FLAGS_NATIVE=-DCMAKE_C_COMPILER=$CC_FOR_BUILD;-DCMAKE_CXX_COMPILER=$CXX_FOR_BUILD;-DCMAKE_C_FLAGS=-O2;-DCMAKE_CXX_FLAGS=-O2;-DCMAKE_EXE_LINKER_FLAGS=;-DCMAKE_MODULE_LINKER_FLAGS=;-DCMAKE_SHARED_LINKER_FLAGS=;-DCMAKE_STATIC_LINKER_FLAGS=;-DLLVM_DIR=$BUILD_PREFIX/lib/cmake/llvm;"
else
  rm -rf $BUILD_PREFIX/bin/llvm-tblgen
fi

if [[ "$target_platform" == osx* ]]; then
  export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
fi

if [[ "$target_platform" == "linux-ppc64le" ]]; then
  # Needed to avoid errors when compiling with gcc 9 (not present with gcc 7)
  # > relocation truncated to fit: R_PPC64_REL24 against symbol
  export CXXFLAGS="${CXXFLAGS/O3/Os}"
  export CFLAGS="${CFLAGS/O3/Os}"
  CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_CXX_FLAGS_RELEASE=-Os"
fi

mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_RTTI=ON \
  -DCLANG_INCLUDE_TESTS=OFF \
  -DCLANG_INCLUDE_DOCS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DLLVM_ENABLE_LIBXML2=OFF \
  -DCMAKE_AR=$AR \
  $CMAKE_ARGS \
  ..

make -j${CPU_COUNT}
