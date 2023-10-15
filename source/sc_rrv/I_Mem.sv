//-----------------------------------------------------------------------------
// Title            : I_Mem cycle core design
// Project          : single cycle core
//-----------------------------------------------------------------------------
// File             : i_mem
// Original Author  : Roman Gilgor
// Code Owner       : 
// Created          : 10/2023
//-----------------------------------------------------------------------------
// Description :
// This is the top level of the single cycle core design.
// The core is a 32 bit RISC-V core.
// compatible with the RV32I base instruction set.
// Fetch, Decode, Execute, Memory, WriteBack all in one cycle.
// The PC (program counter) is the synchronous element in the core 
//-----------------------------------------------------------------------------


module i_mem 
import sc_core_pkg::*;
(
   input logic   [$clog2(I_MEM_SIZE)-1:0] Pc,
   output logic  [31:0] Instruction
 );
    
    logic [7:0] IMem [I_MEM_SIZE-1:I_MEM_OFFSET]; 
    
    assign Instruction = {IMem[Pc+3], IMem[Pc+2], IMem[Pc+1], IMem[Pc]};  //Little Endian
    
endmodule
