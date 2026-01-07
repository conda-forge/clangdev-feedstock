@echo on

cd %SRC_DIR%\clang\build
ninja install
if %ERRORLEVEL% neq 0 exit 1

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

cd %LIBRARY_PREFIX%
rmdir /s /q lib\cmake libexec share include
del /q /f lib\*.lib

move bin bin2
mkdir bin

move bin2\clang.exe bin\clang-!MAJOR_VERSION!.exe
rmdir /s /q bin2

cd %LIBRARY_BIN%
copy clang-!MAJOR_VERSION!.exe "clang++-!MAJOR_VERSION!.exe"

:: conda's use of `files:` disables usual before/after snapshotting mechanism
:: of host environment, see https://github.com/conda/conda-build/issues/5455;
:: since we're including `Library/lib/clang` on windows and llvm-openmp is in
:: host, we need to delete files in that path which llvm-openmp brings along;
:: only from 18-20 because those are the only versions where this is relevant
rmdir /s /q %LIBRARY_LIB%\clang\18
rmdir /s /q %LIBRARY_LIB%\clang\19
rmdir /s /q %LIBRARY_LIB%\clang\20
