cd %SRC_DIR%\build
ninja install
cd %LIBRARY_PREFIX%
rmdir /s /q lib\cmake libexec share include

del /q /f lib\*.lib

move bin bin2

mkdir bin

move bin2\clang.exe bin\
move bin2\clang-cl.exe bin\
move bin2\clang-cpp.exe bin\
rmdir /s /q bin2
