#include "big_core_defines.h"
#include "graphic_vga.h"
#include "csr.h"
#include "math.h"

// RISCV mcause exceptions defines for detection: 
#define ILLEGAL_INSTRUCTION_EXCEPTION     0x2
#define CUSTOM_MCAUSE_DIV_OPERATION       0xa 
#define MACHINE_TIMER_INTERRUPT           0x80000007
#define TIMER_INTERRUPT_INTERVAL          0x0000100 

unsigned int COUNT_MACHINE_TIMER_INTRPT[1] = {0};
unsigned int funct7, funct3;
unsigned int rs1_addr, rs2_addr, rd_addr;
int rs1_value, rs2_value;
unsigned int* stack_pointer;
int rd_value;

void mtime_routine_handler() {
        COUNT_MACHINE_TIMER_INTRPT[0]++;
}

void interrupt_handler() {

    unsigned int mcause = read_mcause(); // read the CSR register for mcause to determine the cause of the interrupt
    unsigned int csr_mepc, csr_mtval;

    // For RISC-V, this value is 0x2 for illegal instruction
    if ((mcause & 0xFFF) == ILLEGAL_INSTRUCTION_EXCEPTION) {
        csr_mepc  = read_mepc();
        csr_mtval = read_mtval();
        rvc_printf("ILGL INST\n");
        rvc_printf("MEPC:");
        rvc_print_unsigned_int_hex(csr_mepc);
        rvc_printf("\n");
        rvc_printf("MTVAL:");
        rvc_print_unsigned_int_hex(csr_mtval);
        rvc_printf("\n");
        }

    // execution of DIV, DIVU, REM, REMU
    // The mcause gets reserved value from the spec
    if (mcause == CUSTOM_MCAUSE_DIV_OPERATION){
        csr_mtval = read_mtval();
        funct7    = extract_funct7(csr_mtval);
        funct3    = extract_funct3(csr_mtval);
        // restore the rs1, rs2 values before entering the exception
        rs1_addr = extract_rs1(csr_mtval);
        rs2_addr = extract_rs2(csr_mtval);
        rd_addr  = extract_rd(csr_mtval);
        // restore the value of stack pointer before entering to interrupt handler
        stack_pointer = (unsigned int *)(READ_CUSTOM_CSR(0xBC2));

        // restore the values of rs1 and rs2 before entering the interrupt handler
        // for example we restore rs1 and rs2 in div rd, rs1, rs2;
        // reminder: assume stack_pointer = 0x100 and rs1_addr = 2
        // then in the following line rs1_value we will restored data from memory in address 100 - 2*4 
        rs1_value = *(stack_pointer - rs1_addr);
        rs2_value = *(stack_pointer - rs2_addr);

        if(funct7 == 0x1 && funct3 == 0x4) {   // DIV
                 rd_value = div(rs1_value, rs2_value);
                 // we want thar rd will contain the result if the instruction than
                 // we have to over write it with the rd stores in the stack at the beginning of the
                 // interupt handler. We have to read again the stack_pointer and than over write
                stack_pointer = (unsigned int *)(READ_CUSTOM_CSR(0xBC2));
                *(stack_pointer - rd_addr) = rd_value;
        }       
        else if(funct7 == 0x1 && funct3 == 0x5) {  // DIVU
                rd_value = divu(rs1_value, rs2_value);
                stack_pointer = (unsigned int *)(READ_CUSTOM_CSR(0xBC2));
                *(stack_pointer - rd_addr) = rd_value;
        }
        else if(funct7 == 0x1 && funct3 == 0x6) {  // REM
                rd_value = rem(rs1_value, rs2_value);
                stack_pointer = (unsigned int *)(READ_CUSTOM_CSR(0xBC2));
                *(stack_pointer - rd_addr) = rd_value;
        }
        else if(funct7 == 0x1 && funct3 == 0x7) {  // REMU
                rd_value = remu(rs1_value, rs2_value);
                stack_pointer = (unsigned int *)(READ_CUSTOM_CSR(0xBC2));
                *(stack_pointer - rd_addr) = rd_value;
        }
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
