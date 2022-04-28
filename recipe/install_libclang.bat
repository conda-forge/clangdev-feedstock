@echo on

cd %SRC_DIR%\clang\build
ninja install
if %ERRORLEVEL% neq 0 exit 1

cd %LIBRARY_PREFIX%
rmdir /s /q lib libexec share include

move bin bin2
mkdir bin

setlocal enabledelayedexpansion
if "%PKG_NAME%"=="libclang" (
    REM unversioned
    move bin2\libclang.dll bin\
) else (
    REM versioned
    for /f "tokens=1 delims=." %%a in ("%libclang_soversion%") do (
        move bin2\libclang.dll bin\libclang-%%a.dll
    )
)
rmdir /s /q bin2
