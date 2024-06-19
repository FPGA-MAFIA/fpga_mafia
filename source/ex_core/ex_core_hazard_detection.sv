`include "macros.vh"

// hazard detection unit
module ex_core_hazard_detection
import ex_core_pkg::*;
(
        input logic [4:0] RegSrc1Q101H,
        input logic [4:0] RegSrc2Q101H,
        input logic [4:0] RegDstQ102H,
        output logic HazardDetected
);

    assign HazardDetected = (RegDstQ102H == RegSrc1Q101H) || (RegDstQ102H == RegSrc2Q101H);

endmodule