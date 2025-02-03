// '>' operator

`include "cpuc_macros.vh"

module cpuc_greater_comparator
import cpuc_package::*;
(
    input logic [DATA_WIDTH-1:0]  data_in0,
    input logic [DATA_WIDTH-1:0]  data_in1,
    output logic [DATA_WIDTH-1:0] data_out    
);

    assign data_out  = ($signed(data_in0) > $signed(data_in1)) ? '1 : '0;
    

endmodule