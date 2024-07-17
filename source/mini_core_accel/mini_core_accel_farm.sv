`include "macros.h"

module mini_core_accel_farm 
import mini_core_pkg::*;
import mini_core_accel_pkg::*;
#(parameter MUL_NUM = 8)
(
    input logic                 clock,
    input logic                 rst,
    input var t_core2mul_req    core2mul_req,
    output var t_mul2core_rsp   mul2core_rsp
);

genvar MUL_INDEX;
generate
    for(MUL_INDEX = 0; MUL_INDEX <= MUL_NUM; MUL_INDEX++) begin
        booth_multiplier booth_multiplier (
            .clock(clock),
            .rst(rst),
            .input_req,
            .output_rsp

        );

    end


endgenerate

endmodule