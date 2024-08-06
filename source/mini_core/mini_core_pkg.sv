//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : mafia_asap_pkg.sv
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 11/2021
//-----------------------------------------------------------------------------
// Description :
// enum & parameters for the MAFIA core
//-----------------------------------------------------------------------------

package mini_core_pkg;

`include "common_pkg.vh"

parameter I_MEM_SIZE_MINI   = 'h1_0000; //FIXME - currently using same as BIG_CORE
parameter I_MEM_OFFSET_MINI = 'h0_0000;
parameter D_MEM_SIZE_MINI   = 'h1_0000;
parameter D_MEM_OFFSET_MINI = 'h1_0000;

parameter I_MEM_MSB_MINI   = I_MEM_SIZE_MINI-1;               // I_MEM   0x0    - 0x3FFF
parameter D_MEM_MSB_MINI   = D_MEM_SIZE_MINI+D_MEM_OFFSET_MINI-1;  // D_MEM   0x4000 - 0x6FFF

parameter I_MEM_ADRS_MSB_MINI = 15;
parameter D_MEM_ADRS_MSB_MINI = 15;

// Region bits
parameter LSB_REGION_MINI = 0;
parameter MSB_REGION_MINI = 17;

// Encoded regions
parameter I_MEM_REGION_FLOOR_MINI   = 'h0;
parameter I_MEM_REGION_ROOF_MINI    = I_MEM_MSB_MINI;

parameter D_MEM_REGION_FLOOR_MINI   = I_MEM_REGION_ROOF_MINI  + 1;
parameter D_MEM_REGION_ROOF_MINI    = D_MEM_MSB_MINI             ;

parameter NOP = 32'b000000000000000000000000010011; // addi x0 , x0 , 0

typedef enum logic [1:0] {
    WB_DMEM = 2'b00 , 
    WB_ALU =  2'b01 ,  
    WB_PC4 =  2'b10      
} t_e_sel_wb;

typedef enum logic [2:0] {
   BEQ  = 3'b000 ,
   BNE  = 3'b001 ,
   BLT  = 3'b100 ,
   BGE  = 3'b101 ,
   BLTU = 3'b110 ,
   BGEU = 3'b111
} t_branch_type ;

typedef enum logic [3:0] {
    ADD  = 4'b0000 ,
    SUB  = 4'b1000 ,
    SLT  = 4'b0010 ,
    SLTU = 4'b0011 ,
    SLL  = 4'b0001 , 
    SRL  = 4'b0101 ,
    SRA  = 4'b1101 ,
    XOR  = 4'b0100 ,
    OR   = 4'b0110 ,
    AND  = 4'b0111 ,
    IN_2 = 4'b1111
} t_alu_op ;

typedef enum logic [6:0] {
   LUI    = 7'b0110111 ,
   AUIPC  = 7'b0010111 ,
   JAL    = 7'b1101111 ,
   JALR   = 7'b1100111 ,
   BRANCH = 7'b1100011 ,
   LOAD   = 7'b0000011 ,
   STORE  = 7'b0100011 ,
   I_OP   = 7'b0010011 ,
   R_OP   = 7'b0110011 ,
   FENCE  = 7'b0001111 ,
   SYSCAL = 7'b1110011
} t_opcode ;

typedef enum logic [2:0] {
    U_TYPE = 3'b000 , 
    I_TYPE = 3'b001 ,  
    S_TYPE = 3'b010 ,     
    B_TYPE = 3'b011 , 
    J_TYPE = 3'b100 
} t_immediate ;

typedef struct packed {
    logic       SelNextPcAluOutJ;
    logic       SelNextPcAluOutB;
    logic       SelRegWrPc;
    logic       SelAluPc;
    logic       SelAluImm;
    logic       SelDMemWb;
    logic       Lui;
    logic       RegWrEn;
    logic       DMemWrEn;
    logic       DMemRdEn;
    logic       SignExt;
    logic [3:0] DMemByteEn;
    t_branch_type BranchOp;
    logic [4:0] RegDst;
    logic [4:0] RegSrc1;
    logic [4:0] RegSrc2;
    t_alu_op    AluOp;
    t_opcode    Opcode;
    t_e_sel_wb  e_SelWrBack;
    logic [31:0] Pc;            //Used for debug - not really a control signal
    logic [31:0] Instruction;   //Used for debug - not really a control signal
} t_mini_ctrl;

typedef struct packed {
    logic SelNextPcAluOutQ102H;
} t_ctrl_if;

typedef struct packed {
    logic [4:0] RegSrc1Q101H;
    logic [4:0] RegSrc2Q101H;
    logic [4:0] RegDstQ104H;
    logic       RegWrEnQ104H;
} t_ctrl_rf;

typedef struct packed {
    logic [4:0] RegSrc1Q102H;
    logic [4:0] RegSrc2Q102H;
    t_alu_op    AluOpQ102H;
    logic       LuiQ102H;
    t_branch_type BranchOpQ102H;
    logic [4:0] RegDstQ103H;
    logic [4:0] RegDstQ104H;
    logic       RegWrEnQ103H;
    logic       RegWrEnQ104H;
    logic       SelAluPcQ102H;
    logic       SelAluImmQ102H;
} t_ctrl_exe;

typedef struct packed {
    logic       DMemWrEnQ103H;  
    logic       DMemRdEnQ103H;  
    logic [3:0] DMemByteEnQ103H;
} t_ctrl_mem;



typedef struct packed {
    logic [3:0] ByteEnQ104H;
    logic [3:0] SignExtQ104H;
    t_e_sel_wb    e_SelWrBackQ104H;
} t_ctrl_wb;

typedef struct packed {
    logic [31:0] WrData;
    logic [31:0] Address; 
    logic       WrEn;  
    logic       RdEn;  
    logic [3:0] ByteEn;
} t_core2mem_req;

parameter WIDTH = 8;
typedef struct packed {
    logic [2*WIDTH:0] AQQ_0;
    logic [WIDTH-1:0] Mu;
} stage_mul_inp_t;

endpackage

