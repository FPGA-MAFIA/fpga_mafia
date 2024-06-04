//------------------------------------------------------------
// Title   : hw_lfsr
// Project : big_core_cachel1
//------------------------------------------------------------
// Description :
// Testing random.h LFSR functions. 
// The numbers are generated in HW
//------------------------------------------------------------

#include "big_core_defines.h"
#include "graphic_vga.h"
#include "random.h"
#include "csr.h"

int main() {

// Test Test the 'get_random_int' function with default seed
rvc_print_unsigned_int_hex(get_hw_random_int());  // expect to see '0x8000000' 

// Setting the 'hw_lfsr_seed'
set_hw_lfsr_seed(0xACE1);

// Test the 'get_hw_random_int' function
rvc_printf("\n");
rvc_print_unsigned_int_hex(get_hw_random_int());  // expect to see '0x80005670'

rvc_printf("\n");
rvc_print_unsigned_int_hex(get_hw_random_int());  // expect to see '0xC0002B38'

// Test the 'get_hw_random_0_127' function
rvc_printf("\n");
rvc_print_int(get_hw_random_0_127()); // expect '28'


return 0;

}