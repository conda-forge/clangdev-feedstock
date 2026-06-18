@echo on

cd %SRC_DIR%\clang\build
ninja install
if %ERRORLEVEL% neq 0 exit 1

if not exist %LIBRARY_BIN%\\libclang-13.dll exit 1

REM create a libclang.dll that forwards to libclang-13.dll
create-forwarder-dll %LIBRARY_BIN%\\libclang-13.dll %LIBRARY_BIN%\\libclang.dll --no-temp-dir
if %ERRORLEVEL% neq 0 exit 1
