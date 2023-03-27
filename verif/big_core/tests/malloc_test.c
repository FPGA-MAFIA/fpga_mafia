//------------------------------------------------------------
// Title : 
// Project :
//------------------------------------------------------------
// File : 
// Author : 
// Adviser :
// Created :
//------------------------------------------------------------
// Description :
// 
//------------------------------------------------------------
#include <stdlib.h>
#include "big_core_defines.h"
#include "graphic_vga.h"

int main() {
    int *arr;
    int size, i;

    //printf("Enter the size of the array: ");
    //scanf("%d", &size);
    size = 10;
    // Allocate memory for the array using malloc
    arr = (int *) malloc(size * sizeof(int));

    if (arr == NULL) {
        rvc_printf("FAILED\n");
        return 1;
    }

    // Initialize the array with values
    for (i = 0; i < size; i++) {
        arr[i] = i * 2;
    }

    // Print the array
    rvc_printf("ARRAY\n");
    for (i = 0; i < size; i++) {
        rvc_print_int(arr[i]);
    }
    // Free the allocated memory
    free(arr);

    return 0;
}
