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

sed -i.bak "s/libLTO.dylib/libLTO.${PKG_VER_ARRAY[0]}.dylib/g" lib/Driver/ToolChains/Darwin.cpp

if [[ "$variant" == "hcc" ]]; then
  CMAKE_ARGS="$CMAKE_ARGS -DKALMAR_BACKEND=HCC_BACKEND_AMDGPU -DHCC_VERSION_STRING=2.7-19365-24e69cd8-24e69cd8-24e69cd8"
  CMAKE_ARGS="$CMAKE_ARGS -DHCC_VERSION_MAJOR=2 -DHCC_VERSION_MINOR=7 -DHCC_VERSION_PATCH=19365"
  CMAKE_ARGS="$CMAKE_ARGS -DKALMAR_SDK_COMMIT=24e69cd8 -DKALMAR_FRONTEND_COMMIT=24e69cd8 -DKALMAR_BACKEND_COMMIT=24e69cd8"
fi

if [[ "$variant" == "root"* ]]; then
  # Cling needs some minor patches to the LLVM sources
  sed -i.bak "s@LLVM_LINK_LLVM_DYLIB yes@LLVM_LINK_LLVM_DYLIB no@g" "${PREFIX}/lib/cmake/llvm/LLVMConfig.cmake"
  if [[ "${target_platform}" = linux* ]]; then
    default_sysroot=$PREFIX/$(echo $CONDA_BUILD_SYSROOT | sed "s@$BUILD_PREFIX@@")
    echo "Setting -DDEFAULT_SYSROOT=${default_sysroot}"
    CMAKE_ARGS="$CMAKE_ARGS -DDEFAULT_SYSROOT=${default_sysroot}"
  fi
  rootversion=$((${variant:5}))
  # ROOT 6.30 sets the minimum required C++ standard version to 17.
  # In 6.30.04 a patch to clang from upstream was introduced that also enforces
  # this requirement on the build of clang. Since we are already building clang
  # for ROOT specifically, also set the C++ standard for the build.
  if [[ $rootversion -ge 63004 ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_CXX_STANDARD=17"
    # Should deal with errors found on MacOS of the type
    # note: 'shared_mutex' has been explicitly marked unavailable here
    # See https://github.com/conda-forge/dealii-feedstock/pull/22
    if [[ "$target_platform" == "osx-64" ]]; then
      export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
    fi
  fi
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DLLVM_TOOLS_BINARY_DIR=$BUILD_PREFIX/bin -DNATIVE_LLVM_DIR=$BUILD_PREFIX/lib/cmake/llvm"
  CMAKE_ARGS="${CMAKE_ARGS} -DCROSS_TOOLCHAIN_FLAGS_NATIVE=-DCMAKE_C_COMPILER=$CC_FOR_BUILD;-DCMAKE_CXX_COMPILER=$CXX_FOR_BUILD;-DCMAKE_C_FLAGS=-O2;-DCMAKE_CXX_FLAGS=-O2;-DCMAKE_EXE_LINKER_FLAGS=;-DCMAKE_MODULE_LINKER_FLAGS=;-DCMAKE_SHARED_LINKER_FLAGS=;-DCMAKE_STATIC_LINKER_FLAGS=;-DZLIB_ROOT=$BUILD_PREFIX"
else
  rm -rf $BUILD_PREFIX/bin/llvm-tblgen
fi

if [[ "$target_platform" == osx* ]]; then
  export CXXFLAGS="$CXXFLAGS -DTARGET_OS_OSX=1"
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
  -DLLVM_ENABLE_RTTI=ON \
  -DCLANG_INCLUDE_TESTS=OFF \
  -DCLANG_INCLUDE_DOCS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DLLVM_ENABLE_LIBXML2=OFF \
  -DCMAKE_AR=$AR \
  -DPython3_EXECUTABLE=${BUILD_PREFIX}/bin/python \
  $CMAKE_ARGS \
  ..

make -j${CPU_COUNT}
