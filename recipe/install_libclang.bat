cd %SRC_DIR%\build
ninja install
cd %LIBRARY_PREFIX%
rmdir /s /q lib libexec share include

move bin bin2

mkdir bin

move bin2\libclang.dll bin\
rmdir /s /q bin2
