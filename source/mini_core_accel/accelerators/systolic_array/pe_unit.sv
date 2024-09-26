// PE unit of systolic array.
// Each unit consists of MAC

`include "macros.vh"
module pe_unit
import mini_core_accel_pkg::*;
(
    input logic                 clk,
    input logic                 rst,
    input var t_pe_unit_input   pe_inputs,
    output int16                result
);


//-----------------------------
// single cycle multiplier 
//-----------------------------
int16 mul_result;
single_cycle_mul single_cycle_mul
(
    .clk(clk),
    .rst(rst),
    .multiplier(pe_inputs.weight),
    .multiplicand(pe_inputs.activation),
    .result(mul_result)
);


// MAC logic
logic [17:0] next_ff_result, ff_result;

assign next_ff_result = {{2{mul_result[15]}},mul_result} + ff_result;

`MAFIA_RST_DFF(ff_result, next_ff_result, clk, rst)


always_comb begin
    result = ff_result[15:0];
    if(pe_inputs.done) begin
        // saturation logic
        if($signed(ff_result) > 18'd127) begin
            result = 16'sd127; 
        end
        if($signed(ff_result) < -18'sd128)begin
            result = -16'sd128;
        end
    end
end

endmodule