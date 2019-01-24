if [[ "$(uname)" == "Linux" && "$cxx_compiler" == "gxx" ]]; then
    sed -i.bak -e 's@SYSROOT_PATH_TO_BE_REPLACED_WITH_SED@'"${PREFIX}/${HOST}/sysroot"'@g' \
        lib/Driver/ToolChains/Linux_sysroot.cc && rm $_.bak

    sed -i.bak -e 's@AddPath("/usr/local/include", System, false);@AddPath("'"${PREFIX}/${HOST}/sysroot/usr/include"'", System, false);@g' \
        lib/Frontend/InitHeaderSearch.cpp && rm $_.bak
fi

if [[ "$(uname)" == "Darwin" ]]; then
    sed -i.bak -e 's@MACOSX_DEPLOYMENT_TARGET_TO_BE_REPLACED_WITH_SED@'"${MACOSX_DEPLOYMENT_TARGET}"'@g' \
        lib/Driver/ToolChains/Darwin.cpp && rm $_.bak
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
  -DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}" \
  -DLLVM_CONFIG="${PREFIX}/bin/llvm-config" \
  ..

make -j${CPU_COUNT}
make install
