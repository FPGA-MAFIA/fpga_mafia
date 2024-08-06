typedef unsigned int uint32_t;  // Define uint32_t as unsigned int

volatile uint32_t *address = (volatile uint32_t *)0x00FE0000;

int xor_accel(int x, int y) {
    uint32_t result;
    asm volatile (
        // Load x into address
        "sw %1, 0(%0)\n\t"   // Store x into *address
        // Load y into address + 4
        "sw %2, 4(%0)\n\t"   // Store y into *address + 4
        // Add 5 NOPs
        "nop\n\t"
        "nop\n\t"
        "nop\n\t"
        "nop\n\t"
        "nop\n\t"
        // Load value from address + 8 and return it
        "lw %0, 8(%0)\n\t"   // Load from *address + 8 into result register
        : "=r" (result)      // Output operand
        : "r" (x), "r" (y), "r" (address)  // Input operands
        : "memory"           // Clobber list: memory is affected
    );
    return result;
}
