#subruledef reg {
    r0 => 0x00
    r1 => 0x01
    r2 => 0x02
    r3 => 0x03
}

#ruledef main {
    halt {r: reg} => 0x00 @ r @ r @ r 
    movi {r: reg}, {im: u16} => 0x01 @ r @ im[7:0] @ im[15:8] 
}
