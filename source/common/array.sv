//-----------------------------------------------------------------------------
// Title            : 
// Project          : 
//-----------------------------------------------------------------------------
// File             : <TODO>
// Original Author  : 
// Code Owner       : 
// Created          : 
//-----------------------------------------------------------------------------
// Description : 
//
//-----------------------------------------------------------------------------
`include "macros.sv"

module array #(
    parameter WORD_WIDTH,   //no default value.
    parameter ADRS_WIDTH     //no default value.
)(
    input   logic                   clk,
    input   logic                   rst,
    //write port
    input   logic                   wr_en,
    input   logic [ADRS_WIDTH-1:0]  wr_address,
    input   logic [WORD_WIDTH-1:0]  wr_data,
    //read port
    input   logic [ADRS_WIDTH-1:0] rd_address,
    output  logic [WORD_WIDTH-1:0] q
);

logic [WORD_WIDTH-1:0] mem     [(2**ADRS_WIDTH)-1:0];
logic [WORD_WIDTH-1:0] next_mem[(2**ADRS_WIDTH)-1:0];
logic [WORD_WIDTH-1:0] pre_q;  


//=======================================
//          Writing to memory
//=======================================
always_comb begin
    next_mem = rst ? '{default:0} : mem;
    if(wr_en) next_mem[wr_address]= wr_data;
end 

//=======================================
//          the memory Array
//=======================================
`MAFIA_DFF(mem, next_mem, clk)

//=======================================
//          reading the memory
//=======================================
assign pre_q= mem[rd_address];
// sample the read - synchros read
`MAFIA_DFF(q, pre_q, clk)

endmodule