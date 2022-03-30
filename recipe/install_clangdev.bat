cd %SRC_DIR%\build
ninja install
if %ERRORLEVEL% neq 0 exit 1
