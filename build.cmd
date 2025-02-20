@echo off

nasm -f win64 main.asm
ld main.obj -o main.exe -e main -lkernel32 -lmsvcrt