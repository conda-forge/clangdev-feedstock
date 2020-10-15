#!/bin/bash

ln -s $PREFIX/bin/clang  $PREFIX/bin/clang++
ln -s $PREFIX/bin/clang  $PREFIX/bin/$HOST-clang++

if [[ "$variant" == "hcc" ]]; then
  ln -s $PREFIX/bin/clang++  $PREFIX/bin/hcc
fi
