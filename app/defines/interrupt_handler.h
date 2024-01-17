#include "big_core_defines.h"
#include "graphic_vga.h"
#include "csr.h"

// RISCV mcause exceptions defines for detection: 
#define ILLEGAL_INSTRUCTION_EXCEPTION     0x2

void interrupt_handler() {

    unsigned int mcause = read_mcause(); // read the CSR register for mcause to determine the cause of the interrupt
    unsigned int csr_mepc, csr_mtval;

    // For RISC-V, this value is 0x2 for illegal instruction
    if ((mcause & 0xFFF) == ILLEGAL_INSTRUCTION_EXCEPTION) {
        asm volatile ("csrr %0, 0x341" : "=r" (csr_mepc));
        asm volatile ("csrr %0, 0x343" : "=r" (csr_mtval)); 
        rvc_printf("ILGL INST\n");
        rvc_printf("MEPC:");
        rvc_print_unsigned_int_hex(csr_mepc);
        rvc_printf("\n");
        rvc_printf("MTVAL:");
        rvc_print_unsigned_int_hex(csr_mtval);
        rvc_printf("\n");
       }
}