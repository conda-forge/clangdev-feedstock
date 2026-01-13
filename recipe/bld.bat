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

ninja install
if %ERRORLEVEL% neq 0 exit 1

for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
  copy "%LIBRARY_BIN%\\clang.exe" "%LIBRARY_BIN%\\clang-%%a.exe"
  copy "%LIBRARY_BIN%\\clang.exe" "%LIBRARY_BIN%\\clang++-%%a.exe"
)

setlocal enabledelayedexpansion
for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
  set "MAJOR_VERSION=%%a"
)
FOR /F "tokens=* USEBACKQ" %%F IN (`%LIBRARY_PREFIX%\bin\clang.exe -print-resource-dir`) DO (
  set "RESOURCE_DIR=%%F"
)
set "RESOURCE_DIR_REF=%LIBRARY_LIB:/=\%\clang\!MAJOR_VERSION!"
if NOT "!RESOURCE_DIR!" == "!RESOURCE_DIR_REF!" (
  echo "resource dir !RESOURCE_DIR_REF! does not match expected !RESOURCE_DIR!"
  exit 1
)
:: Make sure omp.h from conda environment is found by clang
copy %LIBRARY_PREFIX%\include\omp.h %RESOURCE_DIR_REF%\include\omp.h
