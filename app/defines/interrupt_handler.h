#include "big_core_defines.h"
#include "graphic_vga.h"
#include "csr.h"

// RISCV mcause exceptions defines for detection: 
#define ILLEGAL_INSTRUCTION_EXCEPTION     0x2
#define MACHINE_TIMER_INTERRUPT           0x80000007

#define TIMER_INTERRUPT_INTERVAL 0x00000FFF

void interrupt_handler() {

    unsigned int mcause = read_mcause(); // read the CSR register for mcause to determine the cause of the interrupt
    unsigned int csr_mepc, csr_mtval, csr_mstatus, mie_bit, mpie_bit, csr_mie, csr_mip;

    // For RISC-V, this value is 0x2 for illegal instruction
    if ((mcause & 0xFFF) == ILLEGAL_INSTRUCTION_EXCEPTION) { 
        csr_mepc = read_mepc();
        csr_mtval = read_mtval();
        rvc_printf("ILGL INST\n");
        rvc_printf("MEPC:");
        rvc_print_unsigned_int_hex(csr_mepc);
        rvc_printf("\n");
        rvc_printf("MTVAL:");
        rvc_print_unsigned_int_hex(csr_mtval);
        rvc_printf("\n");
       }

    // For RISC-V, this value is 0x80000007 for machine timer interrupt
    if (mcause == MACHINE_TIMER_INTERRUPT) {
        csr_mstatus  = read_mstatus();     
        mie_bit  = (csr_mstatus >> 3) & 0x1;                // read mie bit from mstatus. mie = mstatus[3]
        csr_mstatus = csr_mstatus & 0xFFFFFFF7;             // disable interrupts by setting mie bit to 0 in mstatus. 
        csr_mstatus = csr_mstatus || (mie_bit << 7);        // save mie bit into mpie bit mstatus. mpie = mstatus[7]
        write_mstatus(csr_mstatus);  

        // disable msie, mtie, meie bits in mie
        csr_mie = read_mie();                   
        csr_mie = csr_mie & 0xFFFFF777; 
        write_mie(csr_mie); 


        rvc_printf("TIMER_INTERRUPT\n");
        
        csr_mie = read_mie();
        csr_mie = csr_mie || 0x00000888;
        write_mie(csr_mie); // enable msie, mtie, meie bits in mie

        csr_mstatus  = read_mstatus();
        mpie_bit     = (csr_mstatus >> 7) & 0x1;   
        csr_mstatus  = csr_mstatus || (mpie_bit << 3);  // set mie bit to be equal to mpie
        csr_mstatus  = csr_mstatus & 0xFFFFFF7F;        // set mpie bit to 0
        write_mstatus(csr_mstatus);                     // write mstatus back

        csr_mip = 0;
        write_mip(csr_mip); // clear msip, mtip, meip bits in mip
        
        // update mtimecmp
        unsigned int csr_custom_mtime    = read_custom_mtime();
        unsigned int csr_custom_mtimecmp = read_custom_mtimecmp();
        
        csr_custom_mtimecmp = csr_custom_mtime + TIMER_INTERRUPT_INTERVAL; 
        write_custom_mtimecmp(csr_custom_mtimecmp);

        // update mstatus, mie and mpe



       }

}