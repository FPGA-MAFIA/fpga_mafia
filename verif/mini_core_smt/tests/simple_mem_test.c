//#include "big_core_defines.h"
//#include "graphic_vga.h"

void test_byte_memory_operations() {
    // Creating an 8-byte array with values 1 to 8
    char src_array[8] = {1, 2, 3, 4, 5, 6, 7, 8};
    
    // Destination array to store modified values
    char dest_array[8];
    
    for (int i = 0; i < 8; i++) {
        char value = src_array[i];       // Byte load from src_array
        dest_array[i] = value + 10;      // Addition and byte store to dest_array
    }
    
    // Printing the modified values for verification
    //for (int i = 0; i < 8; i++) {
    //    rvc_print_int(dest_array[i]);    // Expected: 11, 12, 13, 14, 15, 16, 17, 18
    //    rvc_printf("\n");
    //}
}

int main() {
    test_byte_memory_operations();
    return 0;
}
