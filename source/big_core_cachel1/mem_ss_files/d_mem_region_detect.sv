`include "macros.vh"
// Unit responsible of detectiong which region of the data memory we want to use
// for example: we have region for cache, cr and vga

module d_mem_region_detect
import big_core_pkg::*;
(
    input logic              Clock,
    input logic              Rst,
    input var t_core2mem_req Core2DmemReqQ103H,
    output var t_dmem_region MatchDmemRegionQ103H
);

    assign MatchDmemRegionQ103H.MatchVgaRegion    = ((Core2DmemReqQ103H.Address[VGA_MSB_REGION:LSB_REGION] >= VGA_MEM_REGION_FLOOR) && (Core2DmemReqQ103H.Address[VGA_MSB_REGION:LSB_REGION] <= VGA_MEM_REGION_ROOF));
    assign MatchDmemRegionQ103H.MatchCrRegion     = ((Core2DmemReqQ103H.Address[MSB_REGION:LSB_REGION] >= CR_MEM_REGION_FLOOR)      && (Core2DmemReqQ103H.Address[MSB_REGION:LSB_REGION] <= CR_MEM_REGION_ROOF));
    assign MatchDmemRegionQ103H.MathcDcacheRegion = !(MatchDmemRegionQ103H.MatchVgaRegion || MatchDmemRegionQ103H.MatchCrRegion); 

//================================
// Memorry access assertion
//===============================
`ifdef SIM_ONLY
logic  AddrRangeHit;
logic  clk;        // FIXME - in MAFIA_ASSERT macro we use 'clk' instead of 'Clk'
assign clk = Clock; 
assign AddrRangeHit  = (Core2DmemReqQ103H.Address > VGA_MEM_REGION_ROOF || Core2DmemReqQ103H.Address < D_MEM_REGION_FLOOR);

`MAFIA_ASSERT($sformatf("access adder %h is out of range",Core2DmemReqQ103H.Address), AddrRangeHit, Core2DmemReqQ103H.WrEn, "write")
`MAFIA_ASSERT($sformatf("access adder %h is out of range",Core2DmemReqQ103H.Address), AddrRangeHit, Core2DmemReqQ103H.RdEn, "read")
`endif

endmodule

