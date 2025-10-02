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
  move bin2\clang.exe bin\clang-%%a.exe
)
rmdir /s /q bin2

cd %LIBRARY_BIN%
for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
  copy clang-%%a.exe "clang++-%%a.exe"
)

FOR /F "tokens=* USEBACKQ" %%F IN (`%LIBRARY_PREFIX%\bin\clang.exe -print-resource-dir`) DO (
   set "RESOURCE_DIR=%%F"
)
if not exist "!RESOURCE_DIR!\lib\windows\clang_rt.builtins-x86_64.lib" (
    echo "!RESOURCE_DIR!\lib\windows\clang_rt.builtins-x86_64.lib not found"
    exit 1
)
