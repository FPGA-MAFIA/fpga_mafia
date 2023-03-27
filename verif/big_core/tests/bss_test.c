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
// The .bss section is used for uninitialized global and static variables. The memory for these variables is automatically zeroed out before your program starts executing.
// In this program, the global_bss variable and the static_bss variable inside the static_function function are both uninitialized and will be placed in the .bss section. The memory for these variables will be automatically zeroed out before the program starts executing.
// The global_data variable is initialized to 42 and will be placed in the .data section.
//------------------------------------------------------------

#include "big_core_defines.h"
#include "graphic_vga.h"

// Uninitialized global variable - will be placed in the .bss section
int global_bss;

// Initialized global variable - will be placed in the .data section
int global_data = 42;

// Function with a static variable
int static_function() {
    // Uninitialized static variable - will be placed in the .bss section
    static int static_bss;
    return ++static_bss;
}

int main() {
    rvc_printf("GLOBAL_BSS:\n");                     
    rvc_print_int(global_bss);      // Should print 0
    rvc_printf(" \n");                     
    rvc_printf("GLOBAL_DATA:\n"); 
    rvc_print_int(global_data);     // Should print 42
    rvc_printf(" \n");                     

    // Call static_function() twice to demonstrate that the static variable retains its value between calls
    rvc_printf("STATIC_FUNCTION:\n"); // Should print 1
    int a = static_function();
    rvc_print_int(a); // Should print 1
    rvc_printf(" \n");                     
    a = static_function();
    rvc_print_int(a); // Should print 2
    rvc_printf(" \n");                     
    a = static_function();
    rvc_print_int(a); // Should print 3
    rvc_printf(" \n");                     

    return 0;
}
