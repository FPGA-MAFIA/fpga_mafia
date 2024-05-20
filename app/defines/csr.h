
/*********************************************************
 * RISC-V Interrupts and Exceptions CSR read/write macros
**********************************************************/
#ifndef CSR_H
#define CSR_H

#define READ_CSR(reg) ({ unsigned int __val; asm volatile ("csrr %0, " #reg : "=r"(__val)); __val; })
#define WRITE_CSR(reg, val) asm volatile ("csrw " #reg ", %0" : : "r"(val))
#define SET_CSR_BITS(reg, mask) asm volatile ("csrrs zero, " #reg ", %0" : : "r"(mask))
#define CLEAR_CSR_BITS(reg, mask) asm volatile ("csrrc zero, " #reg ", %0" : : "r"(mask))
#define READ_CUSTOM_CSR(reg_addr) ({ unsigned int __val; asm volatile ("csrr %0, %1" : "=r"(__val) : "i"(reg_addr)); __val; })
#define WRITE_CUSTOM_CSR(reg_addr, val) asm volatile ("csrw %0, %1" : : "i"(reg_addr), "r"(val))

#define read_mcause()           READ_CSR(mcause)
#define read_mepc()             READ_CSR(mepc)
#define read_mtval()            READ_CSR(mtval)
#define read_mstatus()          READ_CSR(mstatus)
#define read_mie()              READ_CSR(mie)
#define read_mip()              READ_CSR(mip)
#define write_mcause(val)       WRITE_CSR(mcause, val)
#define write_mepc(val)         WRITE_CSR(mepc, val)
#define write_mtval(val)        WRITE_CSR(mtval, val)
#define write_mstatus(val)      WRITE_CSR(mstatus, val)
#define write_mie(val)          WRITE_CSR(mie, val)
#define write_mip(val)          WRITE_CSR(mip, val)
#define set_mie(mask)           SET_CSR_BITS(mie, mask)
#define clear_mie(mask)         CLEAR_CSR_BITS(mie, mask)
#define write_dscratch0(val)    WRITE_CSR(dscratch0, val)

#define read_custom_mtime() READ_CUSTOM_CSR(0xFC0)
#define read_custom_mtimecmp() READ_CUSTOM_CSR(0xBC0)
#define write_custom_mtimecmp(val) WRITE_CUSTOM_CSR(0xBC0, val)
#define read_custom_lfsr() READ_CUSTOM_CSR(0xBC1)
#define write_custom_lfsr(val) WRITE_CUSTOM_CSR(0xBC1, val)

#define extract_funct7(instruction) (((instruction) >> 25) & 0x7F)
#define extract_funct3(instruction) (((instruction) >> 12) & 0x07)
#define extract_opcode(instruction) ((instruction) & 0x7F)
#define extract_rs1(instruction) (((instruction) >> 15) & 0x1F)
#define extract_rs2(instruction) (((instruction) >> 20) & 0x1F)
#define extract_rd(instruction) (((instruction) >> 7) & 0x1F)


// sample relevant csr's for pmon
void rvc_sample_csr(int *cycle_low, int *instret_low){

    asm volatile ("csrr %0, 0xC00" : "=r" (*cycle_low)); 
    asm volatile ("csrr %0, 0xC02" : "=r" (*instret_low)); 

}


#endif /* CSR_H */