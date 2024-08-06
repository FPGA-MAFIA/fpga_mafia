// Define the necessary types if stdint.h is not available
typedef unsigned int uint32_t;

int main() {
    volatile uint32_t *address = (volatile uint32_t *)0x00FE0004;
    uint32_t value;

    // Store the value 101010 at the memory address using inline assembly
    asm volatile (
        "li t1, 101010\n\t"        // Load immediate value 5 into t1
        "sw t1, 0(%0)\n\t"    // Store t1 to the memory address in a0
        : // No outputs
        : "r" (address)
        : "t1", "memory"      // Clobber list
    );

    // Read the value from the memory address for 10 cycles using inline assembly
    for (int i = 0; i < 10; ++i) {
        asm volatile (
            "lw t2, 0(%1)\n\t"  // Load the value from the memory address into t2
            "mv %0, t2\n\t"     // Move the value from t2 to output register
            : "=r" (value)
            : "r" (address)
            : "t2"
        );
        // Use the value to prevent the compiler from optimizing the read out
        (void)value;  // This line is to prevent unused variable warnings
    }



    // Store the value 202020 at the memory address using inline assembly
    asm volatile (
        "li t1, 202020\n\t"        // Load immediate value 5 into t1
        "sw t1, 0(%0)\n\t"    // Store t1 to the memory address in a0
        : // No outputs
        : "r" (address)
        : "t1", "memory"      // Clobber list
    );

    // Read the value from the memory address for 10 cycles using inline assembly
    for (int i = 0; i < 10; ++i) {
        asm volatile (
            "lw t2, 0(%1)\n\t"  // Load the value from the memory address into t2
            "mv %0, t2\n\t"     // Move the value from t2 to output register
            : "=r" (value)
            : "r" (address)
            : "t2"
        );
        // Use the value to prevent the compiler from optimizing the read out
        (void)value;  // This line is to prevent unused variable warnings
    }

    return 0;
}
