#!/bin/bash
set -ex

# move clang-tools-extra to clang/tools/extra, see
# https://github.com/llvm/llvm-project/blob/main/clang-tools-extra/README.txt
mkdir -p ./clang/tools/extra
mv ./clang-tools-extra/* ./clang/tools/extra/

cd clang

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
  -DLLVM_ENABLE_LTO=Thin \
  -DCMAKE_AR=$AR \
  -DPython3_EXECUTABLE=${BUILD_PREFIX}/bin/python \
  $CMAKE_ARGS \
  ..

make -j${CPU_COUNT}
make install

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
for f in ${PREFIX}/bin/clang-*; do
  if [[ "$(basename $f)" == clang-offload-packager-* ]]; then
    # links to llvm-offload-binary
    continue
  elif [[ "$(basename $f)" == "clang-${MAJOR_VERSION}" ]]; then
    # installation also creates a versioned clang, no need to re-version it
    continue
  fi
  rm -f ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION}
  mv $f ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION};
  ln -s ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION} $f;
done

rm ${PREFIX}/bin/clang
rm ${PREFIX}/bin/clang-cpp
rm ${PREFIX}/bin/clang-cl
rm ${PREFIX}/bin/clang++

ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/c++
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/cc
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/cpp
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/clang
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/clang++
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/clang-cl
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/clang-cpp
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/clang++-${MAJOR_VERSION}
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/clang-cl-${MAJOR_VERSION}
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/clang-cpp-${MAJOR_VERSION}
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/${TARGET}-clang
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/${TARGET}-clang++
ln -sf ${PREFIX}/bin/clang-${MAJOR_VERSION} ${PREFIX}/bin/${TARGET}-clang-cpp
ln -sf ${PREFIX}/bin/clang-scan-deps-${MAJOR_VERSION} ${PREFIX}/bin/${TARGET}-clang-scan-deps


RESOURCE_DIR=${PREFIX}/lib/clang/${MAJOR_VERSION}
if [[ ! -d ${RESOURCE_DIR}/include ]]; then
  echo "${RESOURCE_DIR}/include not found"
  exit 1
fi
# Make sure omp.h from conda environment is found by clang
ln -sf $PREFIX/include/omp.h ${RESOURCE_DIR}/include/

# Create a link from versioned <PREFIX>/lib/libLTO.22.dylib (which
# is present in libllvm<major> that libclang<sover> depends on) to a
# versioned directory as the unversioned symlink <PREFIX>/lib/libLTO.dylib
# is only present in llvmdev, which may not be present when using clang.
# the patch 0010-Look-for-libLTO.dylib-in-the-versioned-ResourceDir.patch
# changes the diretory clang looks for it.
#
# We previously patched clang to use libLTO.22.dylib, and ld64 to
# accept a LTO library named libLTO.22.dylib, but sometimes clang uses the
# system linker when a different target tuple is given and the system
# linker rejects any library not named libLTO.dylib
#
# TODO: fix clang to use the correct linker regardless of the target
# tuple
#
# TODO: figure out what happens with LTO on Linux targetting Darwin
# It seems like this is not supported upstream.

if [[ "$target_platform" == "osx-"* ]]; then
  mkdir -p "${RESOURCE_DIR}/lib"
  IFS='.' read -r -a PKG_VER_ARRAY <<< "${PKG_VERSION}"
  # default SOVER for tagged releases is major.minor since LLVM 18
  SOVER_EXT="${PKG_VER_ARRAY[0]}.${PKG_VER_ARRAY[1]}"
  if [[ "${PKG_VERSION}" == *dev* ]]; then
      # otherwise with git suffix
      SOVER_EXT="${SOVER_EXT}git"
  fi
  ln -s "${PREFIX}/lib/libLTO.${SOVER_EXT}.dylib" "${RESOURCE_DIR}/lib/libLTO.dylib"
fi

if [[ "$target_platform" == "$build_platform" ]]; then
  RESOURCE_DIR_REF=$(${PREFIX}/bin/clang-${MAJOR_VERSION} -print-resource-dir)
  if [[ "${RESOURCE_DIR_REF}" != ${RESOURCE_DIR_REF} ]]; then
    echo "resource dir ${RESOURCE_DIR_REF} does not match expected ${RESOURCE_DIR}"
    exit 1
  fi
fi

# cfg files
for driver in clang clang++ clang-cpp; do
  echo '-isystem <CFGDIR>/../include'                    > ${PREFIX}/bin/${TARGET_NO_VER}-${driver}.cfg
done
# technically the flang cfg files should be in flang, but it's easier to consolidate them here.
for driver in clang clang++ flang; do
  echo '$-Wl,-L,<CFGDIR>/../lib'                        >> ${PREFIX}/bin/${TARGET_NO_VER}-${driver}.cfg
  echo '$-Wl,-rpath,<CFGDIR>/../lib'                    >> ${PREFIX}/bin/${TARGET_NO_VER}-${driver}.cfg
  if [[ "${target_platform}" == "linux-"* ]]; then
    echo '$-Wl,-rpath-link,<CFGDIR>/../lib'             >> ${PREFIX}/bin/${TARGET_NO_VER}-${driver}.cfg
  fi
done
if [[ "${target_platform}" == "linux-"* ]]; then
  for driver in clang clang++ flang clang-cpp; do
    echo "--sysroot=<CFGDIR>/../${TARGET}/sysroot"      >> ${PREFIX}/bin/${TARGET_NO_VER}-${driver}.cfg
  done
fi
