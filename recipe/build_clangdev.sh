set -x

if [[ "${clang_variant}" == root* ]]; then
  # For the cling variants we use the sources from the ROOT fork
  cd root-source/interpreter/llvm/src/tools/clang
fi

if [[ "$(uname)" == "Linux" ]]; then
  patch -p0 -i "${RECIPE_DIR}/disable-libxml2-detection.patch"
  patch -p1 -i "${RECIPE_DIR}/Manually-set-linux-sysroot-for-conda.patch"
  patch -p1 -i "${RECIPE_DIR}/Use-external-char-instead-of-std-string-to-avoid-pre.patch"
  patch -p0 -i "${RECIPE_DIR}/cross-compile.diff"
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

if [[ "$CC_FOR_BUILD" != "" && "$CC_FOR_BUILD" != "$CC" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DLLVM_TABLEGEN_EXE=$BUILD_PREFIX/bin/llvm-tblgen -DNATIVE_LLVM_DIR=$BUILD_PREFIX/lib/cmake/llvm"
  CMAKE_ARGS="${CMAKE_ARGS} -DCROSS_TOOLCHAIN_FLAGS_NATIVE=-DCMAKE_C_COMPILER=$CC_FOR_BUILD;-DCMAKE_CXX_COMPILER=$CXX_FOR_BUILD;-DCMAKE_C_FLAGS=-O2;-DCMAKE_CXX_FLAGS=-O2;-DCMAKE_EXE_LINKER_FLAGS=;-DCMAKE_MODULE_LINKER_FLAGS=;-DCMAKE_SHARED_LINKER_FLAGS=;-DCMAKE_STATIC_LINKER_FLAGS=;"
  # HACK: This should be fixed in llvmdev
  (cd "${PREFIX}/lib/cmake/llvm/" && patch -p4) < "${RECIPE_DIR}/0001-Apply-https-reviews.llvm.org-D39299.patch"
  patch -p6 < "${RECIPE_DIR}/dont-use-llvm-config.patch"
else
  CMAKE_ARGS="${CMAKE_ARGS} -DLLVM_CONFIG=${PREFIX}/bin/llvm-config"
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
  ${CMAKE_ARGS} \
  ..

make -j${CPU_COUNT}
make install
