if [ "$(uname)" == "Linux" ]; then
    sed -i.bak -e 's@addSystemInclude(DriverArgs, CC1Args, SysRoot + "/usr/local/include");@addSystemInclude(DriverArgs, CC1Args, "'"${PREFIX}/${HOST}/sysroot/usr/include"'");@g' \
        lib/Driver/ToolChains/Linux.cpp && rm $_.bak

    sed -i.bak -e 's@AddPath("/usr/local/include", System, false);@AddPath("'"${PREFIX}/${HOST}/sysroot/usr/include"'", System, false);@g' \
        lib/Frontend/InitHeaderSearch.cpp && rm $_.bak
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
  -DLLVM_CONFIG="${PREFIX}/bin/llvm-config" \
  ..

make -j${CPU_COUNT}
make install
