# ISA

## REGISTERS
- [x] Movi  R, 16     => Immediate
- [x] Movl  R, 16     => Immediate (64 bits)
- [x] Movr  R, R      => Indirect

- [x] Store8 [R], R   => Indirect
- [x] Load8  R, [R]   => Indirect
- [x] Store16 [R], R  => Indirect
- [x] Load16 R, [R]   => Indirect
- [x] Store32 [R], R  => Indirect
- [x] Load32 R, [R]   => Indirect

- [x] Add   R, R      => Indirect
- [x] Sub   R, R      => Indirect
- [x] Mul   R, R      => Indirect
- [x] Div   R, R      => Indirect
- [x] Mod   R, R      => Indirect

- [x] Addi  R, 16     => Immediate
- [x] Subi  R, 16     => Immediate
- [x] Muli  R, 16     => Immediate 
- [x] Divi  R, 16     => Immediate 
- [x] Modi  R, 16     => Immediate 

- [x] AND   R, R      => Indirect
- [x] OR    R, R      => Indirect
- [x] XOR   R, R      => Indirect
- [x] SHL   R, R      => Indirect
- [x] SHR   R, R      => Indirect

- [x] SHLI  R, 16     => Immediate
- [x] SHRI  R, 16     => Immediate

- [X] CMP   R, R      => Indirect 
- [x] JMP   [R]       => Indirect
- [x] JE    [R]       => Indirect
- [x] JL    [R]       => Indirect
- [x] JG    [R]       => Indirect
- [x] JZ    R, [R]    => Indirect
- [x] JNZ   R, [R]    => Indirect
- [x] CALL  [R]       => Indirect
- [x] RET

- [x] CMPI  R, 16     => Immediate
- [x] JMPI  16        => Immediate
- [x] JEI   16        => Immediate
- [x] JLI   16        => Immediate 
- [x] JGI   16        => Immediate 
- [x] JZI   R, 16     => Immediate
- [x] JNZI  R, 16     => Immediate
- [x] CALLI 16        => Immediate 

- [x] SYS   16        => Immediate
