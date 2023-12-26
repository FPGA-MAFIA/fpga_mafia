//------------------------------------------------------------
// Title : alive_cpi
// Project : big_core_rrv
//------------------------------------------------------------
// Description :
// basic program with printing CPI results on the screen 
//------------------------------------------------------------

#include "big_core_defines.h"
#include "graphic_vga.h"
void my_program(){

    int x = 10;
    int y = 20;
    int z = x + y;


}
int main(){
    int cycle1, cycle2;
    int instret1, instret2;

    // sample registers for the first time
    rvc_sample_csr(&cycle1, &instret1);
    
    // call your program
    my_program();

    // sample registers for the second time
    rvc_sample_csr(&cycle2, &instret2);
    
    int cycle_diff   = cycle1 - cycle2;
    int instret_diff = instret1 - instret2;
    
    int quotient, reminder;
    fix_div(instret_diff, cycle_diff, &quotient, &reminder);

    rvc_print_int(quotient);
    rvc_printf(".");
    rvc_print_int(reminder);

    return 0;
}