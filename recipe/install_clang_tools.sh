#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install
cd $PREFIX

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")

# Remove stuff that should be in clangdev
rm -rf include/clang
rm -rf include/clang-c
rm -rf include/clang-tidy
rm -rf lib/cmake/clang/
rm -rf lib/lib*.a
# part of output "clang", not "clang-tools"
rm ${PREFIX}/bin/clang
rm ${PREFIX}/bin/clang-${MAJOR_VERSION}
rm ${PREFIX}/bin/clang-cpp
rm ${PREFIX}/bin/clang-cl
# part of output "clang-format", not "clang-tools"
rm ${PREFIX}/bin/clang-format-*
# part of output "clang-scan-deps", not "clang-tools"
rm ${PREFIX}/bin/clang-scan-deps-*
# already a symlink to $PREFIX/bin/llvm-offload-binary
rm ${PREFIX}/bin/clang-offload-packager-*

for f in ${PREFIX}/bin/clang-*; do
    if [[ "$(basename $f)" == "*-${MAJOR_VERSION}" ]]; then
        # installation already creates multiple versioned binaries, no need to re-version them
        continue
    fi
    # add version to actual binary and make $PREFIX/bin/clang-foo a symlink to it
    rm -f ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION}
    mv $f ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION};
    ln -s ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION} $f;
done
