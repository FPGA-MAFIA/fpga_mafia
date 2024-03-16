
package rv32i_ref_pkg;

`include "common_pkg.vh"


typedef enum logic [5:0] {
    I_NULL  = 6'd0,
    LUI   = 6'd1,
    AUIPC = 6'd2,
    JAL   = 6'd3,
    JALR  = 6'd4,
    BEQ   = 6'd5,
    BNE   = 6'd6,
    BLT   = 6'd7,
    BGE   = 6'd8,
    BLTU  = 6'd9,
    BGEU  = 6'd10,
    LB    = 6'd11,
    LH    = 6'd12,
    LW    = 6'd13,
    LBU   = 6'd14,
    LHU   = 6'd15,
    SB    = 6'd16,
    SH    = 6'd17,
    SW    = 6'd18,
    ADDI  = 6'd19,
    SLTI  = 6'd20,
    SLTIU = 6'd21,
    XORI  = 6'd22,
    ORI   = 6'd23,
    ANDI  = 6'd24,
    SLLI  = 6'd25,
    SRLI  = 6'd26,
    SRAI  = 6'd27,
    ADD   = 6'd28,
    SUB   = 6'd29,
    SLL   = 6'd30,
    SLT   = 6'd31,
    SLTU  = 6'd32,
    XOR   = 6'd33,
    SRL   = 6'd34,
    SRA   = 6'd35,
    OR    = 6'd36,
    AND   = 6'd37,
    FENCE = 6'd38,
    ECALL = 6'd39,
    EBREAK= 6'd40,
    MRET  = 6'd41,
    CSRRW = 6'd42,
    CSRRS = 6'd43,
    CSRRC = 6'd44,
    CSRRWI= 6'd45,
    CSRRSI= 6'd46,
    CSRRCI= 6'd47
  } t_rv32i_instr;

// csr registers
typedef enum logic [11:0] {
//User CSR - 
 CSR_CYCLE         = 12'hC00 ,
 CSR_CYCLEH        = 12'hC80 ,
 CSR_INSTRET       = 12'hC02 ,
 CSR_INSTRETH      = 12'hC82 ,
//Machine CSR -  
 CSR_MCYCLE         = 12'hB00 ,
 CSR_MCYCLEH        = 12'hB80 ,
 CSR_MINSTRET       = 12'hB02 ,
 CSR_MINSTRETH      = 12'hB82 ,
 CSR_MHPMCOUNTER3   = 12'hB03 ,
 CSR_MHPMCOUNTER3H  = 12'hB83 ,
 CSR_MHPMCOUNTER4   = 12'hB04 ,
 CSR_MHPMCOUNTER4H  = 12'hB84 ,
 CSR_MCOUNTINHIBIT  = 12'h320 ,
 CSR_MHPMEVENT3     = 12'h323 ,
 CSR_MHPMEVENT4     = 12'h324 ,
 CSR_MVENDORID      = 12'hF11 ,
 CSR_MARCHID        = 12'hF12 ,
 CSR_MIMPID         = 12'hF13 ,
 CSR_MHARTID        = 12'hF14 ,
 CSR_MCONFIGPTR     = 12'hF15 ,
 CSR_MSTATUS        = 12'h300 ,
 CSR_MSTATUSH       = 12'h310 ,
 CSR_MISA           = 12'h301 ,
 CSR_MEDELEG        = 12'h302 ,
 CSR_MIDELEG        = 12'h303 ,
 CSR_MIE            = 12'h304 ,
 CSR_MTVEC          = 12'h305 ,
 CSR_MCOUNTERN      = 12'h306 ,
 CSR_MSCRATCH       = 12'h340 ,
 CSR_MEPC           = 12'h341 ,
 CSR_MCAUSE         = 12'h342 ,
 CSR_MTVAL          = 12'h343 ,
 CSR_MIP            = 12'h344 ,
 CSR_MTINST         = 12'h34A ,
 CSR_MTVAL2         = 12'h34B,
 //Custom csr's for mtime, mtimecmp
 CSR_CUSTOM_MTIME    = 12'hFC0,
 CSR_CUSTOM_MTIMECMP = 12'hBC0,
 //Custom csr used for LFSR 
 CSR_CUSTOM_LFSR     = 12'hBC1,
 //debug csr's
 CSR_DCSR            = 12'h7B0,
 CSR_DPC             = 12'h7B1,
 CSR_DSCRATCH0       = 12'h7B2,
 CSR_DSCRATCH1       = 12'h7B3 
} t_csr_addr ;

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
    logic [31:0] csr_custom_lfsr;
    logic [31:0] csr_dcsr;
    logic [31:0] csr_dpc;
    logic [31:0] csr_dscratch0;
    logic [31:0] csr_dscratch1;
} t_csr;

//systemverilog packed struct for debugging
typedef struct packed {
    logic        clk;
    logic [31:0] pc;
    logic [31:0] instruction;
    t_rv32i_instr instr_type;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [31:0] mem_rd_addr;
    logic [31:0] mem_wr_addr;
    logic [31:0] data_rd1;
    logic [31:0] data_rd2;
    logic [31:0] reg_wr_data;
} t_debug_info;

endpackage