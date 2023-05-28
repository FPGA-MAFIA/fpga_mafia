//------------------------------------------------------------
// Title : alive csr
// Project : big_core
//------------------------------------------------------------
// File : alive_csr.c
// Author : Daniel Kaufman
// Adviser : Amichai Ben-David
// Created : 01/2023
//------------------------------------------------------------
// Description :
// This program is a basic sanity test for the csr
//------------------------------------------------------------
#include "big_core_defines.h"
#include "graphic_vga.h"
int main()  {  
    for(int i=0; i<1000; i++) {
        //busy wait
    }
    // read CSR in offset 0x009  - should have the value 5
    int scratchpad_csr_value;
    asm volatile ("csrr %0, 0x009" : "=r" (scratchpad_csr_value));
    // read the counter 
    int cycle_counter1;
    asm volatile ("csrr %0, 0xC00" : "=r" (cycle_counter1));
    rvc_printf(" VAL ");
    rvc_print_int(scratchpad_csr_value);
    rvc_printf("\n VAL ");
    rvc_print_int(cycle_counter1);



    return 0;
}  // main()
