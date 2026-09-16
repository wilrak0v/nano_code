# Documentation
Here is the documentation.

## Instructions
The computer execute instructions.
An instruction is composed of an opcode and one or more operands.

There are 45 opcodes in nano_code.
But you won't use all of them, assembly use same name for multiple instructions.

### Mov
The mov family instruction is used to place a value in a register or to move the content of a register into another.

The first operand of mov is the destination, and the second can be an immediate value or a register.

Example
```asm
mov r1, 10
mov r2, r1
```

### Store and load
You can use them to store something in memory and to load something from this memory.
They have different prefix for different size in bits.

The first operand is always the destination and the second one is the source.

Store has an address as the destination and a register as the source. It's just reverse for the load.

> Note that when we access to an address stored in a register, we write [] around this register.

Example
```asm
mov r1, 10
mov r2, 100

store8 [r1], r2

load8 r4, [r1]
```

### Arithmetic operations
Of course we can perform arithmetic operations in nano_code. 

So they take two operands, the first is the destination and the second is the source.
For example, in an addition, it adds the destination and the source and it stores it into the destination register.
The source can be an immediate value

| Instruction | Meaning        |
|-------------|----------------|
| add         | addition       |
| sub         | subtract       |
| mul         | multiplication |
| div         | division       |
| mod         | modulo         |

### Bits operations
