#include "big_core_defines.h"
#include "graphic_vga.h"
#include "csr.h"

// RISCV mcause exceptions defines for detection: 
#define ILLEGAL_INSTRUCTION_EXCEPTION     0x2
#define MACHINE_TIMER_INTERRUPT           0x80000007
#define TIMER_INTERRUPT_INTERVAL          0x0000100 

unsigned int COUNT_MACHINE_TIMER_INTRPT[1] = {0};

void mtime_routine_handler() {
        COUNT_MACHINE_TIMER_INTRPT[0]++;
}

void interrupt_handler() {

    unsigned int mcause = read_mcause(); // read the CSR register for mcause to determine the cause of the interrupt
    unsigned int csr_mepc, csr_mtval;

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
        
        //Run the mtime interrupt handler routine
        mtime_routine_handler();
        
        unsigned int csr_custom_mtime    = read_custom_mtime();
        unsigned int csr_custom_mtimecmp = read_custom_mtimecmp();
        
        csr_custom_mtimecmp = csr_custom_mtime + TIMER_INTERRUPT_INTERVAL; 
        write_custom_mtimecmp(csr_custom_mtimecmp);


       }

}
