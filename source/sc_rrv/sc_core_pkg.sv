//-----------------------------------------------------------------------------
// Title            : simple core design
// Project          : single cycle core
//-----------------------------------------------------------------------------
// File             : sc_core_pkg
// Original Author  : Roman Gilgor
// Code Owner       : 
// Created          : 10/2023
//-----------------------------------------------------------------------------
// Description :
// This file will be a macro's file for single cycle core implemenation of the RV32I RISCV
// specification
//-----------------------------------------------------------------------------

`ifndef SC_CORE_PKG_SV
`define SC_CORE_PKG_SV

 package sc_core_pkg;
 
 parameter I_MEM_SIZE   = 65536;
 parameter I_MEM_OFFSET = 0;
 parameter D_MEM_SIZE   = 65536;
 parameter D_MEM_OFFSET = 61440;
  
  
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

typedef enum logic [2:0] {
    U_TYPE = 3'b000 , 
    I_TYPE = 3'b001 ,  
    S_TYPE = 3'b010 ,     
    B_TYPE = 3'b011 , 
    J_TYPE = 3'b100 
} t_immediate ;




 endpackage

`endif
