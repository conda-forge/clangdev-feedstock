#!/bin/bash
set -ex

# move clang-tools-extra to clang/tools/extra, see
# https://github.com/llvm/llvm-project/blob/main/clang-tools-extra/README.txt
mkdir -p llvm-project/clang/tools/extra
mv llvm-project/clang-tools-extra/* llvm-project/clang/tools/extra/

# using subproject sources has been effectively broken in LLVM 14,
# so we use the entire project, but make sure we don't pick up
# anything in-tree other than clang & the shared cmake folder
mv llvm-project/clang ./clang
mv llvm-project/cmake ./cmake
rm -rf llvm-project
cd clang

IFS='.' read -r -a PKG_VER_ARRAY <<< "${PKG_VERSION}"
# default SOVER for tagged releases is major.minor since LLVM 18
SOVER_EXT="${PKG_VER_ARRAY[0]}.${PKG_VER_ARRAY[1]}"
if [[ "${PKG_VERSION}" == *dev* ]]; then
    # otherwise with git suffix
    SOVER_EXT="${SOVER_EXT}git"
fi

# link to versioned libLTO.dylib (which is present in libllvm<major> that
# libclang<sover> depends on), as the unversioned symlink is only present
# in llvmdev, which may not be present when using clang.
sed -i.bak "s/libLTO.dylib/libLTO.${SOVER_EXT}.dylib/g" lib/Driver/ToolChains/Darwin.cpp

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  NATIVE_FLAGS="-DCMAKE_C_COMPILER=$CC_FOR_BUILD;-DCMAKE_CXX_COMPILER=$CXX_FOR_BUILD;-DCMAKE_C_FLAGS=-O2;-DCMAKE_CXX_FLAGS=-O2"
  NATIVE_FLAGS="${NATIVE_FLAGS};-DCMAKE_EXE_LINKER_FLAGS=;-DCMAKE_MODULE_LINKER_FLAGS=;-DCMAKE_SHARED_LINKER_FLAGS="
  NATIVE_FLAGS="${NATIVE_FLAGS};-DCMAKE_STATIC_LINKER_FLAGS=;-DCMAKE_PREFIX_PATH=$BUILD_PREFIX"
  CMAKE_ARGS="${CMAKE_ARGS} -DCROSS_TOOLCHAIN_FLAGS_NATIVE=${NATIVE_FLAGS}"
  CMAKE_ARGS="${CMAKE_ARGS} -DLLVM_TOOLS_BINARY_DIR=$BUILD_PREFIX/bin -DNATIVE_LLVM_DIR=$BUILD_PREFIX/lib/cmake/llvm"
else
  rm -rf $BUILD_PREFIX/bin/llvm-tblgen
fi

if [[ "$target_platform" == osx* ]]; then
  export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
  CMAKE_ARGS="$CMAKE_ARGS -DLLVM_ENABLE_LIBCXX=ON"
fi

# disable -fno-plt due to some GCC bug causing linker errors, see
# https://github.com/llvm/llvm-project/issues/51205
if [[ "$target_platform" == "linux-ppc64le" ]]; then
  CFLAGS="$(echo $CFLAGS | sed 's/-fno-plt //g')"
  CXXFLAGS="$(echo $CXXFLAGS | sed 's/-fno-plt //g')"
fi

mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCLANG_FORCE_MATCHING_LIBCLANG_SOVERSION=OFF \
  -DCLANG_INCLUDE_TESTS=OFF \
  -DCLANG_INCLUDE_DOCS=OFF \
  -DCLANG_DEFAULT_PIE_ON_LINUX=ON \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DLLVM_ENABLE_LIBXML2=FORCE_ON \
  -DLLVM_ENABLE_ZLIB=FORCE_ON \
  -DLLVM_ENABLE_ZSTD=FORCE_ON \
  -DLLVM_ENABLE_RTTI=ON \
  -DCMAKE_AR=$AR \
  -DPython3_EXECUTABLE=${BUILD_PREFIX}/bin/python \
  $CMAKE_ARGS \
  ..

make -j${CPU_COUNT}
