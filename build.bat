@IF NOT EXIST bin mkdir bin
nasm -f win64 -o bin\inout.obj inout.asm
nasm -f win64 -o bin\sub.obj sub.asm
nasm -f win64 -o bin\add.obj add.asm
GoLink /console /ni /entry main bin\sub.obj bin\inout.obj msvcrt.dll
GoLink /console /ni /entry main bin\add.obj bin\inout.obj msvcrt.dll
