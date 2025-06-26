
`include "macros.vh"

module fabric_rv32i_ref_top
import fabric_rv32i_ref_pkg::*;
(
    input logic clk,
    input logic rst,
    input logic run

);


//-----------------
//     fabric 0
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
) 
fabric_rv32i_ref_0
(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req()
);

//-----------------
//     fabric 1
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
) 
fabric_rv32i_ref_1

(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req()
);

//-----------------
//     fabric 2
//-----------------
fabric_rv32i_ref
#(  
    .I_MEM_LSB('h0_0000),
    .I_MEM_MSB('h1_0000 - 1'h1),
    .D_MEM_LSB('h1_0000),
    .D_MEM_MSB('h2_0000 - 1'h1) 
) 
fabric_rv32i_ref_2

(
    .clk(clk),
    .rst(rst),
    .run(run),
    .core2mem_req()
);


endmodule
