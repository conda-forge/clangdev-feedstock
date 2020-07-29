set -x

if [[ "${clang_variant}" == root* ]]; then
  # For the cling variants we use the sources from the ROOT fork
  cd root-source/interpreter/llvm/src/tools/clang
fi

if [[ "$(uname)" == "Linux" ]]; then
  patch -p0 -i "${RECIPE_DIR}/disable-libxml2-detection.patch"
  patch -p1 -i "${RECIPE_DIR}/Manually-set-linux-sysroot-for-conda.patch"
  patch -p1 -i "${RECIPE_DIR}/Use-external-char-instead-of-std-string-to-avoid-pre.patch"
fi
if [[ "$(uname)" == "Darwin" ]]; then
  patch -p1 -i "${RECIPE_DIR}/Improve-logic-for-finding-the-macos-sysroot-for-cond.patch"
fi

if [[ "$(uname)" == "Linux" && "$cxx_compiler" == "gxx" ]]; then
    INSTALL_SYSROOT=$(python -c "import os; rel = os.path.relpath('$CONDA_BUILD_SYSROOT', '$CONDA_PREFIX'); assert not rel.startswith('.'); print(os.path.join('$PREFIX', rel))")
    echo "INSTALL_SYSROOT is ${INSTALL_SYSROOT}"
    sed -i.bak -e 's@SYSROOT_PATH_TO_BE_REPLACED_WITH_SED@'"${INSTALL_SYSROOT}"'@g' \
        lib/Driver/ToolChains/Linux_sysroot.cc && rm $_.bak

    sed -i.bak -e 's@AddPath("/usr/local/include", System, false);@AddPath("'"${INSTALL_SYSROOT}"'", System, false);@g' \
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
