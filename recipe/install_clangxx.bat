cd %LIBRARY_PREFIX%
setlocal enabledelayedexpansion
for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
  copy bin\clang-%%a.exe bin\clang++.exe
)
