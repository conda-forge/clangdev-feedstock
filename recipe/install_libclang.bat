@echo on

cd %SRC_DIR%\clang\build
ninja install
if %ERRORLEVEL% neq 0 exit 1

cd %LIBRARY_PREFIX%
rmdir /s /q libexec share include

move bin bin2
mkdir bin
move lib lib2
mkdir lib

setlocal enabledelayedexpansion
if "%PKG_NAME%"=="libclang" (
    REM for unversioned output, keep only import lib; no DLLs
    move lib2\libclang.lib lib\libclang.lib
    if %ERRORLEVEL% neq 0 exit 1
) else (
    REM for versioned output, keep only versioned DLL; no import lib
    move bin2\libclang-%libclang_soversion%.dll bin\libclang-%libclang_soversion%.dll
    if %ERRORLEVEL% neq 0 exit 1
)
rmdir /s /q bin2
rmdir /s /q lib2
