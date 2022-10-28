IF "%clang_variant:~0,4%"=="root" (
    cd root-source/interpreter/llvm/src/tools/clang
    set "SRC_DIR= %SRC_DIR%/root-source/interpreter/llvm/src/tools/clang"
)

move %LIBRARY_INC%\libxml2\libxml %LIBRARY_INC%
rmdir %LIBRARY_INC%\libxml2

mkdir build
cd build

:: Remove -GL from CXXFLAGS as this takes too much time and memory
set "CFLAGS= -MD"
set "CXXFLAGS= -MD"

cmake -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DCLANG_INCLUDE_TESTS=OFF ^
    -DCLANG_INCLUDE_DOCS=OFF ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_DOCS=OFF ^
    -DLLVM_TARGETS_TO_BUILD=X86 ^
    %SRC_DIR%

if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
