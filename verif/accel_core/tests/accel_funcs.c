typedef unsigned int uint32_t;  // Define uint32_t as unsigned int

volatile uint32_t *address = (volatile uint32_t *)0x00FE0000;

int xor_accel(int x, int y) {
    uint32_t result;
    asm volatile (
        // Store x into *address using t0
        "mv t0, %1\n\t"
        "sw t0, 0(%2)\n\t"
        // Store y into *address + 4 using t1
        "mv t1, %3\n\t"
        "sw t1, 4(%2)\n\t"
        // Add  NOP
        "nop\n\t"
        // Load value from *address + 8 into result using t2
        "lw t2, 8(%2)\n\t"
        "mv %0, t2\n\t"
        : "=r" (result)          // Output operand
        : "r" (x), "r" (address), "r" (y)  // Input operands
        : "t0", "t1", "t2", "memory"  // Clobber list: temporary registers and memory are affected
    );
    return result;
}
