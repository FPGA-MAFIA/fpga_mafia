//------------------------------------------------------------
// Title : alive fpga
// Project : big_core
//------------------------------------------------------------
// File : alive_fpga.c
// Author : Daniel Kaufman
// Adviser : Amichai Ben-David
// Created : 03/2023
//------------------------------------------------------------
// Description :
//------------------------------------------------------------
#include "big_core_defines.h"
#include "graphic_vga.h"

void wait(int cycles) {
    for (int i = 0; i < cycles; i++) {
        asm("nop");
    }
}




void print_fixed_point(int value, int precision) {
    int intPart = value / precision;
    int fractionalPart = value % precision;
    rvc_print_int(intPart);
    rvc_printf(".");
    rvc_print_int(fractionalPart);
}

int calculate_pi(int iterations) {
  int pi = 0;
  int precision = 100000000;
  int i;
    set_cursor(14, 14);
    rvc_printf("                              ");
  for (i = 0; i < iterations; ++i) {

    set_cursor(14, 14);
    int term = (i % 2 == 0 ? 1 : -1) * precision / (2 * i + 1);
    pi += term;
    rvc_printf("ITER ");
    rvc_print_int(i + 1);
    rvc_printf(". ");
    print_fixed_point(pi * 4, precision);
    rvc_printf("\n");
  }
  return pi * 4;
}

int start_pi_calc() {
  int iterations = 2000000; // Increase for a more accurate result
    set_cursor(6, 6);
  rvc_printf("\n\n CALCULATE PIE \n");
  calculate_pi(iterations);
  return 0;
}



int main()  {  

    set_cursor(0, 0);
    //writing a string VGA
    rvc_printf("ABCDEFGHIJKLMNOPQRSTUVWXYZ\n");
    int test = 123456789;
    //writing an integer to VGA
    rvc_print_int(test);
    //writing to the FPGA 7-segment
    int count =0;
    while(1) {
    //writing to the FPGA LED & 7-segment
        CR_LED[0] = 0;
        for (int i = 0; i < 10; i++) {
            CR_LED[0] = 1 << i;
            fpga_7seg_print(count++);
            wait(1000000);
        }
        start_pi_calc();
    }

    return 0;
}  // main()
