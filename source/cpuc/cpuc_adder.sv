// adder between two registers

`include "cpuc_macros.vh"

module cpuc_adder
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0] data_in0,
    input logic [DATA_WIDTH-1:0] data_in1,
    output logic [DATA_WIDTH:0]  data_out,
    output logic                 carry_out
);

    assign data_out  = data_in0 + data_in1; 
    assign carry_out = data_out[DATA_WIDTH];

endmodule