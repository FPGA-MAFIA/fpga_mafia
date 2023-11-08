//------------------------------------------------------------
// Description :
// This program is a basic sanity test for the csr
//------------------------------------------------------------

int main()  {  
 
    //write to CSR in offset 0x009 the value 0x7
    asm volatile ("csrw 0x009, 0x7");   // pseudoInst: csrwi csr, imm. baseInst: csrrw x0, csr, rs

    // read CSR in offset 0x009  - should have the value 7
    int scratchpad_csr_value;
    asm volatile ("csrr %0, 0x009" : "=r" (scratchpad_csr_value));  //pseudoInst: csrr rd, csr. baseInst:  csrrs rd, csr, x0 

    //write to CSR in offset 0x301 the value of 30
    int misa_csr_value = 30;
    asm volatile ("csrw 0x301, %0" : : "r" (misa_csr_value)); // pseudiInstr: csrw csr, rs. baseInst:  csrrw x0, csr, rs 

    //set bits in CSR in offset 0x009 the value 0x1b - should have the value of 0x1f
    asm volatile ("csrs 0x009, 0x1b");    // pseudoInst: csrsi csr, imm. baseInst: csrrsi x0, csr, imm
    
    //clear bits in CSR in offset 0x009 the value 0x4 - should have the value of 0x4
    asm volatile ("csrc 0x009, 0x1b");    // pseudoInst: csrci csr, imm. baseInst: csrrci x0, csr, imm

    //set CSR in offset 0x301 using value 63 - should have the value of 0x3f
    int set_misa_csr = 63;
     asm volatile ("csrs 0x301, %0" : : "r" (set_misa_csr)); // pseudiInstr: csrs csr, rs. baseInst: csrrs x0, csr, rs 

    //clear CSR in offset 0x301 using value 11 - should have the value of 0x14 (use only the first inst with misa)
    int clear_misa_csr = 11;
    asm volatile ("csrc 0x301, %0" : : "r" (clear_misa_csr)); // pseudiInstr: csrc csr, rs. baseInst: csrrc x0, csr, rs 
    return 0;
}  

