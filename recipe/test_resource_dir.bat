@echo on
setlocal enabledelayedexpansion

mkdir build
cd build

for /f "tokens=1 delims=." %%i in ("%PKG_VERSION%") do (
  set "MAJOR_VER=%%i"
)

set "INSTALL_PREFIX=%LIBRARY_PREFIX%\lib\clang\%MAJOR_VER%"


FOR /F "tokens=* USEBACKQ" %%F IN (`clang -print-resource-dir`) DO (
    set "RESOURCE_DIR=%%F"
)
if "!RESOURCE_DIR!" NEQ "%INSTALL_PREFIX%" (
    echo "Wrong resource dir (!RESOURCE_DIR!). Should match %INSTALL_PREFIX%"
    exit 1
)
