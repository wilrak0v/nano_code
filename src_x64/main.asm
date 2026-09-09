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
    movzx register_in, byte [r12]
    verify_register register_in 
    ;mov register_in, r10
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
    write STDOUT, add_msg, add_len
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
    write STDOUT, sub_msg, sub_len
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

op_addi:
    load_register rax
    mov esi, dword [r13 + rax * 4]
    mov bx, word [r12]
    inc r12
    inc r12
    add esi, ebx
    mov dword [r13 + rax * 4], esi
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

op_or:
    load_register rsi
    load_register rdi
    inc r12
    mov eax, dword [r13 + rsi * 4]
    mov ebx, dword [r13 + rdi * 4]
    or eax, ebx
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_xor:
    load_register rsi
    load_register rdi
    inc r12
    mov eax, dword [r13 + rsi * 4]
    mov ebx, dword [r13 + rdi * 4]
    xor eax, ebx
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_shl:
    load_register rsi
    load_register rdi
    inc r12
    mov eax, dword [r13 + rsi * 4]
    mov cl, byte [r13 + rdi * 4]
    shl rax, cl 
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_shr:
    load_register rsi
    load_register rdi
    inc r12
    mov eax, dword [r13 + rsi * 4]
    mov cl, byte [r13 + rdi * 4]
    shr rax, cl 
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_shli:
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    mov cl, byte [r12]
    inc r12
    inc r12
    shl eax, cl
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_shri:
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    mov cl, byte [r12]
    inc r12
    inc r12
    shr eax, cl
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_cmp:
    load_register rsi
    load_register rdi
    ; Read
    mov edx, dword [r13 + rsi * 4]
    mov ebx, dword [r13 + rdi * 4]
    inc r12
    cmp edx, ebx 
    lahf
    mov al, ah
    mov r15b, al
    jmp fetch

op_jmp:
    load_register rsi
    ; Read
    mov eax, dword [r13 + rsi * 4]
    shl rax, 2
    ; Jump
    add rax, nano_code
    mov r12, rax 
    jmp fetch

op_je:
    test r15b, 0x40     ; Check the zero flag
    jz op_je.no_jump

    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    shl rax, 2
    ; Jump
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_je.no_jump:
    add r12, 3
    jmp fetch

op_jne:
    test r15b, 0x40     ; Check the zero flag
    jnz op_jne.no_jump

    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    shl rax, 2
    ; Jump
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jne.no_jump:
    add r12, 3
    jmp fetch

op_jlt:
    test r15b, 0x80
    jz op_jlt.no_jump

    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jlt.no_jump:
    add r12, 3
    jmp fetch

op_jgt:
    test r15b, 0xC0     ; 0x80 | 0x40 = 0xC0
    jnz op_jgt.no_jump
    
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jgt.no_jump:
    add r12, 3
    jmp fetch


op_jmpi:
    ; Fetch immediate 
    movzx rbx, word [r12]
    shl rbx, 2
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
    dq halt         ; 0x00
    dq movi         ; 0x01
    dq movr         ; 0x02
    dq op_add       ; 0x03
    dq op_sub       ; 0x04
    dq op_mul       ; 0x05
    dq op_div       ; 0x06
    dq op_mod       ; 0x07
    dq op_addi      ; 0x08
    dq op_and       ; 0x09
    dq op_or        ; 0x0A
    dq op_xor       ; 0x0B
    dq op_shl       ; 0x0C
    dq op_shr       ; 0x0D
    dq op_shli      ; 0x0E
    dq op_shri      ; 0x0F
    dq op_cmp
    dq op_jmp
    dq op_je
    dq op_jne
    dq op_jlt
    dq op_jgt
    dq op_jmpi

op_table_len = ($ - op_table) / 8 - 1 

movi_msg: db 'Mov Immediate value', 10
movi_len = $ - movi_msg

movr_msg: db 'Mov Register', 10
movr_len = $ - movr_msg

sub_msg: db 'Sub Registers', 10
sub_len = $ - sub_msg

add_msg: db 'Add Registers', 10
add_len = $ - add_msg

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
    db 0x01, 1, 2, 0x00 ; movi r01, 2
    db 0x08, 1, 10, 0x00; addi r01, 10
    db 0x00, 1, 0, 0x00 ; halt r2 
nano_code_len = $ - nano_code
