cd %SRC_DIR%\build
ninja install
cd %LIBRARY_PREFIX%
rmdir /s /q lib include bin\libclang.dll
