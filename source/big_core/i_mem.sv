//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : rvc_asap
//-----------------------------------------------------------------------------
// File             : rvc_asap_5pl_i_mem
// Original Author  : Matan Eshel & Gil Ya'akov
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 03/2022
//-----------------------------------------------------------------------------
// Description :
// This module serves as the instruction memory of the core.
// The I_MEM will support sync memory read.
`include "macros.sv"

module i_mem (
    input  logic Clk,
    input  logic [31:2] address,
    output logic [31:0] q
);
import big_core_pkg::*;  
// Memory array (behavrial - not for FPGA/ASIC)
logic [7:0]         IMem [I_MEM_MSB:0];

// Data-Path signals
logic [31:0]        InstructionQ100H;
logic [31:0]        address_aligned;
assign address_aligned = {address,2'b00};

// Note: This memory is written in behavioral way for simulation - for FPGA/ASIC should be replaced with SRAM/RF/LATCH based memory etc.
// FIXME - currently this logic wont allow to load the I_MEM from HW interface - for simulation we will use Backdoor. (force with XMR)
`RVC_DFF(IMem, IMem, Clk)
// This is the instruction fetch. (input pc, output Instruction)

assign InstructionQ100H[7:0]   = IMem[address_aligned+0]; // mux - address_aligned is the selector, IMem is the Data, Instruction is the Out
assign InstructionQ100H[15:8]  = IMem[address_aligned+1];
assign InstructionQ100H[23:16] = IMem[address_aligned+2];
assign InstructionQ100H[31:24] = IMem[address_aligned+3];
// Sample the instruction read - synchorus read

`RVC_DFF(q, InstructionQ100H, Clk)

endmodule // Module i_mem