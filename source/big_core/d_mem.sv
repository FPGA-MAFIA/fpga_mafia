//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : rvc_asap
//-----------------------------------------------------------------------------
// File             : rvc_asap_5pl_d_mem
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
    input  logic        Clk,
    input  logic [31:0] data,
    input  logic [31:2] address,
    input  logic [3:0]  byteena,
    input  logic        wren,
    input  logic        rden,
    output logic [31:0] q
);
import big_core_pkg::*;
// Memory array (behavrial - not for FPGA/ASIC)
logic [7:0]         DMem     [D_MEM_MSB:I_MEM_MSB+1];
logic [7:0]         NextDMem [D_MEM_MSB:I_MEM_MSB+1];

// Data-Path signals
logic [31:0]        pre_q;
logic [31:0]        address_aligned;
assign address_aligned = {address,2'b00};

//==============================
// Memory Access
//------------------------------
// 1. Access D_MEM for Wrote (STORE) and Reads (LOAD)
//==============================
always_comb begin
    NextDMem = DMem;
    if(wren) begin
        if(byteena[0]) NextDMem[address_aligned+0] = data[7:0];
        if(byteena[1]) NextDMem[address_aligned+1] = data[15:8] ;
        if(byteena[2]) NextDMem[address_aligned+2] = data[23:16];
        if(byteena[3]) NextDMem[address_aligned+3] = data[31:24];
    end
end

`RVC_DFF(DMem , NextDMem , Clk)
// This is the load
assign pre_q = rden ? {DMem[address_aligned+3], DMem[address_aligned+2], DMem[address_aligned+1], DMem[address_aligned+0]} : '0;

// Sample the data load - synchorus load
`RVC_DFF(q, pre_q, Clk)

endmodule // Module rvc_asap_5pl_d_mem