format ELF64 executable 3

SYS_write = 1
STDOUT = 1

macro syscall1 number, arg {
    mov rax, number
    mov rdi, arg
    syscall
}

macro syscall3 number, arg0, arg1, arg2 {
    mov rax, number
    mov rdi, arg0
    mov rsi, arg1
    mov rdx, arg2
    syscall
}

macro exit exit_code {
    syscall1 60, exit_code
}

macro write fd, buf, length {
    syscall3 SYS_write, fd, buf, length 
}

segment readable executable
entry start

op_table:
    dq halt
    dq movi
    dq movr

start:
    mov r12, nano_code ; Instruction pointer

fetch:
    movzx rbx, byte [r12]
    inc r12
    cmp rbx, 2
    ja unknown_instruction
    ; dispatch
    jmp qword [op_table + rbx*8]

movi:
    write STDOUT, movi_msg, movi_len
    ; rax = register number
    mov rax, [r12]
    inc r12
    ; rdi = Immediate value
    mov rdi, [r12]
    inc r12
    ; Offset to be aligned with 32 bits
    inc r12
    ; exit rdi 
    jmp fetch

movr:
    write STDOUT, movr_msg, movr_len
    ; rax = register in
    mov rax, [r12]
    inc r12
    ; rdi = register out
    mov rdi, [r12]
    inc r12
    ; Offset to be aligned with 32 bits
    inc r12
    ; exit rdi 
    jmp fetch 

unknown_instruction:
    write STDOUT, unknown_msg, unknown_msg_len
    exit 69

halt:
    write STDOUT, halt_msg, halt_msg_len
    exit [r12]

segment readable
movi_msg: db 'Mov Immediate value', 10
movi_len = $ - movi_msg

movr_msg: db 'Mov Register', 10
movr_len = $ - movr_msg

unknown_msg: db 'ERROR: Unknown instruction', 10
unknown_msg_len = $ - unknown_msg

halt_msg: db 'Halt', 10
halt_msg_len = $ - halt_msg 

nano_code:
    dd 0x00100101 ; movi r01, 16
    dd 0x00010202 ; movr r02, r01
    dd 0x00001000 ; halt
nano_code_len = $ - nano_code
