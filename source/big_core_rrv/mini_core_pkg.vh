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

//instead of importing the riscv_pkg, include this file in the common_pkg
//package mini_core_pkg;
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


typedef enum logic [1:0] {
    WB_DMEM = 2'b00 , 
    WB_ALU =  2'b01 ,  
    WB_PC4 =  2'b10      
} t_e_sel_wb;

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
    logic [4:0] RegDstQ105H;
    logic       RegWrEnQ105H;
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
} t_ctrl_mem1;



typedef struct packed {
    logic [3:0] ByteEnQ105H;
    logic [3:0] SignExtQ105H;
    t_e_sel_wb    e_SelWrBackQ105H;
} t_ctrl_wb;

typedef struct packed {
    logic [31:0] WrData;
    logic [31:0] Address; 
    logic       WrEn;  
    logic       RdEn;  
    logic [3:0] ByteEn;
} t_core2mem_req;


//endpackage
