@echo on

cd %SRC_DIR%\clang\build
ninja install
if %ERRORLEVEL% neq 0 exit 1

cd %LIBRARY_PREFIX%
rmdir /s /q lib libexec share include

move bin bin2
mkdir bin

move bin2\clang-format.exe bin\clang-format.exe
rmdir /s /q bin2
