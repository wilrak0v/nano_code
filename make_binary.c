#include <stdio.h>

int rom[] = {
    0x00010300,
    -1 // End
};

int
main()
{
    FILE *fp = fopen("binary.bin", "wb");
    int index = 0;
    while (rom[index] != -1) {
        index++;
    }
    fwrite(rom, 4, index, fp);
    fclose(fp);
    return 0;
}
