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
    syscall3 SYS_write, fd, msg, msg_len
}

segment readable executable
entry start

start:
    write STDOUT, msg, msg_len
    exit 0

movi:
    exit 1

movr:
    exit 2

segment readable
op_table:
    dq movi
    dq movr
msg:
    db 'Hello world', 10
msg_len = $ - msg
nano_code:
    dd 0x00011000
    dd 0x01020100
nano_code_len = $ - nano_code
