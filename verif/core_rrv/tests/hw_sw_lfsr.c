//------------------------------------------------------------
// Title : sw_lfsr
// Project : core_rrv
//------------------------------------------------------------
// Description :
// Testing random.h LFSR functions. 
// The numbers are generated in sw
//------------------------------------------------------------

#include "big_core_defines.h"
#include "graphic_vga.h"
#include "random.h"

int main() {

    // Test Test the 'get_random_int' function with default seed
    int is_hw_sw_lfsr_same;
    int hw_lfsr, sw_lfsr;
    // check if the sw and hw LFSR are the same with default seed
    hw_lfsr = get_hw_random_int();
    sw_lfsr = get_random_int();
    is_hw_sw_lfsr_same = (hw_lfsr == sw_lfsr);
    if(is_hw_sw_lfsr_same){
        rvc_printf("PASS\n");
    }else{
        rvc_printf("FAIL\n");
    }

    // set the seed to 0xACE1 both for sw and hw LFSR
    set_lfsr_seed(0xACE1);
    set_hw_lfsr_seed(0xACE1);
    // check if the sw and hw LFSR are the same
    for(int i=0; i<5; i++){
        hw_lfsr = get_hw_random_int();
        sw_lfsr = get_random_int();
        is_hw_sw_lfsr_same = (hw_lfsr == sw_lfsr);
        if(is_hw_sw_lfsr_same){
            rvc_printf("\nPASS  ");
            rvc_print_unsigned_int_hex(hw_lfsr);
        }else{ //If the LFSR are not the same, print FAIL and the values of the LFSR
            rvc_printf("\nFAIL");
            rvc_print_unsigned_int_hex(hw_lfsr);
            rvc_printf("  ");
            rvc_print_unsigned_int_hex(sw_lfsr);
        }
    }

    // check if the sw and hw LFSR are the same for the 0-127 function range
    for(int i=0; i<5; i++){
        hw_lfsr = get_hw_random_0_127();
        sw_lfsr = get_random_0_127();
        is_hw_sw_lfsr_same = (hw_lfsr == sw_lfsr);
        if(is_hw_sw_lfsr_same){
            rvc_printf("\nPASS  ");
            rvc_print_int(hw_lfsr);  // expect to see '0xC0002B38'
        }else{ //If the LFSR are not the same, print FAIL and the values of the LFSR
            rvc_printf("\nFAIL");
            rvc_print_int(hw_lfsr);
            rvc_printf("  ");
            rvc_print_int(sw_lfsr);
        }
    }
    return 0;

}
