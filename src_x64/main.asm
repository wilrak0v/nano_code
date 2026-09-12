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

movl:
    load_register rax
    inc r12
    inc r12
    mov edi, dword [r12]
    add r12, 4
    mov dword [r13 + rax * 4], edi
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

op_store8:
    ; store8 [r], r
    load_register rsi
    load_register rdi
    xor rdx, rdx
    mov edx, dword [r13 + rsi * 4]
    mov al, byte [r13 + rdi * 4]
    inc r12
    mov byte [ram + rdx], al 
    jmp fetch

op_load8:
    ; load8 r, [r]
    load_register rsi
    load_register rdi
    inc r12
    xor rdx, rdx
    mov edx, dword [r13 + rdi * 4]
    mov al, byte [ram + rdx]
    mov byte [r13 + rsi * 4], al
    jmp fetch

op_store16:
    load_register rsi
    load_register rdi
    inc r12
    xor rdx, rdx
    mov edx, dword [r13 + rsi * 4]
    mov ax, word [r13 + rdi * 4]
    mov word [ram + rdx], ax
    jmp fetch

op_load16:
    load_register rsi
    load_register rdi
    inc r12
    xor rdx, rdx
    mov edx, dword [r13 + rdi * 4]
    mov ax, word [ram + rdx]
    mov word [r13 + rsi * 4], ax
    jmp fetch

op_store32:
    ; store [r], r
    load_register rsi
    load_register rdi
    inc r12
    xor rdx, rdx
    mov edx, dword [r13 + rsi * 4]
    mov eax, dword [r13 + rdi * 4]
    mov dword [ram + edx], eax
    jmp fetch

op_load32:
    ; load r, [r]
    load_register rsi
    load_register rdi
    inc r12
    xor rdx, rdx
    mov edx, dword [r13 + rdi * 4]
    mov eax, dword [ram + rdx]
    mov dword [r13 + rsi * 4], eax
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

op_subi:
    load_register rax
    mov esi, dword [r13 + rax * 4]
    mov bx, word [r12]
    inc r12
    inc r12
    sub esi, ebx
    mov dword [r13 + rax * 4], esi
    jmp fetch

op_muli:
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    mov bx, word [r12]
    inc r12
    inc r12
    mul ebx
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_divi:
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    mov bx, word [r12]
    inc r12
    inc r12
    xor rdx, rdx
    div ebx
    mov dword [r13 + rsi * 4], eax
    jmp fetch

op_modi:
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    mov bx, word [r12]
    inc r12
    inc r12
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

op_jz:
    ; JZ Ra, [Rb] => if Ra == 0 jump to Rb
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    cmp rax, 0
    jnz op_jz.no_jump

    load_register rdi
    mov eax, dword [r13 + rdi * 4]
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jz.no_jump:
    add r12, 2
    jmp fetch

op_jnz:
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    cmp rax, 0
    jz op_jnz.no_jump

    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jnz.no_jump:
    add r12, 2
    jmp fetch

op_call:
    ; call [R] => mov r29, address ; jump [R]
    load_register rsi
    mov ebx, dword [r13 + rsi * 4]

    add r12, 3
    sub r12, nano_code
    shr r12, 2
    mov dword [r13 + 29 * 4], r12d 

    mov eax, ebx
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch

op_ret:
    xor rax, rax
    mov eax, dword [r13 + 29 * 4]
    mov r12, rax
    shl r12, 2
    add r12, nano_code
    jmp fetch

op_cmpi:
    load_register rsi
    movzx ebx, word [r12]
    inc r12
    inc r12
    ; Read
    mov edx, dword [r13 + rsi * 4]
    cmp edx, ebx 
    lahf
    mov al, ah
    mov r15b, al
    jmp fetch

op_jei:
    test r15b, 0x40     ; Check the zero flag
    jz op_jei.no_jump

    movzx rax, word [r12]
    shl rax, 2
    ; Jump
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jei.no_jump:
    add r12, 3
    jmp fetch

op_jli:
    test r15b, 0x80
    jz op_jlt.no_jump

    movzx rax, word [r12]
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jli.no_jump:
    add r12, 3
    jmp fetch

op_jgi:
    test r15b, 0xC0     ; 0x80 | 0x40 = 0xC0
    jnz op_jgt.no_jump
    
    movzx rax, word [r12]
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jgi.no_jump:
    add r12, 3
    jmp fetch

op_jzi:
    ; JZ Ra, [Rb] => if Ra == 0 jump to Rb
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    cmp rax, 0
    jnz op_jz.no_jump

    movzx rax, word [r12]
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jzi.no_jump:
    add r12, 2
    jmp fetch

op_jnzi:
    load_register rsi
    mov eax, dword [r13 + rsi * 4]
    cmp rax, 0
    jz op_jnzi.no_jump

    movzx rax, word [r12]
    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch
op_jnzi.no_jump:
    add r12, 2
    jmp fetch

op_jmpi:
    ; Fetch immediate 
    movzx rbx, word [r12]
    shl rbx, 2
    ; change r12
    add rbx, nano_code
    mov r12, rbx
    jmp fetch

op_calli:
    ; call 16
    movzx rax, word [r12]
    add r12, 3
    sub r12, nano_code 
    shr r12, 2
    mov [r13 + 29 * 4], r12b

    shl rax, 2
    add rax, nano_code
    mov r12, rax
    jmp fetch

op_sys:
    ; sys 17
    movzx rbx, word [r12]
    add r12, 3
    jmp qword [sys_table + rbx * 4]

sys_print:
    mov rax, 1
    mov edi, dword [r13 + 1 * 4]
    mov esi, dword [r13 + 2 * 4]
    mov edx, dword [r13 + 3 * 4]
    add rsi, nano_code
    syscall
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

sys_table:
    dq sys_print

op_table:
    dq halt
    dq movi 
    dq movl
    dq movr  
    dq op_store8
    dq op_load8
    dq op_store16
    dq op_load16
    dq op_store32
    dq op_load32
    dq op_add 
    dq op_sub
    dq op_mul
    dq op_div
    dq op_mod
    dq op_addi
    dq op_subi
    dq op_muli
    dq op_divi
    dq op_modi
    dq op_and
    dq op_or
    dq op_xor
    dq op_shl
    dq op_shr
    dq op_shli
    dq op_shri
    dq op_cmp
    dq op_jmp
    dq op_je
    dq op_jne
    dq op_jlt
    dq op_jgt
    dq op_jz
    dq op_jnz
    dq op_call
    dq op_ret
    dq op_cmpi
    dq op_jei
    dq op_jli
    dq op_jgi
    dq op_jzi
    dq op_jnzi
    dq op_jmpi
    dq op_calli
    dq op_sys

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
    db 1, 1, SYS_write, 0
    db 1, 2, 20, 0
    db 1, 3, 12, 0
    db 45, 0, 0, 0
    db 0, 2, 0, 0
    db 'Hello World', 10
nano_code_len = $ - nano_code
