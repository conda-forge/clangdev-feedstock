@echo on

cd %LIBRARY_BIN%
setlocal enabledelayedexpansion
for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
  copy clang-%%a.exe "clang++.exe"
)
