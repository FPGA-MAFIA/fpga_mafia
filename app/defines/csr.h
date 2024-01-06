// CSR address for exception handler and interrupt handler
#define CSR_MCAUSE 0x342
#define CSR_MEPC   0x341
#define CSR_MTVAL  0x343
#define CSR_MSTATUS 0x300
#define CSR_MIE 0x304
#define CSR_MIP 0x344


int read_mcause() {

    int mcause;
    asm volatile ("csrr %0, CSR_MCAUSE" : "=r"(mcause));
    return mcause;

}

int read_mepc() {

    int mepc;
    asm volatile ("csrr %0, CSR_MEPC" : "=r"(mepc));
    return mepc;

}

int read_mtval() {

    int mtval;
    asm volatile ("csrr %0, CSR_MTVAL" : "=r"(mtval));
    return mtval;

}

int read_mstatus() {

    int mstatus;
    asm volatile ("csrr %0, CSR_MSTATUS" : "=r"(mstatus));
    return mstatus;

}

int read_mie() {

    int mie;
    asm volatile ("csrr %0, CSR_MIE" : "=r"(mie));
    return mie;

}

int read_mip() {

    int mip;
    asm volatile ("csrr %0, CSR_MIP" : "=r"(mip));
    return mip;

}