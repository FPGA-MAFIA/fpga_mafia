//------------------------------------------------------------------------------------------------------
// Description:
// This test aims to compare IPC (Instructions Per Cycle) by performing 
// multiplication of 32-bit integers using an RV32I core without the 'M' extension
// and without using dedicated hardware. When dealing with large numbers, approximately 500 cycles
// are added per 1 multiplication. With the use of basic multiplier hardware such as the 
// "shift and add" method, up to 32 cycles are added per multiplication. This results in an 
// approximate speedup of x15 times per multiplication.
// To perform that analysis COMMENT the included libraries and print functions and Watch the `trk_cpi_ipc_trk.log' file
//-------------------------------------------------------------------------------------------------------

#include "big_core_defines.h"
#include "graphic_vga.h"

typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

int main() {
    uint32_t x = 2147483647; 
    uint32_t y = 2147483647;

    uint64_t z = (uint64_t)x * y;  // Full 64-bit multiplication
    uint32_t low = (uint32_t)(z & 0xFFFFFFFF);  // Extract lower 32 bits
    uint32_t high = (uint32_t)(z >> 32);  // Extract upper 32 bits

    // Use 'low' and 'high' as needed
    // comment those functions and the libraries to perform more accurate analysis using `trk_cpi_ipc_trk.log' file
    rvc_print_int(low);  
    rvc_printf("\n");
    rvc_print_int(high);

    return 0;
}
