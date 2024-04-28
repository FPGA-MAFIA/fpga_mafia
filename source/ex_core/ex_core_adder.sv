// This is a simple 4-bit adder module
module ex_core_adder (
    input [3:0] a,
    input [3:0] b,
    output [3:0] sum
);
    assign sum = a + b;
endmodule