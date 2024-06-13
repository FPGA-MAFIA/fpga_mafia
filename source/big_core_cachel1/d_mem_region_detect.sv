`include "macros.vh"
// Unit responsible of detectiong which region of the data memory we want to use
// for example: we have region for cache, cr and vga

module d_mem_region_detect
import big_core_pkg::*;
(
    input               Clock,
    input logic         Rst,
    input  logic [31:0] DMemAddressQ103H,
    output logic        MatchCRMemRegionQ103H,
    output logic        MatchVGAMemRegionQ103H,
    output logic        MatchCacheMemRegionQ103H
);

    assign MatchVGAMemRegionQ103H   = ((DMemAddressQ103H[VGA_MSB_REGION:LSB_REGION] >= VGA_MEM_REGION_FLOOR) && (DMemAddressQ103H[VGA_MSB_REGION:LSB_REGION] <= VGA_MEM_REGION_ROOF));
    assign MatchCRMemRegionQ103H    = ((DMemAddressQ103H[MSB_REGION:LSB_REGION] >= CR_MEM_REGION_FLOOR) && (DMemAddressQ103H[MSB_REGION:LSB_REGION] <= CR_MEM_REGION_ROOF));
    assign MatchCacheMemRegionQ103H = !(MatchVGAMemRegionQ103H || MatchCRMemRegionQ103H); 

endmodule

