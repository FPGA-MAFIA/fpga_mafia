//-----------------------------------------------------------------------------
// Title            : data memory - Behavioral
// Project          : gpc_4t
//-----------------------------------------------------------------------------
// File             : d_mem.sv
// Original Author  : Amichai Ben-David
// Created          : 1/2020
//-----------------------------------------------------------------------------
// Description :
// Behavioral duel read dueal write memory
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------

`include "macros.sv"

//---------------------------------------------------
module mem #(
    parameter WORD_WIDTH,   //no defualt value.
    parameter ADRS_WIDTH    //no default value.
) (
    input  logic                  clock      ,
    //interface a
    input  logic [ADRS_WIDTH-1:0] address_a  ,
    input  logic                  wren_a     ,
    input  logic [3:0]            byteena_a  ,
    input  logic [WORD_WIDTH-1:0] data_a     ,
    output logic [WORD_WIDTH-1:0] q_a        ,
    //interface b
    input  logic [ADRS_WIDTH-1:0] address_b  ,
    input  logic                  wren_b     ,
    input  logic [3:0]            byteena_b  ,
    input  logic [WORD_WIDTH-1:0] data_b     ,
    output logic [WORD_WIDTH-1:0] q_b   
);

logic [7:0]             mem     [(2**ADRS_WIDTH)-1:0];
logic [7:0]             next_mem[(2**ADRS_WIDTH)-1:0];
logic [WORD_WIDTH-1:0]  pre_q_a;  
logic [WORD_WIDTH-1:0]  pre_q_b;
logic [ADRS_WIDTH+1:0]  address_a_byte;
logic [ADRS_WIDTH+1:0]  address_b_byte;
assign  address_a_byte = {address_a,2'b00};
assign  address_b_byte = {address_b,2'b00}; 

//=======================================
//          Writing to memory
//=======================================
always_comb begin
    next_mem = mem;
    if(wren_a) begin
        if(byteena_a[0]) next_mem[address_a_byte+0]= data_a[7:0];
        if(byteena_a[1]) next_mem[address_a_byte+1]= data_a[15:8];
        if(byteena_a[2]) next_mem[address_a_byte+2]= data_a[23:16];
        if(byteena_a[3]) next_mem[address_a_byte+3]= data_a[31:24]; 
    end
    if(wren_b) begin
        if(byteena_b[0]) next_mem[address_b_byte+0]= data_b[7:0];
        if(byteena_b[1]) next_mem[address_b_byte+1]= data_b[15:8];
        if(byteena_b[2]) next_mem[address_b_byte+2]= data_b[23:16];
        if(byteena_b[3]) next_mem[address_b_byte+3]= data_b[31:24]; 
    end
end 

//=======================================
//          the memory Array
//=======================================
`RVC_DFF(mem, next_mem, clock)

//=======================================
//          reading the memory
//=======================================
assign pre_q_a = {mem[address_a_byte+3], mem[address_a_byte+2], mem[address_a_byte+1], mem[address_a_byte+0]};
assign pre_q_b = {mem[address_b_byte+3], mem[address_b_byte+2], mem[address_b_byte+1], mem[address_b_byte+0]};
// sample the read - synchorus read
`RVC_DFF(q_a, pre_q_a, clock)
`RVC_DFF(q_b, pre_q_b, clock)

endmodule
