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
  int iterations = 50000; // Increase for a more accurate result
    set_cursor(6, 6);
  rvc_printf("\n\n CALCULATE PIE \n");
  calculate_pi(iterations);
  return 0;
}



void matrix_calc(){
    set_cursor(70, 0);
    int matrix_1 [3][3] = {{1,2,3},{4,5,6},{7,8,9}};
    int matrix_2 [3][3] = {{1,2,3},{4,5,6},{7,8,9}};
    int matrix_3 [3][3] = {{0,0,0},{0,0,0},{0,0,0}};

    rvc_printf("MATRIX 1\n");
    for (int i=0; i<3; i++){
        for (int j=0; j<3; j++){
            rvc_print_int(matrix_1[i][j]);
            rvc_printf(" ");
        }
        rvc_printf("\n");
    }
    rvc_printf("\nMATRIX 2\n");
    for (int i=0; i<3; i++){
        for (int j=0; j<3; j++){
            rvc_print_int(matrix_2[i][j]);
            rvc_printf(" ");
        }
        rvc_printf("\n");
    }
    //calculate matrix_3 = matrix_1 * matrix_2
    for (int i=0; i<3; i++){
        for (int j=0; j<3; j++){
            for (int k=0; k<3; k++){
                matrix_3[i][j] += matrix_1[i][k] * matrix_2[k][j];
            }
        }
    }
    rvc_printf("\nMATRIX 3\n");
    for (int i=0; i<3; i++){
        for (int j=0; j<3; j++){
            rvc_print_int(matrix_3[i][j]);
            rvc_printf(" ");
        }
        rvc_printf("\n");
    }
}

int main()  {  
    clear_screen();
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
        matrix_calc();
    }

    return 0;
}  // main()
