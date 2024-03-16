//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : mafia_asap_5pl_i_mem
// Original Author  : Matan Eshel & Gil Ya'akov
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 03/2022
//-----------------------------------------------------------------------------
// Description :
// This module serves as the instruction memory of the core.
// The I_MEM will support sync memory read.
`include "macros.vh"

module i_mem (
    input  logic clock,
    input  logic [31:2] address_a,
    input  logic [31:2] address_b,
    input  logic [31:0] data_a,
    input  logic [31:0] data_b,
    input  logic        wren_a,
    input  logic        wren_b,
    output logic [31:0] q_a,
    output logic [31:0] q_b
);
import big_core_pkg::*;
// Memory array (behavrial - not for FPGA/ASIC)
logic [7:0]    IMem      [I_MEM_MSB:0];
logic [7:0]    next_IMem [I_MEM_MSB:0];

// Data-Path signals
logic [31:0]   InstructionQ100H_A;
logic [31:0]   InstructionQ100H_B;
logic [31:0]   address_a_aligned;
logic [31:0]   address_b_aligned;
assign address_a_aligned = {address_a,2'b00};
assign address_b_aligned = {address_b,2'b00};

always_comb begin : write_to_memory
    next_IMem = IMem;
    if(wren_a) begin
        next_IMem[address_a_aligned+0]= data_a[7:0];
        next_IMem[address_a_aligned+1]= data_a[15:8];
        next_IMem[address_a_aligned+2]= data_a[23:16];
        next_IMem[address_a_aligned+3]= data_a[31:24]; 
    end
    if(wren_b) begin
        next_IMem[address_b_aligned+0]= data_b[7:0];
        next_IMem[address_b_aligned+1]= data_b[15:8];
        next_IMem[address_b_aligned+2]= data_b[23:16];
        next_IMem[address_b_aligned+3]= data_b[31:24]; 
    end
end 
// Note: This memory is written in behavioral way for simulation - for FPGA/ASIC should be replaced with SRAM/RF/LATCH based memory etc.
// FIXME - currently this logic wont allow to load the I_MEM from HW interface - for simulation we will use Backdoor. (force with XMR)
`MAFIA_DFF(IMem, IMem, clock)
// This is the instruction fetch. (input pc, output Instruction)

assign InstructionQ100H_A[7:0]   = IMem[address_a_aligned+0]; // mux - address_aligned is the selector, IMem is the Data, Instruction is the Out
assign InstructionQ100H_A[15:8]  = IMem[address_a_aligned+1];
assign InstructionQ100H_A[23:16] = IMem[address_a_aligned+2];
assign InstructionQ100H_A[31:24] = IMem[address_a_aligned+3];
assign InstructionQ100H_B[7:0]   = IMem[address_b_aligned+0]; // mux - address_aligned is the selector, IMem is the Data, Instruction is the Out
assign InstructionQ100H_B[15:8]  = IMem[address_b_aligned+1];
assign InstructionQ100H_B[23:16] = IMem[address_b_aligned+2];
assign InstructionQ100H_B[31:24] = IMem[address_b_aligned+3];

// Sample the instruction read - synchorus read

`MAFIA_DFF(q_a, InstructionQ100H_A, clock)
`MAFIA_DFF(q_b, InstructionQ100H_B, clock)

endmodule // Module i_mem