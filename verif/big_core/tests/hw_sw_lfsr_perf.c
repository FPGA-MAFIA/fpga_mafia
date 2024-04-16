//------------------------------------------------------------
// Title   : hw_sw_lfsr_perf
// Project : big_core
//------------------------------------------------------------
// Description :
// Testing performance of random.h LFSR functions HW vs SW
//------------------------------------------------------------

#include "big_core_defines.h"
#include "graphic_vga.h"
#include "random.h"
#include "csr.h"
#include "interrupt_handler.h"

// define number of random numbers to be generated
#define NUM_RANDOM_NUMBERS 10
int main() {
//create two arrays to store the LFSR values
int hw_lfsr[NUM_RANDOM_NUMBERS];
int sw_lfsr[NUM_RANDOM_NUMBERS];

int cycle1, cycle2, cycle3;
// sample registers for the first time
cycle1 = READ_CSR(mcycle);
// create NUM_RANDOM_NUMBERS random numbers and store them in the hw_lfsr array
for(int i=0; i<NUM_RANDOM_NUMBERS; i++){
    hw_lfsr[i] = get_hw_random_int();
}
// sample registers for the second time
cycle2 = READ_CSR(mcycle);
// create NUM_RANDOM_NUMBERS random numbers and store them in the sw_lfsr array
for(int i=0; i<NUM_RANDOM_NUMBERS; i++){
    sw_lfsr[i] = get_random_int();
}
// sample registers for the third time
cycle3 = READ_CSR(mcycle);

//=======================================================
//Print the HW LFSR values and the latency
//=======================================================
//rvc_printf("\nHW LFSR VALUES ");
//for(int i=0; i<NUM_RANDOM_NUMBERS; i++){
//    rvc_print_unsigned_int_hex(hw_lfsr[i]);
//    rvc_printf(" ");
//}
rvc_printf("\nHW LFSR LATENCY ");
rvc_print_int(cycle2 - cycle1);

//=======================================================
//Print the SW LFSR values and the latency
//=======================================================
//rvc_printf("\nSW LFSR VALUES ");
//for(int i=0; i<NUM_RANDOM_NUMBERS; i++){
//    rvc_print_unsigned_int_hex(sw_lfsr[i]);
//    rvc_printf("  ");
//}
rvc_printf("\nSW LFSR LATENCY ");
rvc_print_int(cycle3 - cycle2);


return 0;
}