source ${RECIPE_DIR}/install_clang_symlinks.sh

if [[ "${target_platform}" == "linux-64" ]]; then
  TARGET=x86_64-conda-linux-gnu
elif [[ "${target_platform}" == "linux-"* ]]; then
  TARGET=${target_platform/linux-/}-conda-linux-gnu
elif [[ "${target_platform}" == "osx-64" ]]; then
  # Don't use version numbers here to allow `-arch x86_64 -arch arm64` etc.
  TARGET=x86_64-apple-darwin
elif [[ "${target_platform}" == "osx-arm64" ]]; then
  # Don't use version numbers here to allow `-arch x86_64 -arch arm64` etc.
  TARGET=arm64-apple-darwin
else
  echo "Unknown platform ${target_platform}"
  exit 1
fi

mkdir -p ${PREFIX}/bin

if [[ "${with_cfg}" == "true" ]]; then
  echo '-isystem <CFGDIR>/../include'                    > ${PREFIX}/bin/${TARGET}.cfg
  echo '$-Wl,-L,<CFGDIR>/../lib'                        >> ${PREFIX}/bin/${TARGET}.cfg
  echo '$-Wl,-rpath,<CFGDIR>/../lib'                    >> ${PREFIX}/bin/${TARGET}.cfg
  if [[ "${target_platform}" == "linux-"* ]]; then
    echo '$-Wl,-rpath-link,<CFGDIR>/../lib'             >> ${PREFIX}/bin/${TARGET}.cfg
    echo "--sysroot=<CFGDIR>/../${TARGET}/sysroot"      >> ${PREFIX}/bin/${TARGET}.cfg
  fi
else
  if [[ "${target_platform}" == "linux-"* ]]; then
    echo "--sysroot=<CFGDIR>/../${TARGET}/sysroot"       > ${PREFIX}/bin/${TARGET}.cfg
  fi
fi
