//------------------------------------------------------------
// Title : alive_lfsr
// Project : core_rrv
//------------------------------------------------------------
// Description :
// Testing random.h LFSR function. 
// The numbers are generated in sw
//------------------------------------------------------------

#include "big_core_defines.h"
#include "graphic_vga.h"
#include "random.h"

int main(){

    // Test the 'set_lfsr_seed' function
    set_lfsr_seed(0xACE1);
    rvc_print_int(lfsr_seed);  // expecting to see '44257'

    // Test the 'get_random_int' function
    rvc_printf("\n");
    rvc_print_unsigned_int_hex(get_random_int());  // expect to see '0x80005670'

    rvc_printf("\n");
    rvc_print_unsigned_int_hex(get_random_int());  // expect to see '0xC0002B38'

    // Test the 'get_random_0_127' function
    rvc_printf("\n");
    rvc_print_int(get_random_0_127()); // expect '28'          



 
    return 0;

}
