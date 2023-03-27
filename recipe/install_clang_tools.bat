@echo on

cd %SRC_DIR%\clang\build
ninja install
if %ERRORLEVEL% neq 0 exit 1

cd %LIBRARY_PREFIX%
rmdir /s /q include\clang include\clang-c include\clang-tidy lib
