#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install
cd $PREFIX

# Remove stuff that should be in clangdev
rm -rf include/clang
rm -rf include/clang-c
rm -rf include/clang-tidy
rm -rf lib/cmake/clang/
rm -rf lib/lib*.a

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
for f in ${PREFIX}/bin/clang-*; do
    if [[ "$(basename $f)" == clang-format-* ]]; then
        # already got versioned in install_clang_format.sh
        continue
    elif [[ "$(basename $f)" == "clang-${MAJOR_VERSION}" ]]; then
        # installation also creates a versioned clang, no need to re-version it
        continue
    fi
    rm -f ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION}
    mv $f ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION};
    ln -s ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION} $f;
done

# part of output "clang", not "clang-tools"
rm ${PREFIX}/bin/clang-${MAJOR_VERSION}
rm ${PREFIX}/bin/clang-cpp-${MAJOR_VERSION}
rm ${PREFIX}/bin/clang-cl-${MAJOR_VERSION}
