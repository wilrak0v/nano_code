r0 = 0
r1 = 1
r2 = 2
r3 = 3
r4 = 4

macro movi dst*, value*
    if dst < 0 or dst > 32
        err "Unknown register"
    end if

    db 0x01, dst 
    dw value
end macro

macro movl dst*, value*
    db 0x02, dst, 0x00, 0x00
    dd value
end macro

macro movr dst*, src*
    db 0x03
    db dst 
    db src, 0x00
end macro

macro jmpi dst
    db 0x2c, dst, 0x00, 0x00
end macro

macro halt dst*
    db 0x00, dst, 0x00, 0x00
end macro
