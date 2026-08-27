.section .text
.global _start
_start:
    mov x8, #64
    mov x0, #1
    ldr x1, =msg
    mov x2, msg_len 
    svc #0

    mov x8, #93
    mov x0, #0
    svc #0

.section .rodata
msg:
    .ascii "Hello World\n"
msg_len = . - msg
