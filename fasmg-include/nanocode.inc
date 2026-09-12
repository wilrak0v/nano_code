element Register

element r0 : Register + 0
element r1 : Register + 1
element r2 : Register + 2

macro movi dst*, value
    local reg_num
    reg_num = dst metadata 1 scale 1
    db 0x01, reg_num
    dw value
end macro

macro movl dst*, value
    local reg_num
    reg_num = dst metadata 1 scale 1
    db 0x02, reg_num, 0x00, 0x00
    dd value
end macro

macro jmpi dst
    db 0x2c, dst, 0x00, 0x00
end macro

macro halt
    db 0x00, 0x01, 0x00, 0x00
end macro
