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
  # technically the clang++/flang cfg files should be in clang++ and flang packages
  # but it's easier to consolidate them here.
  for driver in clang clang++ clang-cpp; do
    echo '-isystem <CFGDIR>/../include'                    > ${PREFIX}/bin/${TARGET}-${driver}.cfg
  done
  for driver in clang clang++ flang; do
    echo '$-Wl,-L,<CFGDIR>/../lib'                        >> ${PREFIX}/bin/${TARGET}-${driver}.cfg
    echo '$-Wl,-rpath,<CFGDIR>/../lib'                    >> ${PREFIX}/bin/${TARGET}-${driver}.cfg
    if [[ "${target_platform}" == "linux-"* ]]; then
      echo '$-Wl,-rpath-link,<CFGDIR>/../lib'             >> ${PREFIX}/bin/${TARGET}-${driver}.cfg
    fi
  done
  if [[ "${target_platform}" == "linux-"* ]]; then
    for driver in clang clang++ flang clang-cpp; do
      echo "--sysroot=<CFGDIR>/../${TARGET}/sysroot"      >> ${PREFIX}/bin/${TARGET}-${driver}.cfg
    done
  fi
fi
