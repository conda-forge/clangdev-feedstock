mkdir build
cd build

:: Remove -GL from CXXFLAGS as this takes too much time and memory
set "CFLAGS= -MD"
set "CXXFLAGS= -MD"

set "CXX=cl.exe"
set "CC=cl.exe"

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DCLANG_INCLUDE_TESTS=OFF ^
    -DCLANG_INCLUDE_DOCS=OFF ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_DOCS=OFF ^
    -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON ^
    -DLLVM_ENABLE_LIBXML2=OFF ^
    %SRC_DIR%

if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1

