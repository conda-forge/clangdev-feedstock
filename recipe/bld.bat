@echo on

:: move clang-tools-extra to clang/tools/extra, see
:: https://github.com/llvm/llvm-project/blob/main/clang-tools-extra/README.txt
mkdir llvm-project\clang\tools\extra
robocopy llvm-project\clang-tools-extra llvm-project\clang\tools\extra /E >nul
:: do not check %ERRORLEVEL%! robocopy returns an exit code
:: of 1 if one or more files were successfully copied.

:: using subproject sources has been effectively broken in LLVM 14,
:: so we use the entire project, but make sure we don't pick up
:: anything in-tree other than clang & the shared cmake folder
robocopy llvm-project\clang .\clang /E >nul
robocopy llvm-project\cmake .\cmake /E >nul
del /f /q llvm-project
cd clang

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
    -DCLANG_FORCE_MATCHING_LIBCLANG_SOVERSION=OFF ^
    -DCLANG_INCLUDE_TESTS=OFF ^
    -DCLANG_INCLUDE_DOCS=OFF ^
    -DLLVM_INCLUDE_TESTS=OFF ^
    -DLLVM_INCLUDE_DOCS=OFF ^
    -DLLVM_ENABLE_LIBXML2=FORCE_ON ^
    -DLLVM_ENABLE_ZLIB=FORCE_ON ^
    -DLLVM_ENABLE_ZSTD=FORCE_ON ^
    -DPython3_EXECUTABLE=%BUILD_PREFIX%\python ^
    ..
if %ERRORLEVEL% neq 0 exit 1

ninja -j%CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1
