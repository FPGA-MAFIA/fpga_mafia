// mux

`include "cpuc_macros.vh"

module cpuc_inst_mem 
import cpuc_package::*;
#(parameter INST_NUM, parameter INST_WIDTH)
(
    input logic clk,
    input logic we,
    input logic [INST_WIDTH-1:0]       instruction_in,
    input logic [$clog2(INST_NUM)-1:0] address,
    output logic [INST_WIDTH-1:0]      instruction_out 
);

    logic [INST_WIDTH-1:0] mem [INST_NUM-1:0];
    logic [INST_WIDTH-1:0] next_mem [INST_NUM-1:0];

    `CPUC_DFF(mem, next_mem, clk)

    always_comb begin
        next_mem = mem;
        if(we) begin
            next_mem[address] = instruction_in; 
        end
    end
    
    assign instruction_out = mem[address];

endmodule