#include "big_core_defines.h"
#include "graphic_vga.h"
#include "csr.h"


void interrupt_handler() {

    int mcause = read_mcause(); // read the CSR register for mcause to determine the cause of the interrupt

    // For RISC-V, this value is 0x2 for illegal instruction
    const int ILLEGAL_INSTRUCTION_EXCEPTION = 0x2;

    if ((mcause & 0xFFF) == ILLEGAL_INSTRUCTION_EXCEPTION) {
        rvc_printf("ILLEGAL_INSTRUCTION\n");
    }
}