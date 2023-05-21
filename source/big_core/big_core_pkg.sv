//-----------------------------------------------------------------------------
// Title            : 7 pipes core  design
// Project          : big_core
//-----------------------------------------------------------------------------
// File             : big_core
// Original Author  : Daniel Kaufman
// Code Owner       : 
// Created          : 11/2022
//-----------------------------------------------------------------------------
// Description :
//-----------------------------------------------------------------------------



`ifndef BIG_CORE_PKG_VS
`define BIG_CORE_PKG_VS
package big_core_pkg;
    


parameter I_MEM_SIZE   = 'h1_0000;
parameter I_MEM_OFFSET = 'h0_0000;
parameter D_MEM_SIZE   = 'h1_0000;
parameter D_MEM_OFFSET = 'h1_0000;

parameter I_MEM_MSB   = I_MEM_SIZE-1;               
parameter D_MEM_MSB   = D_MEM_SIZE+D_MEM_OFFSET-1;  
// Region bits
parameter LSB_REGION = 0;
parameter MSB_REGION = 23;

// VGA Region bits
parameter VGA_MSB_REGION = 23;

// Encoded regions
parameter I_MEM_REGION_FLOOR   = 'h0;
parameter I_MEM_REGION_ROOF    = I_MEM_MSB;

parameter D_MEM_REGION_FLOOR   = D_MEM_OFFSET;
parameter D_MEM_REGION_ROOF    = D_MEM_OFFSET +  D_MEM_SIZE - 1;

parameter CR_MEM_OFFSET       = 'h00FE_0000;
parameter CR_MEM_REGION_FLOOR = CR_MEM_OFFSET;
parameter CR_MEM_REGION_ROOF  = 'h00FF_0000 -4;


// define VGA memory sizes
parameter SIZE_VGA_MEM          = 38400; 
parameter VGA_MEM_REGION_FLOOR  = 32'h00FF_0000;
parameter VGA_MEM_REGION_ROOF   = VGA_MEM_REGION_FLOOR + SIZE_VGA_MEM - 1;

parameter NOP = 32'b000000000000000000000000010011; // addi x0 , x0 , 0

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

typedef enum logic [2:0] {
  CRSRW   = 3'b001 ,
  CRSRS   = 3'b010 ,
  CRSRC   = 3'b011 ,
  CRSRWI  = 3'b101 ,
  CRSRSI  = 3'b110 ,
  CRSRCI  = 3'b111
} t_funct3_csr ;

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
    logic        csr_wren;
    logic        csr_rden;
    logic [1:0]  csr_op;
    logic [4:0]  csr_rs1;
    logic [11:0] csr_addr;
    logic [31:0] csr_data;
} t_csr_inst;

typedef enum logic [11:0] {
 CSR_SCRATCH   = 12'h009 ,
 CSR_CYCLE_LOW = 12'hC00 ,
 CSR_CYCLE_HIGH= 12'hC80 ,
 CSR_MCAUSE    = 12'h342
} t_csr_addr ;

typedef struct packed {
    logic illegal_instruction;
    logic misaligned_access;
    logic illegal_csr_access;
    logic breakpoint;
    logic timer_interrupt;  
    logic external_interrupt;
} t_csr_hw_updt;

typedef struct packed {
    logic [31:0] csr_scratch;
    logic [31:0] csr_cycle_low;
    logic [31:0] csr_cycle_high;
    logic [31:0] csr_mcause;
} t_csr;

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
    logic [3:0] VGA_R;
    logic [3:0] VGA_G;
    logic [3:0] VGA_B;
    logic       VGA_VS;
    logic       VGA_HS;
} t_vga_out;


// CR Address Offsets
parameter CR_SEG7_0    = CR_MEM_OFFSET + 'h0  ; // RW 8 bit
parameter CR_SEG7_1    = CR_MEM_OFFSET + 'h4  ; // RW 8 bit
parameter CR_SEG7_2    = CR_MEM_OFFSET + 'h8  ; // RW 8 bit
parameter CR_SEG7_3    = CR_MEM_OFFSET + 'hC  ; // RW 8 bit
parameter CR_SEG7_4    = CR_MEM_OFFSET + 'h10 ; // RW 8 bit
parameter CR_SEG7_5    = CR_MEM_OFFSET + 'h14 ; // RW 8 bit
parameter CR_LED       = CR_MEM_OFFSET + 'h18 ; // RW 10 bit
parameter CR_Button_0  = CR_MEM_OFFSET + 'h1C ; // RO 1 bit
parameter CR_Button_1  = CR_MEM_OFFSET + 'h20 ; // RO 1 bit
parameter CR_SWITCH    = CR_MEM_OFFSET + 'h24 ; // RO 10 bit


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
} t_cr_rw ;

endpackage
`endif 
