#include <stdio.h>
#include <stdint.h>

#define DISPATCH() goto *op_table[vm->fetch8(vm->ip++)];

enum opcodes {
    HALT = 0x00,
    MOVI = 0x01,
    MOVL = 0x02,
    MOVR = 0x03,
};

uint8_t code[] = {
    MOVI, 0x01, 0x0A, 0x0A, 
    MOVR, 0x02, 0x01,
    HALT, 0x02
};

typedef struct {
    uint8_t ip;
    uint32_t registers[32];
    uint8_t* memory;
    uint8_t (*fetch8)(uint8_t);
} nano_code_t;

enum action_type {
    ACTION_HALT = 0x00,
};

typedef struct {
    int type;
    int halt_code;
} nano_action_t;

nano_action_t
run(nano_code_t* vm)
{
    static const void *op_table[] = {
        [0x00] = &&op_halt,
        [0x01] = &&op_movi,
        [0x02] = &&op_movl,
        [0x03] = &&op_movr,
    };

    DISPATCH();

op_halt:
    puts("HALT");
    return (nano_action_t){
        .type = ACTION_HALT,
        .halt_code = vm->registers[vm->fetch8(vm->ip++)]
    };

op_movi:
    puts("Mov Immediate");
    vm->registers[vm->fetch8(vm->ip)] = (uint32_t)vm->fetch8(vm->ip+1) | (vm->fetch8(vm->ip+2) << 8);
    vm->ip += 3;
    DISPATCH();

op_movl:
    puts("Mov long");
    vm->registers[vm->fetch8(vm->ip)] = (uint32_t) vm->fetch8(vm->ip+1) |
                                                  (vm->fetch8(vm->ip+2) << 8) |
                                                  (vm->fetch8(vm->ip+3) << 16) |
                                                  (vm->fetch8(vm->ip+4) << 24);
    vm->ip += 5;
    DISPATCH();

op_movr:
    puts("Mov Register");
    vm->registers[vm->fetch8(vm->ip)] = (uint32_t) vm->registers[vm->fetch8(vm->ip+1)];
    vm->ip += 2;
    DISPATCH();
}

uint8_t
fetch(uint8_t ip) {
    return code[ip];
}

int
main()
{
    nano_code_t vm = {
        .ip = 0,
        .memory = NULL,
        .fetch8 = &fetch
    };
    nano_action_t t = run(&vm);
    return t.halt_code;
}
