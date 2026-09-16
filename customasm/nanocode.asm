#subruledef reg {
    r0 => 0x0
    r1 => 0x1
    r2 => 0x2
    r3 => 0x3
    r4 => 0x4
    r5 => 0x5
    r6 => 0x6
    r7 => 0x7
    r8 => 0x8
    r9 => 0x9
    r10 => 0xa
    r11 => 0xb
    r12 => 0xc
    r13 => 0xd
    r14 => 0xe
    r15 => 0xf
    r16 => 0x10
    r17 => 0x11
    r18 => 0x12
    r19 => 0x13
    r20 => 0x14
    r21 => 0x15
    r22 => 0x16
    r23 => 0x17
    r24 => 0x18
    r25 => 0x19
    r26 => 0x1a
    r27 => 0x1b
    r28 => 0x1c
    r29 => 0x1d
    r30 => 0x1e
    r31 => 0x1f
}

#ruledef main {
    halt {r: reg}                   => 0x00 @ r @ r @ r 

    mov {r: reg}, {im: u16}         => 0x01 @ r @ im[7:0] @ im[15:8] 
    mov {r: reg}, {im: u32}         => 0x02 @ r @ 0x0000 @ im[7:0] @ im[15:8] @ im[23:16] @ im[31:24]
    mov {dst: reg}, {src: reg}      => 0x03 @ dst @ src @ 0x00

    store8 [{dst: reg}], {src: reg} => 0x04 @ dst @ src @ 0x00
    load8  {dst: reg}, [{src: reg}] => 0x05 @ dst @ src @ 0x00
    store16 [{dst: reg}], {src: reg}=> 0x06 @ dst @ src @ 0x00
    load16  {dst: reg}, [{src: reg}]=> 0x07 @ dst @ src @ 0x00
    store32 [{dst: reg}], {src: reg}=> 0x08 @ dst @ src @ 0x00
    load32  {dst: reg}, [{src: reg}]=> 0x09 @ dst @ src @ 0x00

    add {dst: reg}, {src: reg}      => 0x0A @ dst @ src @ 0x00
    sub {dst: reg}, {src: reg}      => 0x0B @ dst @ src @ 0x00
    mul {dst: reg}, {src: reg}      => 0x0C @ dst @ src @ 0x00
    div {dst: reg}, {src: reg}      => 0x0D @ dst @ src @ 0x00
    mod {dst: reg}, {src: reg}      => 0x0E @ dst @ src @ 0x00

    add {dst: reg}, {im: u16}       => 0x0F @ dst @ im[7:0] @ im[15:8]
    sub {dst: reg}, {im: u16}       => 0x10 @ dst @ im[7:0] @ im[15:8]
    mul {dst: reg}, {im: u16}       => 0x11 @ dst @ im[7:0] @ im[15:8]
    div {dst: reg}, {im: u16}       => 0x12 @ dst @ im[7:0] @ im[15:8]
    mod {dst: reg}, {im: u16}       => 0x13 @ dst @ im[7:0] @ im[15:8]

    and {dst: reg}, {src: reg}      => 0x14 @ dst @ src @ 0x00
    or  {dst: reg}, {src: reg}      => 0x15 @ dst @ src @ 0x00
    xor {dst: reg}, {src: reg}      => 0x16 @ dst @ src @ 0x00
    shl {dst: reg}, {src: reg}      => 0x17 @ dst @ src @ 0x00
    shr {dst: reg}, {src: reg}      => 0x18 @ dst @ src @ 0x00
    shl {dst: reg}, {im: u16}       => 0x19 @ dst @ im[7:0] @ im[15:8]
    shr {dst: reg}, {im: u16}       => 0x1A @ dst @ im[7:0] @ im[15:8]

    cmp {reg1: reg}, {reg2: reg}    => 0x1B @ reg1 @ reg2 @ 0x00
    jmp [{r: reg}]                  => 0x1C @ r @ 0x0000
    je  [{r: reg}]                  => 0x1D @ r @ 0x0000
    jne [{r: reg}]                  => 0x1E @ r @ 0x0000
    jlt [{r: reg}]                  => 0x1F @ r @ 0x0000
    jgt [{r: reg}]                  => 0x20 @ r @ 0x0000
    jz  {r: reg}, [{addr: reg}]     => 0x21 @ r @ addr @ 0x00
    jnz {r: reg}, [{addr: reg}]     => 0x22 @ r @ addr @ 0x00
    call [{r: reg}]                 => 0x23 @ r @ 0x0000
    ret                             => 0x24000000

    cmp {r: reg}, {im: u16}         => 0x25 @ r @ im[7:0] @ im[15:8] 
    je  {address: u16}              => 0x26 @ address[7:0] @ address[15:8] @ 0x00
    jlt {address: u16}              => 0x27 @ address[7:0] @ address[15:8] @ 0x00
    jgt {address: u16}              => 0x28 @ address[7:0] @ address[15:8] @ 0x00
    jz  {r: reg}, {addr: u16}       => 0x29 @ r @ addr[7:0] @ addr[15:8] @ 0x00
    jnz {r: reg}, [{address: u16}]  => 0x2A @ r @ address[7:0] @ address[15:8]
    jmp {address: u16}              => 0x2b @ address[7:0] @ address[15:8] @ 0x00
    call {addr: u16}                => 0x2C @ addr[7:0] @ addr[15:8] @ 0x00

    sys  {code: u16}                => 0x2D @ code[7:0] @ code [15:8]
}
