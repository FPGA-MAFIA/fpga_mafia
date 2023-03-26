//------------------------------------------------------------
// Title : gcd test
// Project : big_core
//------------------------------------------------------------
// File : gcd.c
// Author : Daniel Kaufman
// Adviser : Amichai Ben-David
// Created : 01/2023
//------------------------------------------------------------
// Description :
// This program calculates the greatest common divisor (GCD)
// of two integers using the Euclidean algorithm.
//------------------------------------------------------------
#include "../../../app/defines/big_core_defines.h"

int gcd(int a, int b) {
    if (b == 0) return a;
    return gcd(b, a % b);
}

int main() {
    int a = 48, b = 18;
    int gcd_res = gcd(a, b);
    D_MEM_SCRATCH[0]=gcd_res;
    return 0;
}

