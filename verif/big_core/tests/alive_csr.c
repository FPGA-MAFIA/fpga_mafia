#include "csr.h"
//------------------------------------------------------------
// Description :
// This program is a basic sanity test for the csr
//------------------------------------------------------------

int main()  {  
    
    // ------------------ CSR read or write only ---------------- //
    //-----------------------------------------------------------//

    asm volatile ("csrw 0x340, 0x7");   
    int scratchpad_csr_value;
    asm volatile ("csrr %0, 0x340" : "=r" (scratchpad_csr_value));  

    //write to CSR in offset 0x301 the value of 30
    // pseudiInstr: csrw csr, rs. baseInst:  csrrw x0, csr, rs 
    int misa_csr_value = 30;
    asm volatile ("csrw 0x301, %0" : : "r" (misa_csr_value)); 

    // pseudoInst: csrsi csr, imm. baseInst: csrrsi x0, csr, imm
    asm volatile ("csrs 0x340, 0x1b");    
    
    //clear bits in CSR in offset 0x009 the value 0x4
    // pseudoInst: csrci csr, imm. baseInst: csrrci x0, csr, imm
    asm volatile ("csrc 0x340, 0x1b");    

    //set CSR in offset 0x301 using value 63
    // pseudiInstr: csrs csr, rs. baseInst: csrrs x0, csr, rs 
    int set_misa_csr = 63;
    asm volatile ("csrs 0x301, %0" : : "r" (set_misa_csr)); 

    //clear CSR in offset 0x301 using value 11 
    // pseudiInstr: csrc csr, rs. baseInst: csrrc x0, csr, rs 
    int clear_misa_csr = 11;
    asm volatile ("csrc 0x301, %0" : : "r" (clear_misa_csr)); 


    // ------------------ CSR read and write  ---------------- //
    //---------------------------------------------------------//
    int new_value = 20;
    int previous_value;
    asm volatile ("csrrw  %0, 0x340, %1"    : "=r" (previous_value) : "r" (new_value));
    asm volatile ("csrrw  %0, 0x340, %1"    : "+r" (previous_value) : "r" (new_value));
    asm volatile ("csrrs  %0, 0x340, %1"    : "+r" (previous_value) : "r" (new_value));
    asm volatile ("csrrc  %0, 0x340, %1"    : "+r" (previous_value) : "r" (new_value));
    asm volatile ("csrrwi %0, 0x340, 0x1b"  :                       : "r" (previous_value));
    asm volatile ("csrrsi %0, 0x340, 0x1b"  :                       : "r" (previous_value));
    asm volatile ("csrrci %0, 0x340, 0x1b"  :                       : "r" (previous_value));

    // --------- special cases from spec involving x0  -------- //
    // --------- test them using assemnbly file ---------------//
    /*
    csrwi	vxsat,7
    csrrw	x1,vxsat,x0
    csrwi	vxsat,7
    csrwi	vxsat,0
    */
   
    return 0;
}  

