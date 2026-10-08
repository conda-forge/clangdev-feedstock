// Reproducer from https://github.com/conda-forge/compilers-feedstock/issues/85:
// with the macOS 27 SDK and -std=c++20, INFINITY and NAN were undeclared without
// patches/0011-clang-headers-Need-a-way-for-math.h-to-share-the-def.patch
#include <cmath>
int main() {}
float f() { return INFINITY + NAN; }
