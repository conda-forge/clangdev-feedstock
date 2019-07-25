if [[ "$target_platform" == "osx-64" ]]; then
    export CONDA_BUILD_SYSROOT_BACKUP=${CONDA_BUILD_SYSROOT}
    conda install -p $BUILD_PREFIX --quiet --yes clangxx_osx-64=${cxx_compiler_version}
    export CONDA_BUILD_SYSROOT=${CONDA_BUILD_SYSROOT_BACKUP}
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
  ..

make -j${CPU_COUNT}
