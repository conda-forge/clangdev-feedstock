@echo on
setlocal enabledelayedexpansion

:: move clang-tools-extra to clang/tools/extra, see
:: https://github.com/llvm/llvm-project/blob/main/clang-tools-extra/README.txt
mkdir clang\tools\extra
robocopy clang-tools-extra clang\tools\extra /E >nul
:: do not check %ERRORLEVEL%! robocopy returns an exit code
:: of 1 if one or more files were successfully copied.

cd clang

mkdir build
cd build

:: Remove -GL from CXXFLAGS as this takes too much time and memory
set "CFLAGS= -MD"
set "CXXFLAGS= -MD"

set "CXX=cl.exe"
set "CC=cl.exe"

if NOT "%target_platform%"=="%build_platform%" (
    echo "LIB: %LIB%"
    echo "LIB_FOR_BUILD: %LIB_FOR_BUILD%"
    echo set^(CMAKE_C_COMPILER "%CC_FOR_BUILD:\=/%"^)           >> native-toolchain.cmake
    echo set^(CMAKE_CXX_COMPILER "%CXX_FOR_BUILD:\=/%"^)        >> native-toolchain.cmake
    echo set^(CMAKE_C_FLAGS ""^)                                >> native-toolchain.cmake
    echo set^(CMAKE_CXX_FLAGS ""^)                              >> native-toolchain.cmake
    echo set^(CMAKE_LIBRARY_PATH "%LIB_FOR_BUILD:\=/%"^)        >> native-toolchain.cmake
    echo set^(CMAKE_INCLUDE_PATH "%INCLUDE_FOR_BUILD:\=/%"^)    >> native-toolchain.cmake
    echo set^(CMAKE_RC_COMPILER "%BUILD_PREFIX:\=/%/Library/bin/llvm-rc.exe"^) >> native-toolchain.cmake
    echo set^(CMAKE_MT "%BUILD_PREFIX:\=/%/Library/bin/llvm-mt.exe"^) >> native-toolchain.cmake
    echo set^(LLVM_DIR "%BUILD_PREFIX:\=/%/Library/lib/cmake/llvm"^) >> native-toolchain.cmake
    echo set^(ENV{INCLUDE} "%INCLUDE_FOR_BUILD:\=/%"^)          >> native-toolchain.cmake
    echo set^(ENV{LIB} "%LIB_FOR_BUILD:\=/%"^)                  >> native-toolchain.cmake
    REM Build /LIBPATH: flags from LIB_FOR_BUILD so they are baked into
    REM the ninja build files and used at build time, not just configure time.
    set "LIBPATH_FLAGS=/MACHINE:X64"
    for %%p in ("!LIB_FOR_BUILD:;=" "!") do (
        if not "%%~p"=="" (
            set "_fwd=%%~p"
            set "_fwd=!_fwd:\=/!"
            set "LIBPATH_FLAGS=!LIBPATH_FLAGS! /LIBPATH:\"!_fwd!\""
        )
    )
    echo set^(CMAKE_EXE_LINKER_FLAGS "!LIBPATH_FLAGS!"^)        >> native-toolchain.cmake
    echo set^(CMAKE_MODULE_LINKER_FLAGS "!LIBPATH_FLAGS!"^)     >> native-toolchain.cmake
    echo set^(CMAKE_SHARED_LINKER_FLAGS "!LIBPATH_FLAGS!"^)     >> native-toolchain.cmake
    echo set^(CMAKE_STATIC_LINKER_FLAGS ""^)                    >> native-toolchain.cmake
    type native-toolchain.cmake
    set "CMAKE_ARGS=%CMAKE_ARGS% -DCROSS_TOOLCHAIN_FLAGS_NATIVE=-DCMAKE_TOOLCHAIN_FILE=%cd%\\native-toolchain.cmake"
    set "CMAKE_ARGS=!CMAKE_ARGS! -DLLVM_TABLEGEN_EXE=%BUILD_PREFIX%/Library/bin/llvm-tblgen.exe"
)

cmake -G "Ninja" !CMAKE_ARGS! ^
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
  set "MAJOR_VERSION=%%a"
)

:: create versioned copies of clang/clang++
copy "%LIBRARY_BIN%\clang.exe" "%LIBRARY_BIN%\clang-!MAJOR_VERSION!.exe"
copy "%LIBRARY_BIN%\clang.exe" "%LIBRARY_BIN%\clang++-!MAJOR_VERSION!.exe"

if not exist %LIBRARY_BIN%\\libclang-13.dll exit 1

REM create a libclang.dll that forwards to libclang-13.dll
create-forwarder-dll %LIBRARY_BIN%\\libclang-13.dll %LIBRARY_BIN%\\libclang.dll --no-temp-dir
if %ERRORLEVEL% neq 0 exit 1

set "RESOURCE_DIR_REF=%LIBRARY_LIB:/=\%\clang\!MAJOR_VERSION!"
if "%build_platform%" == "%target_platform%" (
  FOR /F "tokens=* USEBACKQ" %%F IN (`%LIBRARY_PREFIX%\bin\clang.exe -print-resource-dir`) DO (
    set "RESOURCE_DIR=%%F"
  )
  if NOT "!RESOURCE_DIR!" == "!RESOURCE_DIR_REF!" (
    echo "resource dir !RESOURCE_DIR_REF! does not match expected !RESOURCE_DIR!"
    exit 1
  )
)
:: Make sure omp.h from conda environment is found by clang
copy %LIBRARY_PREFIX%\include\omp.h %RESOURCE_DIR_REF%\include\omp.h
