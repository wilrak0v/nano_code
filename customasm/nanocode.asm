#subruledef reg {
    r0 => 0x00
    r1 => 0x01
    r2 => 0x02
    r3 => 0x03
}

#ruledef main {
    halt {r: reg} => 0x00 @ r @ 0x00000
    movi {r: reg}, {im: u16} => 0x01 @ r @ im
    movl {r: reg}, {im: u32} => 0x02000000 @ r
    movr {dst: reg}, {src: reg} => 0x03 @ dst @ src @ 0x00
}
