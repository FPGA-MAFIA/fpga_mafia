//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : mafia_asap_5pl_d_mem
// Original Author  : Matan Eshel & Gil Ya'akov
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 06/2022
//-----------------------------------------------------------------------------
// Description :
// This module serves as the data memory of the core.
// D_MEM will support sync memory read.
`include "macros.sv"

module d_mem (
    input  logic        clock,
    input  logic [31:2] address_a,
    input  logic [31:2] address_b,
    input  logic [31:0] data_a,
    input  logic [31:0] data_b,
    input  logic [3:0]  byteena_a,
    input  logic [3:0]  byteena_b,
    input  logic        wren_a,
    input  logic        wren_b,
    output logic [31:0] q_a,
    output logic [31:0] q_b
);
import big_core_pkg::*;
// Memory array (behavrial - not for FPGA/ASIC)
logic [7:0]         DMem     [D_MEM_MSB:I_MEM_MSB+1];
logic [7:0]         NextDMem [D_MEM_MSB:I_MEM_MSB+1];


// Data-Path signals
logic [31:0]        pre_q_a;
logic [31:0]        pre_q_b;
logic [31:0]        address_a_aligned;
logic [31:0]        address_b_aligned;
assign address_a_aligned = {address_a,2'b00};
assign address_b_aligned = {address_b,2'b00};

//==============================
// Memory Access
//------------------------------
// 1. Access D_MEM for Wrote (STORE) and Reads (LOAD)
//==============================
always_comb begin
    NextDMem = DMem;
    if(wren_a) begin 
        if(byteena_a[0]) NextDMem[address_a_aligned+0] = data_a[7:0];
        if(byteena_a[1]) NextDMem[address_a_aligned+1] = data_a[15:8] ;
        if(byteena_a[2]) NextDMem[address_a_aligned+2] = data_a[23:16];
        if(byteena_a[3]) NextDMem[address_a_aligned+3] = data_a[31:24];
    end
    if(wren_b) begin
        if(byteena_b[0]) NextDMem[address_b_aligned+0] = data_b[7:0];
        if(byteena_b[1]) NextDMem[address_b_aligned+1] = data_b[15:8] ;
        if(byteena_b[2]) NextDMem[address_b_aligned+2] = data_b[23:16];
        if(byteena_b[3]) NextDMem[address_b_aligned+3] = data_b[31:24];
    end
end

`MAFIA_DFF(DMem , NextDMem , clock)
// This is the load
assign pre_q_a = {DMem[address_a_aligned+3], DMem[address_a_aligned+2], DMem[address_a_aligned+1], DMem[address_a_aligned+0]};
assign pre_q_b = {DMem[address_b_aligned+3], DMem[address_b_aligned+2], DMem[address_b_aligned+1], DMem[address_b_aligned+0]};

// Sample the data load - synchorus load
`MAFIA_DFF(q_a, pre_q_a, clock)
`MAFIA_DFF(q_b, pre_q_b, clock)

endmodule // Module mafia_asap_5pl_d_mem