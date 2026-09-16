#include "nanocode.asm"

start:
    mov r0, 10000 
    mov r1, 0
    mov r2, 1

loop:
    cmp r0, 1
    je done

    mov r3, r1
    add r3, r2

    mov r1, r2
    mov r2, r3

    sub r0, 1
    jmp loop

done:
    halt r2
