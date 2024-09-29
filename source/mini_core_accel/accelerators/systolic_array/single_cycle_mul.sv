// Implementation of int8*int8 multiplier in one cycle

module single_cycle_mul
import mini_core_accel_pkg::*;
(
    input logic  clk,
    input logic  rst,
    input int8   multiplier,
    input int8   multiplicand,
    output int16 result
);

int16 partial_result0;
int16 partial_result1;
int16 partial_result2;
int16 partial_result3;
int16 partial_result4;
int16 partial_result5;
int16 partial_result6;
int16 partial_result7;

// logic to deal with negative numbers
// I got issues when multiplicand is negative than I make him be possitive and convert the reusult of needed in the last line

int8  positive_miltiplicand;
assign positive_miltiplicand = (multiplicand[7]== 1) ? (~multiplicand + 1) : multiplicand;

int16 extended_multiplier;
assign extended_multiplier = $signed(multiplier);

assign partial_result0 = (positive_miltiplicand[0] == 1) ? {extended_multiplier}       : 0;
assign partial_result1 = (positive_miltiplicand[1] == 1) ? {extended_multiplier, 1'b0} : 0;
assign partial_result2 = (positive_miltiplicand[2] == 1) ? {extended_multiplier, 2'b0} : 0;
assign partial_result3 = (positive_miltiplicand[3] == 1) ? {extended_multiplier, 3'b0} : 0;
assign partial_result4 = (positive_miltiplicand[4] == 1) ? {extended_multiplier, 4'b0} : 0;
assign partial_result5 = (positive_miltiplicand[5] == 1) ? {extended_multiplier, 5'b0} : 0;
assign partial_result6 = (positive_miltiplicand[6] == 1) ? {extended_multiplier, 6'b0} : 0;
assign partial_result7 = (positive_miltiplicand[7] == 1) ? {extended_multiplier, 7'b0} : 0;  // that line will always assign 0 to partial sum

int16 pre_result;
assign pre_result = (rst) ? '0 : partial_result0 + partial_result1 + partial_result2 + partial_result3 +
                                 partial_result4 + partial_result5 + partial_result6 + partial_result7;

assign result = (multiplicand[7] == 1) ? (~pre_result + 1) : pre_result;

endmodule