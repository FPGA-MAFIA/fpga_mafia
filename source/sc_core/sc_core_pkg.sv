//-----------------------------------------------------------------------------
// Title            : 
// Project          : 
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : 
// Code Owner       : 
// Created          : 11/2022
//-----------------------------------------------------------------------------
// Description :
// 
//-----------------------------------------------------------------------------



`ifndef SC_CORE_PKG_SV
`define SC_CORE_PKG_SV
package sc_core_pkg;
    
`include "common_pkg.vh"


parameter I_MEM_SIZE   = 'h1_0000; 
parameter I_MEM_OFFSET = 'h0_0000;
parameter D_MEM_SIZE   = 'h1_0000;
parameter D_MEM_OFFSET = 'h1_0000;


parameter I_MEM_MSB     = I_MEM_SIZE-1;               // I_MEM   0x0    - 0x3FFF
parameter D_MEM_MSB     = D_MEM_SIZE+D_MEM_OFFSET-1;  // D_MEM   0x4000 - 0x6FFF
parameter CR_MEM_MSB    = 'h5000-1;                   // CR_MEM  0x7000 - 0x7FFF
// Region bits
parameter LSB_REGION = 0;
parameter MSB_REGION = 15;

// define VGA memory sizes and region bits
parameter SIZE_VGA_MEM          = 38400; 
parameter VGA_MEM_REGION_FLOOR  = 32'h00FF_0000;
parameter VGA_MEM_REGION_ROOF   = VGA_MEM_REGION_FLOOR + SIZE_VGA_MEM - 1;

// Encoded regions
parameter I_MEM_REGION_FLOOR   = 'h0                    ;
parameter I_MEM_REGION_ROOF    = I_MEM_MSB              ;

parameter D_MEM_REGION_FLOOR   = I_MEM_REGION_ROOF  + 1 ;
parameter D_MEM_REGION_ROOF    = D_MEM_MSB              ;

parameter CR_MEM_REGION_FLOOR  = D_MEM_REGION_ROOF  + 1 ;
parameter CR_MEM_REGION_ROOF   = CR_MEM_MSB             ;

// define data memory sizes
parameter SIZE_D_MEM       = D_MEM_REGION_ROOF - D_MEM_REGION_FLOOR + 1; 


parameter EBREAK = 32'b00000000000100000000000001110011 ;
parameter NOP    = 32'b00000000000000000000000000010011; // addi x0 , x0 , 0

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


endpackage

`endif //SC_CORE_PKG_SV
