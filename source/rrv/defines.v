//----- General purpose register file -----//
`define NO_INIT_GPR 
`define REG_WIDTH  32
`define GPRN       32

//----- Instruction BRAM defines -----//
`define INST_DEPTH      65536
`define INST_MEM_WIDTH  8
`define INST_WIDTH      32

//----- DATA BRAM defines -----//
`define NO_INIT_DATA_RAM
//`define DATA_DEPTH  2048
`define DATA_DEPTH  262144
`define DATA_WIDTH  32 

//----- Fetch stage -----//
`define PC_WIDTH        32 

//----- Decode stage -----//
`define IMM_ID         32
`define REG_ADDR_WIDTH 5
`define OP_CODE_WIDTH  7
`define FUNCT3_WIDTH   3
`define addr_rs1    instruction[19:15]
`define addr_rs2    instruction[24:20]
`define addr_rd     instruction[11:7]
`define funct3      instruction[14:12]
`define bit         instruction[30]
`define shamt       instruction[24:20]

//----- imm generator (DECODE_STAGE) -----//
`define op_code   instruction[6:0]  
`define msb       instruction[31]
`define imm_i     instruction[31:20]
`define imm_sr    instruction[11:7]
`define imm_sl    instruction[31:25]
`define imm_br    instruction[11:8]
`define imm_bl    instruction[30:25]
`define b_bit     instruction[7]
`define imm_jl    instruction[30:21]
`define imm_jr    instruction[19:12]
`define l_bit     instruction[20]
`define imm_u     instruction[31:12]

//----- write back stage -----//
`define pass 1'b0
`define load 1'b1

//----- OP_CODES -----//
`define r_type        7'b0110011
`define i_type_arithm 7'b0010011
`define i_type_dmem   7'b0000011
`define s_type        7'b0100011
`define b_type        7'b1100011
`define i_type_jalr   7'b1100111
`define j_type        7'b1101111
`define u_type_auipc  7'b0010111
`define u_type_lui    7'b0110111

//----- alu -----//
`define FLAGN     3 
`define FUNC_SIZE 4
`define add  4'b0000
`define sub  4'b1000
`define sll  4'b0001
`define slt  4'b0010
`define sltu 4'b0011
`define rxor 4'b0100
`define srl  4'b0101
`define sra  4'b1101
`define ror  4'b0110
`define rand 4'b0111



 


