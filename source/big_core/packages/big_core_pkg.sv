//-----------------------------------------------------------------------------
// Title            : big_core_pkg 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : big_core_pkg.sv
// Original Author  :  
// Code Owner       : Amichai Ben-David
// Created          : 12/2023
//-----------------------------------------------------------------------------
// Description :
// enum & parameters for the MAFIA big_core
//-----------------------------------------------------------------------------

package big_core_pkg;

`include "big_core_csr_pkg.vh"
`include "big_core_ips_pkg.vh"
`include "big_core_fab_pkg.vh"

parameter I_MEM_SIZE   = 'h1_0000; 
parameter I_MEM_OFFSET = 'h0_0000;
parameter D_MEM_SIZE   = 'h1_0000;
parameter D_MEM_OFFSET = 'h1_0000;

parameter I_MEM_MSB  = I_MEM_SIZE-1;               // I_MEM
parameter D_MEM_MSB  = D_MEM_SIZE+D_MEM_OFFSET-1;  // D_MEM

parameter I_MEM_ADRS_MSB = 15;
parameter D_MEM_ADRS_MSB = 15;

// Region bits
parameter LSB_REGION = 0;
parameter MSB_REGION = 23;

// Encoded regions
parameter I_MEM_REGION_FLOOR   = 'h0;
parameter I_MEM_REGION_ROOF    = I_MEM_MSB;

parameter D_MEM_REGION_FLOOR  = I_MEM_REGION_ROOF  + 1;
parameter D_MEM_REGION_ROOF   = D_MEM_MSB             ;

// VGA Region bits
parameter VGA_MSB_REGION = 23;

// define VGA memory sizes
parameter SIZE_VGA_MEM          = 38400; 
parameter VGA_MEM_REGION_FLOOR  = 32'h00FF_0000;
parameter VGA_MEM_REGION_ROOF   = VGA_MEM_REGION_FLOOR + SIZE_VGA_MEM - 1;

// define CR memory sizes
parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR = CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 - 1;

// CR Address Offsets
parameter CR_SEG7_0      = CR_MEM_OFFSET + 'h0  ; // RW 8 bit
parameter CR_SEG7_1      = CR_MEM_OFFSET + 'h4  ; // RW 8 bit
parameter CR_SEG7_2      = CR_MEM_OFFSET + 'h8  ; // RW 8 bit
parameter CR_SEG7_3      = CR_MEM_OFFSET + 'hC  ; // RW 8 bit
parameter CR_SEG7_4      = CR_MEM_OFFSET + 'h10 ; // RW 8 bit
parameter CR_SEG7_5      = CR_MEM_OFFSET + 'h14 ; // RW 8 bit
parameter CR_LED         = CR_MEM_OFFSET + 'h18 ; // RW 10 bit
parameter CR_Button_0    = CR_MEM_OFFSET + 'h1C ; // RO 1 bit
parameter CR_Button_1    = CR_MEM_OFFSET + 'h20 ; // RO 1 bit
parameter CR_SWITCH      = CR_MEM_OFFSET + 'h24 ; // RO 10 bit
parameter CR_JOYSTICK_X  = CR_MEM_OFFSET + 'h28 ; // RO 10 bit
parameter CR_JOYSTICK_Y  = CR_MEM_OFFSET + 'h2C ; // RO 10 bit

// VGA contreol Address Offsets
parameter CR_VGA_CounterX= CR_MEM_OFFSET + 'h50 ; // RO 10 bit
parameter CR_VGA_CounterY= CR_MEM_OFFSET + 'h54 ; // RO 10 bit

// Keyboard control & data Address Offsets
parameter CR_KBD_DATA     = CR_MEM_OFFSET + 'h100 ; // RO 8 bit
parameter CR_KBD_READY    = CR_MEM_OFFSET + 'h104 ; // RO 1 bit
parameter CR_KBD_SCANF_EN = CR_MEM_OFFSET + 'h108 ; // RW 1 bit


parameter NOP = 32'b000000000000000000000000010011; // addi x0 , x0 , 0

//-----------------------------------
//      core rrv structs
//-----------------------------------
typedef enum logic [1:0] {
    WB_DMEM = 2'b00 , 
    WB_ALU =  2'b01 ,  
    WB_PC4 =  2'b10      
} t_e_sel_wb;

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

typedef enum logic [2:0] {
   BEQ  = 3'b000 ,
   BNE  = 3'b001 ,
   BLT  = 3'b100 ,
   BGE  = 3'b101 ,
   BLTU = 3'b110 ,
   BGEU = 3'b111
} t_branch_type;

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
} t_big_core_ctrl;

typedef struct packed {
    logic [4:0] RegSrc1Q102H;
    logic [4:0] RegSrc2Q102H;
    t_alu_op    AluOpQ102H;
    logic       LuiQ102H;
    t_branch_type BranchOpQ102H;
    logic [4:0] RegDstQ103H;
    logic [4:0] RegDstQ104H;
    logic [4:0] RegDstQ105H;
    logic       RegWrEnQ103H;
    logic       RegWrEnQ104H;
    logic       RegWrEnQ105H;
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

typedef enum logic [2:0] {
    U_TYPE = 3'b000 , 
    I_TYPE = 3'b001 ,  
    S_TYPE = 3'b010 ,     
    B_TYPE = 3'b011 , 
    J_TYPE = 3'b100 
} t_immediate ;

//-----------------------------------
//         fpga structs 
//-----------------------------------
typedef struct packed {
    logic           Button_0;
    logic           Button_1;
    logic [9:0]     Switch;
    logic [11:0]    Joystick_x;
    logic [11:0]    Joystick_y;
} t_fpga_in;

typedef struct packed {
    logic [7:0] SEG7_0;
    logic [7:0] SEG7_1;
    logic [7:0] SEG7_2;
    logic [7:0] SEG7_3;
    logic [7:0] SEG7_4;
    logic [7:0] SEG7_5;
    logic [9:0] LED;
} t_fpga_out;

typedef struct packed {
    logic [9:0]  VGA_CounterX;
    logic [9:0]  VGA_CounterY;
} t_cr;

endpackage
