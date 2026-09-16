#include "nanocode.asm"

start:
    ; Write FD=1, buffer=msg, length=12
    mov r1, 1
    mov r2, msg
    mov r3, 12
    sys 1

    ; halt
    halt r0

msg:
#d "Hello World"
#d8 10
