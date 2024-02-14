//------------------------------------------------------------
// Description :
// In this test we allows timer interrupt than, 
// start illegal instruction will cause clear of mstatus[3]
// during the exception handler the timer will be at pending state
// after we ruturn from the illegal instruction the HW sets mstatus[3]
// and timer interrupt will be taken 
//------------------------------------------------------------

#include "interrupt_handler.h"
int main() {

    //enable the mie timer interrupts CSR:
    set_mie(0x888);

    int x = 1;
    int y = 2;
    
    // This instruction is trying to generate slli instruction with illegal FUNCT7.
    int i = 0;
    while(i<3) {
        asm(".word 0xfff79793" : /* outputs / : / inputs / : / clobbers */);
        i++;
    }

    int z = x + y;

    // Reading mepc and mtval S
    int csr_mepc, csr_mtval;
    asm volatile ("csrr %0, 0x341" : "=r" (csr_mepc));
    asm volatile ("csrr %0, 0x343" : "=r" (csr_mtval)); 
        
    clear_mie(0x080); // disable timer interrupts while execution rcv_print_int 
    write_dscratch0(COUNT_MACHINE_TIMER_INTRPT[0]); //used for debug

    rvc_print_int(COUNT_MACHINE_TIMER_INTRPT[0]);

    return 0;
}