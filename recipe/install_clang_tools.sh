#!/bin/bash
set -ex

cd ${SRC_DIR}/clang/build
make install
cd $PREFIX
rm -rf lib/cmake include lib/lib*.a

MAJOR_VERSION=$(echo ${PKG_VERSION} | cut -f1 -d".")
for f in ${PREFIX}/bin/clang-*; do
    if [[ "$(basename $f)" == clang-format-* ]]; then
        continue
    fi
    rm -f ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION}
    mv $f ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION};
    ln -s ${PREFIX}/bin/$(basename $f)-${MAJOR_VERSION} $f;
done

rm ${PREFIX}/bin/clang-${MAJOR_VERSION}-${MAJOR_VERSION}
rm ${PREFIX}/bin/clang-cpp-${MAJOR_VERSION}
rm ${PREFIX}/bin/clang-cl-${MAJOR_VERSION}
