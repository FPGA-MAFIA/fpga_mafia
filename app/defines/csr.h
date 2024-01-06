/*******************************************************
 * RISC-V Interrupts and Exceptions CSR read functions
*******************************************************/
int read_mcause() {

    int mcause;
    asm volatile ("csrr %0, mcause" : "=r"(mcause));
    return mcause;

}

int read_mepc() {

    int mepc;
    asm volatile ("csrr %0, mepc" : "=r"(mepc));
    return mepc;

}

int read_mtval() {

    int mtval;
    asm volatile ("csrr %0, mtval" : "=r"(mtval));
    return mtval;

}

int read_mstatus() {

    int mstatus;
    asm volatile ("csrr %0, mstatus" : "=r"(mstatus));
    return mstatus;

}

int read_mie() {

    int mie;
    asm volatile ("csrr %0, mie" : "=r"(mie));
    return mie;

}

int read_mip() {

    int mip;
    asm volatile ("csrr %0, mip" : "=r"(mip));
    return mip;

}