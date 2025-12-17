@echo on

cd %LIBRARY_BIN%
setlocal enabledelayedexpansion
if "%PKG_NAME%" == "clang" (
  for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
    copy clang-%%a.exe clang.exe
    copy clang-%%a.exe clang-cl.exe
    copy clang-%%a.exe clang-cpp.exe
  )
)

if "%PKG_NAME%" == "clangxx" (
  for /f "tokens=1 delims=." %%a in ("%PKG_VERSION%") do (
    copy clang-%%a.exe clang++.exe
  )
)
