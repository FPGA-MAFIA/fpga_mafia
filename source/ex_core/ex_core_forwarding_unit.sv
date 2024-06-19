`include "macros.vh"

// forwarding unit
module ex_core_forwarding_unit
import ex_core_pkg::*;
(
    input logic [4:0] RegSrc1Q101H,
    input logic [4:0] RegSrc2Q101H,
    input logic [4:0] RegDstQ102H,
    input logic HazardDetected,
    output logic FwdA,
    output logic FwdB
);

    always_comb begin
        // default: no forwarding
        FwdA = 1'b0;
        FwdB = 1'b0;

        // if a hazard is detected
        if (HazardDetected) begin
            // if the destination register of the instruction in the wb stage (Q102) matches
            // the source register of the instruction in the execute stage (Q101), forward data from wb stage
            if (RegDstQ102H == RegSrc1Q101H) begin
                FwdA = 1'b1;  // forward from wb stage
            end
            if (RegDstQ102H == RegSrc2Q101H) begin
                FwdB = 1'b1;  // forward from wb stage
            end
        end
    end

endmodule
