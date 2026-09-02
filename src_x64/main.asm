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

macro verify_register register_number {
    cmp register_number, number_registers
    ja unknown_register
}

macro load_register register_in {
    movzx r10, byte [r12]
    verify_register r10
    mov register_in, r10
    inc r12
}

segment readable writable
registers rb 32 * 4 ; Each register is 32 bytes
ram rb 65536        ; 64ko for the RAM
number_registers = 32 

segment readable executable
entry start

start:
    mov r12, nano_code ; Instruction pointer
    mov r13, registers ; Registers pointer

fetch:
    movzx rbx, byte [r12]
    inc r12
    cmp rbx, op_table_len
    ja unknown_instruction
    ; dispatch
    jmp qword [op_table + rbx*8]

movi:
    write STDOUT, movi_msg, movi_len
    ; rax = register number
    load_register rax
    ; rdi = Immediate value
    movzx rdi, word [r12]
    inc r12
    ; Offset to be aligned with 32 bits
    inc r12
    ; Write
    mov dword [r13 + rax * 4], edi
    ; exit rdi 
    jmp fetch

movr:
    write STDOUT, movr_msg, movr_len
    ; rax = register in
    load_register rax
    ; rdi = register out
    load_register rdi
    ; Offset to be aligned with 32 bits
    inc r12
    ; Read and write
    mov edx, dword [r13 + rdi * 4]
    mov dword [r13 + rax * 4], edx
    ; exit rdi 
    jmp fetch 

op_add:
    ; rax = register in
    load_register rax
    ; rdi = register out 
    load_register rdi
    ; Offset to aligned with 32 bits
    inc r12
    ; Read
    mov esi, dword [r13 + rax * 4]
    mov edx, dword [r13 + rdi * 4]
    ; Add and store
    add esi, edx
    mov dword [r13 + rax * 4], esi
    jmp fetch

op_sub:
    ; rax = register in
    load_register rax
    ; rdi = register out
    load_register rdi
    ; Offset
    inc r12
    ; Read
    mov esi, dword [r13 + rax * 4]
    mov edx, dword [r13 + rdi * 4]
    ; Sub and store
    sub esi, edx
    mov dword [r13 + rax * 4], esi
    jmp fetch

op_mul:
    ; rax = register in
    load_register rsi 
    ; rdi = register out
    load_register rdi
    ; Offset
    inc r12
    ; Read, mul and store 
    mov eax, dword [r13 + rsi * 4]
    mov ebx, dword [r13 + rdi * 4]
    ; Mul and Store
    xor edx, edx
    mul ebx
    mov dword [r13 + rsi * 4], eax 
    jmp fetch

op_div:
    write STDOUT, div_msg, div_msg_len
    ; rax = register in
    load_register rsi 
    ; rdi = register out
    load_register rdi
    ; Offset
    inc r12
    ; Read, di9v and store
    mov eax, dword [r13 + rsi * 4]
    mov ebx, dword [r13 + rdi * 4]
    ; div
    xor rdx, rdx
    div ebx
    mov dword [r13 + rsi * 4], eax 
    jmp fetch

op_mod:
    load_register rsi
    load_register rdi
    inc r12

    mov eax, dword [r13 + rsi * 4]
    mov ebx, dword [r13 + rdi * 4]
    xor rdx, rdx
    div ebx
    mov dword [r13 + rsi * 4], edx
    jmp fetch

op_and:
    load_register rsi
    load_register rdi
    inc r12
    mov eax, dword [r13 + rsi * 4]
    mov ebx, dword [r13 + rdi * 4]
    and eax, ebx
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_jmpi:
    ; Fetch immediate 
    movzx rbx, byte [r12]
    shl rbx, 2
    ; Verify if it's aligned (4 bytes)
    mov rax, rbx
    test al, 3
    jnz address_not_aligned 
    ; change r12
    add rbx, nano_code
    mov r12, rbx
    jmp fetch

unknown_instruction:
    write STDOUT, unknown_msg, unknown_msg_len
    exit 69

unknown_register:
    write STDOUT, unknown_register_msg, unknown_register_msg_len
    exit 69

address_not_aligned:
    write STDOUT, address_not_aligned_msg, address_not_aligned_len 
    exit 69

halt:
    write STDOUT, halt_msg, halt_msg_len
    movzx rax, byte [r12]
    cmp rax, number_registers
    ja unknown_register
    mov edi, dword [r13 + rax * 4]
    exit rdi 

segment readable

op_table:
    dq halt
    dq movi
    dq movr
    dq op_add
    dq op_sub
    dq op_mul
    dq op_div
    dq op_mod
    dq op_and
    dq op_jmpi

op_table_len = ($ - op_table) / 8 - 1 

movi_msg: db 'Mov Immediate value', 10
movi_len = $ - movi_msg

movr_msg: db 'Mov Register', 10
movr_len = $ - movr_msg

div_msg: db 'Div', 10
div_msg_len = $ - div_msg

unknown_msg: db 'ERROR: Unknown instruction', 10
unknown_msg_len = $ - unknown_msg

unknown_register_msg: db 'ERROR: Unknown register', 10
unknown_register_msg_len = $ - unknown_register_msg

address_not_aligned_msg: db 'ERROR: address not aligned (4 bytes)', 10
address_not_aligned_len = $ - address_not_aligned_msg

halt_msg: db 'Halt', 10
halt_msg_len = $ - halt_msg 

; NANO_CODE (that's just a str to jump to it easily in VIM)
nano_code:
    dd 0x00450101 ; movi r01, 10 
    dd 0x00430201 ; movi r02
    dd 0x00020108 ; and 
    dd 0x00000100 ; halt
nano_code_len = $ - nano_code
