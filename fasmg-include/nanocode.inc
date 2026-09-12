element reg
element r0 : reg + 0
element r1 : reg + 1
element r2 : reg + 2
element r3 : reg + 3

macro movi? reg, value
    db 0x01, reg
    dw value
end macro

macro halt? reg
    db 0x00, 0x01, 0x00, 0x00
end macro
