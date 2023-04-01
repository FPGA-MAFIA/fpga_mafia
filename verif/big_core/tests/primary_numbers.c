//------------------------------------------------------------
// Title : primary numbers test
// Project : big_core
//------------------------------------------------------------
// File : primary_numbers.c
// Author : Daniel Kaufman
// Adviser : Amichai Ben-David
// Created : 01/2023
//------------------------------------------------------------
// Description :
// This program finds all prime numbers up to a given number n 
//------------------------------------------------------------
#include "big_core_defines.h"

int isPrime(int n) {
    if (n <= 1) return 0;
    if (n <= 3) return 1;
    if (n % 2 == 0 || n % 3 == 0) return 0;

    for (int i = 5; i * i <= n; i = i + 6)
        if (n % i == 0 || n % (i + 2) == 0)
            return 0;

    return 1;
}
void eot(int *list, int size){
    for(int i = 0; i<size; i++){
        D_MEM_SCRATCH[i]=list[i];
    }
}
int main() {
    int n = 20;
    int primeNumbers[20]; // create an array to store the prime numbers
    int primeCounter = 0; // keep track of how many prime numbers have been found
    for (int i = 2; i <= n; i++) {
        if (isPrime(i)) {
            primeNumbers[primeCounter] = i; // add the prime number to the array
            primeCounter++;
        }
    }
    eot(primeNumbers, primeCounter);
}