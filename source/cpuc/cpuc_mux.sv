// mux

`include "cpuc_macros.vh"

module cpuc_mux
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0]   data_in0,
    input logic [DATA_WIDTH-1:0]   data_in1,
    input logic                    ctrl,
    output logic [DATA_WIDTH-1:0]  data_out
);

    assign data_out = (!ctrl) ? data_in0 : data_in1; 

endmodule