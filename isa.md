# ISA

## REGISTERS
- Movi  R, 16     => Immediate
- Movr  R, R      => Indirect
- Loadi R, 16     => Immediate
- Stori R, 16     => address

- Load  R, [R]    => Indirect
- Store R, [R]    => Indirect
- Push  R         => Indirect
- Pop   R         => Indirect

- Add   R, R, R   => Indirect
- Sub   R, R, R   => Indirect
- Mul   R, R, R   => Indirect
- Div   R, R, R   => Indirect
- Mod   R, R, R   => Indirect

- Addi  R, R, 16  => Immediate
- Subi  R, R, 16  => Immediate
- Muli  R, R, 16  => Immediate 
- Divi  R, R, 16  => Immediate 
- Modi  R, R, 16  => Immediate 

- AND   R, R, R   => Indirect
- OR    R, R, R   => Indirect
- XOR   R, R, R   => Indirect
- SHL   R, R      => Indirect
- SHR   R, R      => Indirect

- SHLI  R, 16     => Immediate
- SHRI  R, 16     => Immediate

- CMP   R, R      => Indirect 
- JMP   [R]       => Indirect
- JZ    [R]       => Indirect
- JNZ   [R]       => Indirect
- CALL  [R]       => Indirect
- RET

- JMPI  16        => Immediate
- JZI   16        => Immediate
- JNZI  16        => Immediate
- CALLI 16        => Immediate 

- SYS   16        => Immediate
