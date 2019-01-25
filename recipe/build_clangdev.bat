echo "clang_variant is %clang_variant%"
ls
if "%clang_variant%" NEQ "default" echo "If statement triggered"
if "%clang_variant%" NEQ "default" ls root-source/interpreter/llvm/src/tools/clang
if "%clang_variant%" NEQ "default" cd root-source/interpreter/llvm/src/tools/clang
ls

echo %cd%

if "%clang_variant%" EQU "default" goto :defaultsourcedir
cd root-source/interpreter/llvm/src/tools/clang
:defaultsourcedir

echo %cd%
mkdir build
cd build
echo %cd%

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
