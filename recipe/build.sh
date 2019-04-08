mkdir build
cd build

if [[ "${target_platform}" == "osx-64" ]]; then
    LLVM_PREFIX=`pwd`/tmp
    conda create -p $LLVM_PREFIX -c conda-forge -c defaults --yes --quiet llvmdev=$PKG_VERSION libcxx=4.0.1
else
    LLVM_PREFIX=$PREFIX
fi

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$LLVM_PREFIX \
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
make install
