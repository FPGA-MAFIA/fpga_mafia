`include "macros.vh"

`define CORE2MUL_REQ(INDEX)       core2mul_req.core2mul``INDEX``
`define MUL2CORE_RSP(INDEX)       mul2core_rsp.mul2core``INDEX``

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
            .input_req(`CORE2MUL_REQ(mul_index)),
            .output_rsp(`MUL2CORE_RSP(mul_index))

        );

    end
endgenerate


endmodule

