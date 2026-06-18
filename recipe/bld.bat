@echo on
setlocal enabledelayedexpansion

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
set "MT=%BUILD_PREFIX%\Library\bin\llvm-mt.exe"
set "RC=%BUILD_PREFIX%\Library\bin\llvm-rc.exe"

if NOT "%target_platform%"=="%build_platform%" (
    echo "LIB: %LIB%"
    echo "LIB_FOR_BUILD: %LIB_FOR_BUILD%"
    echo set^(CMAKE_C_COMPILER "%CC_FOR_BUILD:\=/%"^)           >> native-toolchain.cmake
    echo set^(CMAKE_CXX_COMPILER "%CXX_FOR_BUILD:\=/%"^)        >> native-toolchain.cmake
    echo set^(CMAKE_C_FLAGS ""^)                                >> native-toolchain.cmake
    echo set^(CMAKE_CXX_FLAGS ""^)                              >> native-toolchain.cmake
    echo set^(CMAKE_MT "%MT:\=/%"^)                             >> native-toolchain.cmake
    echo set^(CMAKE_LIBRARY_PATH "%LIB_FOR_BUILD:\=/%"^)        >> native-toolchain.cmake
    echo set^(CMAKE_INCLUDE_PATH "%INCLUDE_FOR_BUILD:\=/%"^)    >> native-toolchain.cmake
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
