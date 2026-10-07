// Test for patches/0011-clang-headers-Need-a-way-for-math.h-to-share-the-def.patch
// (backport of llvm/llvm-project#164348): the macOS 27 SDK's math.h does
// `#define __need_infinity_nan` + `#include <float.h>` to get only INFINITY and
// NAN; a later full `#include <float.h>` must still define everything else.

#define __need_infinity_nan
#include <float.h>

#ifndef INFINITY
#error "__need_infinity_nan did not provide INFINITY"
#endif
#ifndef NAN
#error "__need_infinity_nan did not provide NAN"
#endif
#ifdef FLT_MAX
#error "__need_infinity_nan leaked FLT_MAX"
#endif
#ifdef __need_infinity_nan
#error "__need_infinity_nan was not undefined by float.h"
#endif

#include <float.h>

#ifndef FLT_MAX
#error "full float.h after partial include did not provide FLT_MAX"
#endif
#ifndef DBL_EPSILON
#error "full float.h after partial include did not provide DBL_EPSILON"
#endif

float infinity0 = INFINITY;
float nan0 = NAN;
double eps0 = DBL_EPSILON;
