//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : rvc_asap
//-----------------------------------------------------------------------------
// File             : rvc_asap_pkg.sv
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 11/2021
//-----------------------------------------------------------------------------
// Description :
// enum & parameters for the RVC core
//-----------------------------------------------------------------------------

package mini_core_pkg;

parameter I_MEM_MSB   = 'h4000-1;  // I_MEM   0x0    - 0x3FFF
parameter D_MEM_MSB   = 'h7000-1;  // D_MEM   0x4000 - 0x6FFF
parameter CR_MEM_MSB  = 'h8000-1;  // CR_MEM  0x7000 - 0x7FFF
parameter VGA_MEM_MSB = 'h11600-1; // VGA_MEM 0x8000 - 0x115FF

// Region bits
parameter LSB_REGION = 0;
parameter MSB_REGION = 15;

// VGA Region bits
parameter VGA_MSB_REGION = 19;

// Encoded regions
parameter I_MEM_REGION_FLOOR   = 'h0                    ;
parameter I_MEM_REGION_ROOF    = I_MEM_MSB              ;

parameter D_MEM_REGION_FLOOR   = I_MEM_REGION_ROOF  + 1 ;
parameter D_MEM_REGION_ROOF    = D_MEM_MSB              ;

parameter CR_MEM_REGION_FLOOR  = D_MEM_REGION_ROOF  + 1 ;
parameter CR_MEM_REGION_ROOF   = CR_MEM_MSB             ;

parameter VGA_MEM_REGION_FLOOR = CR_MEM_REGION_ROOF + 1 ;
parameter VGA_MEM_REGION_ROOF  = VGA_MEM_MSB            ;

// define data memory sizes
parameter SIZE_D_MEM       = D_MEM_REGION_ROOF - D_MEM_REGION_FLOOR + 1; 
parameter D_MEM_OFFSET     = 'h0040_0000;   // See D_MEM_REGION
parameter LSB_D_MEM        = 0 ;
parameter MSB_D_MEM        = 12;
parameter SIZE_D_MEM_LOTR      = 2**(MSB_D_MEM + 1);
parameter SIZE_SHRD_MEM    = 2**(MSB_D_MEM );
parameter T0_STK_OFFSET    = 32'h0040_1400;
parameter T1_STK_OFFSET    = 32'h0040_1800;
parameter T2_STK_OFFSET    = 32'h0040_1C00;
parameter T3_STK_OFFSET    = 32'h0040_2000;
parameter MEM_SHARD_OFFSET = 32'h0040_0f00;
// define VGA memory sizes
parameter SIZE_VGA_MEM       = 38400;



typedef enum logic [2:0] {
    U_TYPE = 3'b000 , 
    I_TYPE = 3'b001 ,  
    S_TYPE = 3'b010 ,     
    B_TYPE = 3'b011 , 
    J_TYPE = 3'b100 
} t_immediate ;

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
    AND  = 4'b0111
} t_alu_op ;

typedef enum logic [2:0] {
   BEQ  = 3'b000 ,
   BNE  = 3'b001 ,
   BLT  = 3'b100 ,
   BGE  = 3'b101 ,
   BLTU = 3'b110 ,
   BGEU = 3'b111
} t_branch_type ;

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

parameter NOP = 32'b000000000000000000000000010011; // addi x0 , x0 , 0

// CR Address Offsets
parameter CR_SEG7_0    = CR_MEM_REGION_FLOOR ; // RW 7 bit
parameter CR_SEG7_1    = CR_SEG7_0   + 4 ; // RW 7 bit
parameter CR_SEG7_2    = CR_SEG7_1   + 4 ; // RW 7 bit
parameter CR_SEG7_3    = CR_SEG7_2   + 4 ; // RW 7 bit
parameter CR_SEG7_4    = CR_SEG7_3   + 4 ; // RW 7 bit
parameter CR_SEG7_5    = CR_SEG7_4   + 4 ; // RW 7 bit
parameter CR_LED       = CR_SEG7_5   + 4 ; // RW 10 bit
parameter CR_Button_0  = CR_LED      + 4 ; // RO 1 bit
parameter CR_Button_1  = CR_Button_0 + 4 ; // RO 1 bit
parameter CR_Switch    = CR_Button_1 + 4 ; // RO 10 bit
parameter CR_CURSOR_H  = CR_Switch   + 4 ; // RW 32 bit
parameter CR_CURSOR_V  = CR_CURSOR_H + 4 ; // RW 32 bit

typedef struct packed { // RO
    logic       Button_0;
    logic       Button_1;
    logic [9:0] Switch;
} t_cr_ro ;

typedef struct packed { // RW
    logic [7:0]  SEG7_0;
    logic [7:0]  SEG7_1;
    logic [7:0]  SEG7_2;
    logic [7:0]  SEG7_3;
    logic [7:0]  SEG7_4;
    logic [7:0]  SEG7_5;
    logic [9:0]  LED;
    logic [31:0] CR_CURSOR_H;
    logic [31:0] CR_CURSOR_V;
} t_cr_rw ;


parameter I_MEM_SIZE   = 'h1000;
parameter I_MEM_OFFSET = 'h0;
parameter D_MEM_SIZE   = 'h1000;
parameter D_MEM_OFFSET = 'h1000;

//typedef enum logic [2:0] {
//    U_TYPE = 3'b000 , 
//    I_TYPE = 3'b001 ,  
//    S_TYPE = 3'b010 ,     
//    B_TYPE = 3'b011 , 
//    J_TYPE = 3'b100 
//} t_immediate ;
//
//typedef enum logic [3:0] {
//    ADD  = 4'b0000 ,
//    SUB  = 4'b1000 ,
//    SLT  = 4'b0010 ,
//    SLTU = 4'b0011 ,
//    SLL  = 4'b0001 , 
//    SRL  = 4'b0101 ,
//    SRA  = 4'b1101 ,
//    XOR  = 4'b0100 ,
//    OR   = 4'b0110 ,
//    AND  = 4'b0111 ,
//    IN_2 = 4'b1111
//} t_alu_op ;
//
//typedef enum logic [2:0] {
//   BEQ  = 3'b000 ,
//   BNE  = 3'b001 ,
//   BLT  = 3'b100 ,
//   BGE  = 3'b101 ,
//   BLTU = 3'b110 ,
//   BGEU = 3'b111
//} t_branch_type ;
//
//typedef enum logic [6:0] {
//   LUI    = 7'b0110111 ,
//   AUIPC  = 7'b0010111 ,
//   JAL    = 7'b1101111 ,
//   JALR   = 7'b1100111 ,
//   BRANCH = 7'b1100011 ,
//   LOAD   = 7'b0000011 ,
//   STORE  = 7'b0100011 ,
//   I_OP   = 7'b0010011 ,
//   R_OP   = 7'b0110011 ,
//   FENCE  = 7'b0001111 ,
//   SYSCAL = 7'b1110011
//} t_opcode ;


endpackage
