// registers


`include "cpuc_macros.vh"

module cpuc_register
import cpuc_package::*;
(
    input logic                   clk,
    input logic                   rst,
    input logic [DATA_WIDTH-1:0]  data_in,
    output logic [DATA_WIDTH-1:0] data_out

);

    `CPUC_RST_DFF(data_out, data_in, rst, clk)

endmodule