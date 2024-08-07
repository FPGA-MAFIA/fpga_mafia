

module accel_core_xor
(
    input logic Rst,
    input logic [7:0] x, 
    input logic [7:0] y, 
    output logic [7:0] out
);

assign out = (Rst) ? 0 : x ^ y;

endmodule