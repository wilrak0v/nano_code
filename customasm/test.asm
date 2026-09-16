#include "nanocode.asm"

start:
    movl r0, 10000 
    movi r1, 0
    movi r2, 1

loop:
    cmpi r0, 1
    jei [done]

    movr r3, r1
    add r3, r2

    movr r1, r2
    movr r2, r3

    subi r0, 1
    jmpi [loop]

done:
    halt r2
