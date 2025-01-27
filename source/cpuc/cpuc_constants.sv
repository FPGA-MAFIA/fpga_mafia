// constants

`include "cpuc_macros.vh"

module cpuc_constants
import cpuc_package::*;
(
    output logic [DATA_WIDTH-1:0]   const0,
    output logic [DATA_WIDTH-1:0]   const1,
    output logic [DATA_WIDTH-1:0]   const2,
    output logic [DATA_WIDTH-1:0]   const3
);

    assign const0 = {{(DATA_WIDTH-1){1'b0}}, 1'b1};
    assign const1 = {{(DATA_WIDTH-2){1'b0}}, 2'b10};
    assign const2 = {{(DATA_WIDTH-2){1'b0}}, 2'b11};
    assign const3 = {{(DATA_WIDTH-3){1'b0}}, 3'b100};


endmodule