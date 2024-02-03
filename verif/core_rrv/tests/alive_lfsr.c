
//------------------------------------------------------------
// Title : alive_lfsr
// Project : core_rrv
//------------------------------------------------------------
// Description :
//generating LENGTH pseudo random numbers created using LFSR
//------------------------------------------------------------
#include "big_core_defines.h"
#include "graphic_vga.h"
#define LENGTH 10

// Function to generate the next LFSR value
unsigned int lfsr(unsigned int current_state) {
    // Feedback polynomial: x^8 + x^6 + x^5 + x^4 + 1
    // We use taps at positions 8, 6, 5, and 4.
    unsigned int bit = ((current_state >> 7) ^ (current_state >> 5) ^ (current_state >> 4) ^ (current_state >> 3)) & 1;
    return (current_state << 1) | bit; // Shift left and add feedback bit
}

// Function to generate a pseudo-random number in the range 0-99
unsigned int lfsr_random_0_99(unsigned int seed) {
    unsigned int random_value = 0;
    for (int i = 0; i < 7; ++i) { // Generate 7 bits
        seed = lfsr(seed); // Update LFSR state
        random_value = (random_value << 1) | (seed & 1); // Append LSB of LFSR state to random_value
    }
    return random_value % 100; // Modulate by 100 to get a range of 0-99
}

int main() {
    unsigned int seed = 0xACE1u; // Non-zero seed
    unsigned int random_numbers[LENGTH];

    // Fill the array with pseudo-random numbers within the range 0-99
    for (int i = 0; i < LENGTH; ++i) {
        random_numbers[i] = lfsr_random_0_99(seed + i); // Use varying seeds for each number
        rvc_print_int(random_numbers[i]);
        rvc_printf(" ");
    }

    return 0;
}
