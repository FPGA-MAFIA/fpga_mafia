// constants

`include "cpuc_macros.vh"

module cpuc_constants
import cpuc_package::*;
#(parameter CONST_NUM)
(   
    input logic                          clk,
    input logic                          rst,
    input logic [DATA_WIDTH-1:0]         constant_in,
    input logic                          we,
    input logic [$clog2(CONST_NUM)-1:0]  address,
    output var t_constants_output        constants_output
);

    logic [DATA_WIDTH-1:0] mem [CONST_NUM-1:0];
    logic [DATA_WIDTH-1:0] next_mem [CONST_NUM-1:0];

    `CPUC_DFF(mem, next_mem, clk)

    integer i;
    always_comb begin
        next_mem = mem;
        if(rst) begin
            for(i=0; i<CONST_NUM; i++) begin
                next_mem[i] = '0;
            end
        end
        else if(we) begin
            next_mem[address] = constant_in;
        end
    end

    genvar j;
    generate 
        for(j=0; j<CONST_NUM; j++) begin: generate_outputs
            assign constants_output.constants_output[j] = mem[j]; 
        end
    endgenerate
    
    

endmodule