int main(){

    int x = 10;
    int y = 5;

    int z = x + y;

    asm(".word 0x40E79833  " :  /* outputs / : / inputs / : / clobbers */);
    // 0100 000 01110 01111 001 10000 0110011 = (x16 = x14 + x15 + 1)

    return 0;

}