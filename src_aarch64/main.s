.section .bss
.align 4
buffer_size = 4096
buffer:
    .skip buffer_size 

.section .text
.global _start
_start:
    mov x19, #1
    // Get filename 
    ldr x0, [sp]    // argc
    cmp x0, #2
    b.eq _start.argc_noerror 
    ldr x0, =argc_error
    bl puts
    b exit
_start.argc_noerror:

    ldr x1, [sp, #16] // argv[1]

    // Try to open it
    mov x0, #-100
    mov x2, #0
    mov x3, #0
    mov x8, #56
    svc #0
    mov x19, x0

    cmp x19, #0
    b.ge _start.file_found 
    adr x0, file_not_found
    bl puts
    b exit
_start.file_found:

    // Try to read it
    mov x0, x19
    adr x1, buffer
    mov x2, buffer_size
    mov x8, #63
    svc #0

exit:
    // Close the file
    mov x0, x19
    mov x8, #57
    svc #0

    mov x8, #93
    mov x0, #0
    svc #0

puts:
    // puts *buf
    mov x3, x0
    stp x29, x30, [sp, -16]!
puts.loop:
    ldrb w0, [x3]
    cbz w0, puts.bottom

    mov x0, #0
    mov x1, x3
    bl putc

    add x3, x3, #1
    b puts.loop
puts.bottom:
    ldp x29, x30, [sp], 16
    ret

putc:
    // putc stdout *char
    mov x8, #64
    mov x2, #1
    svc #0
    ret


.section .rodata
argc_error:
    .asciz "ERROR: filename is missing\n"
file_not_found:
    .asciz "ERROR: file not found\n"
