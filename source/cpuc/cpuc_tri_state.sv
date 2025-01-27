// tri state

`include "cpuc_macros.vh"

module cpuc_tri_state
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0]   data_in,
    input logic                    en,
    output logic [DATA_WIDTH-1:0]  data_out
);

    assign data_out = (en) ? data_in : {DATA_WIDTH{1'bz}}; 

endmodule