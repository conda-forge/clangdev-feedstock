@echo on

cd %SRC_DIR%\clang\build
ninja install
if %ERRORLEVEL% neq 0 exit 1

cd %LIBRARY_PREFIX%
rmdir /s /q lib\cmake libexec share include
del /q /f lib\*.lib

move bin bin2
mkdir bin

setlocal enabledelayedexpansion
for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
  set "MAJOR_VERSION=%%a"
)
move bin2\clang.exe bin\clang-!MAJOR_VERSION!.exe
rmdir /s /q bin2

cd %LIBRARY_BIN%
copy clang-!MAJOR_VERSION!.exe "clang++-!MAJOR_VERSION!.exe"

FOR /F "tokens=* USEBACKQ" %%F IN (`%LIBRARY_PREFIX%\bin\clang.exe -print-resource-dir`) DO (
   set "RESOURCE_DIR=%%F"
)
set "RESOURCE_DIR_REF=%LIBRARY_LIB:/=\%\clang\!MAJOR_VERSION!"
if NOT "!RESOURCE_DIR!" == "!RESOURCE_DIR_REF!" (
    echo "resource dir !RESOURCE_DIR_REF! does not match expected !RESOURCE_DIR!"
    exit 1
)

:: Make sure omp.h from conda environment is found by clang
copy %LIBRARY_PREFIX%/include/omp.h %RESOURCE_DIR_REF%/include/
