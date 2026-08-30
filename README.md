# Nano Code
Nano Code is a small and easy bytecode.

It is written in ASM so it's not as easy as C to compile.
For the x64 version (64-bits Intel and AMD) you'll need the FASM assembler.
The AAarch64 use GNU AS so it's easy to compile with the Makefile.

> Note that the Makefile works only with the AAarch64 version and it supposes that you're on an arm64 computer.

Feel free to contribute to this project.

## Architecture
The architecture is pretty simple. The main core is a fetch-decode-execute loop in ASM,
which is more simpler than in C in my opinion (for this task).

Why? Because we can use a table to jump. If you don't understand it's normal, so let's explain that.
Each instruction is an offset. So for example `movi` is the value 0x01 in my bytecode.
That means the loop gets the value 1 from the memory, and then jump to `table + 1`.

If you still don't understand then it's my fault because I am not very good at english.
I'll rewrite all of these words version after version.

Every instruction is 32-bits with operands included.
