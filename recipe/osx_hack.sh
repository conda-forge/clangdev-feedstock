# This is needed to avoid cycles in osx

if [[ "$target_platform" == "osx-64" ]]; then
    export CONDA_BUILD_SYSROOT_BACKUP=${CONDA_BUILD_SYSROOT}
    conda install -p $BUILD_PREFIX --quiet --yes clangxx_osx-64=${cxx_compiler_version}
    export CONDA_BUILD_SYSROOT=${CONDA_BUILD_SYSROOT_BACKUP}
    export PATH="$PREFIX/bin:$PATH"
fi
