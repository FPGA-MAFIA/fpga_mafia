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
    // read CSR in offset 0x009  - should have the value 5
    int scratchpad_csr_value;
    asm volatile ("csrr %0, 0x009" : "=r" (scratchpad_csr_value));
    rvc_printf(" VAL ");
    rvc_print_int(scratchpad_csr_value);
    //write to CSR in offset 0x009 the value 0x7
    asm volatile ("csrw 0x009, 0x7");
    // read CSR in offset 0x009  - should have the value 0x7
    asm volatile ("csrr %0, 0x009" : "=r" (scratchpad_csr_value));
    rvc_printf("\n VAL ");
    rvc_print_int(scratchpad_csr_value);

    // read the CSR in offset 0xC00 - the cycle counter
    int cycle_counter1;
    int cycle_counter2;
    asm volatile ("csrr %0, 0xC00" : "=r" (cycle_counter1));
    rvc_delay(100);
    asm volatile ("csrr %0, 0xC00" : "=r" (cycle_counter2));
    rvc_printf("\n COUNT1 ");
    rvc_print_int(cycle_counter1);
    rvc_printf("\n COUNT2 ");
    rvc_print_int(cycle_counter2);
    int counter = cycle_counter2 - cycle_counter1;
    rvc_printf("\n DIFF   ");
    rvc_print_int(counter);

    return 0;
}  // main()
