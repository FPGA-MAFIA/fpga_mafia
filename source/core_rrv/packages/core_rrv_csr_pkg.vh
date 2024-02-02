//-----------------------------------------------------------------------------
// Title            : core_rrv_csr_pkg 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : core_rrv_csr_pkg.sv
// Original Author  :  
// Code Owner       : Amichai Ben-David
// Created          : 12/2023
//-----------------------------------------------------------------------------
// Description :
// CSR structs and Interrupt 
//-----------------------------------------------------------------------------

typedef enum logic [2:0] {
  CRSRW   = 3'b001 ,
  CRSRS   = 3'b010 ,
  CRSRC   = 3'b011 ,
  CRSRWI  = 3'b101 ,
  CRSRSI  = 3'b110 ,
  CRSRCI  = 3'b111
} t_funct3_csr ;

typedef struct packed {
    logic        csr_wren;
    logic        csr_rden;
    logic [1:0]  csr_op;
    logic [4:0]  csr_rs1;
    logic [11:0] csr_addr;
    logic [31:0] csr_data_imm;     
    logic        csr_imm_bit;
} t_csr_inst_rrv;


typedef enum logic [11:0] {
//User CSR - 
 CSR_CYCLE         = 12'hC00 ,
 CSR_CYCLEH        = 12'hC80 ,
 CSR_INSTRET       = 12'hC02 ,
 CSR_INSTRETH      = 12'hC82 ,
//Machine CSR -  
 CSR_MCYCLE          = 12'hB00 ,
 CSR_MCYCLEH         = 12'hB80 ,
 CSR_MINSTRET        = 12'hB02 ,
 CSR_MINSTRETH       = 12'hB82 ,
 CSR_MHPMCOUNTER3    = 12'hB03 ,
 CSR_MHPMCOUNTER3H   = 12'hB83 ,
 CSR_MHPMCOUNTER4    = 12'hB04 ,
 CSR_MHPMCOUNTER4H   = 12'hB84 ,
 CSR_MCOUNTINHIBIT   = 12'h320 ,
 CSR_MHPMEVENT3      = 12'h323 ,
 CSR_MHPMEVENT4      = 12'h324 ,
 CSR_MVENDORID       = 12'hF11 ,
 CSR_MARCHID         = 12'hF12 ,
 CSR_MIMPID          = 12'hF13 ,
 CSR_MHARTID         = 12'hF14 ,
 CSR_MCONFIGPTR      = 12'hF15 ,
 CSR_MSTATUS         = 12'h300 ,
 CSR_MSTATUSH        = 12'h310 ,
 CSR_MISA            = 12'h301 ,
 CSR_MEDELEG         = 12'h302 ,
 CSR_MIDELEG         = 12'h303 ,
 CSR_MIE             = 12'h304 ,
 CSR_MTVEC           = 12'h305 ,
 CSR_MCOUNTERN       = 12'h306 ,
 CSR_MSCRATCH        = 12'h340 ,
 CSR_MEPC            = 12'h341 ,
 CSR_MCAUSE          = 12'h342 ,
 CSR_MTVAL           = 12'h343 ,
 CSR_MIP             = 12'h344 ,
 CSR_MTINST          = 12'h34A ,
 CSR_MTVAL2          = 12'h34B,
 //Custom csr's for mtime, mtimecmp
 CSR_CUSTOM_MTIME    = 12'hFC0,
 CSR_CUSTOM_MTIMECMP = 12'hBC0
} t_csr_addr ;

typedef struct packed {
    logic illegal_instruction;
    logic misaligned_access;
    logic illegal_csr_access;
    logic breakpoint;
    logic timer_interrupt_taken;  
    logic external_interrupt;
    logic Mret;
    logic [31:0] mtval_instruction;
    logic [31:0] csr_mip;
    logic [31:0] Pc; 
} t_csr_interrupt_update;

typedef struct packed {
    logic        InterruptJumpEnQ102H;
    logic [31:0] InterruptJumpAddressQ102H;
    logic        InteruptReturnEnQ102H;
    logic [31:0] InteruptReturnAddressQ102H; 
} t_csr_pc_update;

typedef struct packed {
    logic [31:0] csr_cycle;
    logic [31:0] csr_cycleh;
    logic [31:0] csr_instret;
    logic [31:0] csr_instreth;
    logic [31:0] csr_mcycle;
    logic [31:0] csr_minstret;
    logic [31:0] csr_mhpmcounter3;
    logic [31:0] csr_mhpmcounter4;
    logic [31:0] csr_mcycleh;
    logic [31:0] csr_minstreth;
    logic [31:0] csr_mhpmcounter3h;
    logic [31:0] csr_mhpmcounter4h;
    logic [31:0] csr_mcountinhibit;
    logic [31:0] csr_mhpmevent3;
    logic [31:0] csr_mhpmevent4;
    logic [31:0] csr_mvendorid;
    logic [31:0] csr_marchid;
    logic [31:0] csr_mimpid;
    logic [31:0] csr_mhartid;
    logic [31:0] csr_mconfigptr;
    logic [31:0] csr_mstatus;
    logic [31:0] csr_misa;
    logic [31:0] csr_medeleg;
    logic [31:0] csr_mideleg;
    logic [31:0] csr_mie;
    logic [31:0] csr_mtvec;
    logic [31:0] csr_mcountern;
    logic [31:0] csr_mstatush;
    logic [31:0] csr_mscratch;
    logic [31:0] csr_mepc;
    logic [31:0] csr_mcause;
    logic [31:0] csr_mtval;
    logic [31:0] csr_mip;
    logic [31:0] csr_mtinst;
    logic [31:0] csr_mtval2;
    logic [31:0] csr_custom_mtime;
    logic [31:0] csr_custom_mtimecmp;
} t_csr;

typedef struct packed {
    logic RopFunct7NotMatchZero;
    logic RopFunct7NotMatch20OrZero;
    logic IopFunct7NotMatch20OrZero;
    logic StoreFunct3NotMatch;
    logic LoadFunct3NotMatch;
    logic BranchFunct3NotMatch;
    logic JalrFunct3NotMatch;
    logic OpCodeNotMatchBaseISA;
    logic RegOutOfRangeRV32E;
} t_illegal_instruction;

typedef enum logic [2:0] {  
   SB_  = 3'b000 ,
   SH_  = 3'b001 ,
   SW_  = 3'b010
} t_funct3_store_type;

typedef enum logic [2:0] {  
   LB_  = 3'b000 ,
   LH_  = 3'b001 ,
   LW_  = 3'b010 ,
   LBU_ = 3'b011 ,
   LBH_ = 3'b100
} t_funct3_load_type;

typedef enum logic [2:0] {  
    ADD_  = 3'b000 ,
    SLL_  = 3'b001 ,
    SLT_  = 3'b010 ,
    SLTU_ = 3'b011 ,
    XOR_  = 3'b100 , 
    SRL_  = 3'b101 , 
    OR_   = 3'b110 , 
    AND_  = 3'b111
} t_funct3_Rtype;