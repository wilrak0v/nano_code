#subruledef reg {
    r0 => 0x00
    r1 => 0x01
    r2 => 0x02
    r3 => 0x03
    r4 => 0x04
}

#ruledef main {
    halt {r: reg} => 0x00 @ r @ r @ r 
    movi {r: reg}, {im: u16} => 0x01 @ r @ im[7:0] @ im[15:8] 
    movl {r: reg}, {im: u32} => 0x02 @ r @ 0x0000 @ im[7:0] @ im[15:8] @ im[23:16] @ im[31:24]
    movr {dst: reg}, {src: reg}  => 0x03 @ dst @ src @ 0x00
    add {dst: reg}, {src: reg} => 0x0A @ dst @ src @ 0x00
    subi {dst: reg}, {im: u16} => 0x10 @ dst @ im[7:0] @ im[15:8]
    cmpi {r: reg}, {im: u16}    => 0x25 @ r @ im[7:0] @ im[15:8] 
    jei [{address: u16}]        => 0x26 @ address[7:0] @ address[15:8] @ 0x00
    jnzi {r: reg}, [{address: u16}] => 0x2a @ r @ address[7:0] @ address[15:8]
    jmpi [{address: u16}]       => 0x2b @ address[7:0] @ address[15:8] @ 0x00
}
