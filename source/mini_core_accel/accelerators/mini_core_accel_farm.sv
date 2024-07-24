`include "macros.vh"

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

genvar mul_index;

generate
    for(mul_index = 0; mul_index < MUL_NUM; mul_index++) begin : multiplier_inst
        booth_multiplier booth_multiplier (
            .clock(clock),
            .rst(rst),
            .input_req(core2mul_req.core2mul[mul_index]),
            .output_rsp(mul2core_rsp.mul2core[mul_index])
        );

    end
endgenerate


endmodule

