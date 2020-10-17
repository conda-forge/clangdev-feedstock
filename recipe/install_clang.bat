cd %SRC_DIR%\build
ninja install
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
