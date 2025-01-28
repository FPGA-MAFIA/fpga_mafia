// mux

`include "cpuc_macros.vh"

module cpuc_mux
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0]   data_in0,
    input logic [DATA_WIDTH-1:0]   data_in1,
    input logic [DATA_WIDTH-1:0]   ctrl, // TODO - all the signals have the same width. reduce width may cause warning but probably not errors
    output logic [DATA_WIDTH-1:0]  data_out
);

    assign data_out = (ctrl == '0) ? data_in0 : (ctrl == 1) ? data_in1 : data_in0; 

endmodule