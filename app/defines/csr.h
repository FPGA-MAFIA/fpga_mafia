/*******************************************************
 * RISC-V Interrupts and Exceptions CSR read functions
*******************************************************/
#ifndef CSR_H
#define READ_CSR(reg) ({ int __val; asm volatile ("csrr %0, " #reg : "=r"(__val)); __val; })

#define read_mcause()   READ_CSR(mcause)
#define read_mepc()     READ_CSR(mepc)
#define read_mtval()    READ_CSR(mtval)
#define read_mstatus()  READ_CSR(mstatus)
#define read_mie()      READ_CSR(mie)
#define read_mip()      READ_CSR(mip)

#endif /* CSR_H */