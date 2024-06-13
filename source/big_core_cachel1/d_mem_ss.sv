`include "macros.vh"

module d_mem_ss 
import big_core_pkg::*;
(
    input logic              Clock,
    input logic              Rst,
    //============================================
    //      Dmem interface
    //============================================ 
    input var t_core2mem_req Core2DmemReqQ103H
    output logic [31:0]      DMemRdRspQ105H,  // data from d_mem regions(cache, vga or csr)
    output logic             DMemReady,       // data from d_mem region is ready (back pressure)
    //============================================
    //      vga interface
    //============================================  
    output logic             inDisplayArea,
    output t_vga_out         vga_out,
    //============================================
    //      keyboard interface
    //============================================  
    input  var t_kbd_data_rd kbd_data_rd,
    output t_kbd_ctrl        kbd_ctrl,
    //============================================
    //      fpga interface
    //============================================             
    input  var t_fpga_in   fpga_in,  // CR_MEM
    output t_fpga_out      fpga_out      // CR_MEM       
);

//================================================================
//                   Memory region detection     
//====================================    ========================
logic MatchCRMemRegionQ103H;
logic MatchVGAMemRegionQ103H;
logic MatchCacheMemRegionQ103H;

d_mem_region_detect d_mem_region_detect
(
    .Clock                      (Clock),
    .Rst                        (Rst),
    .DMemAddressQ103H           (Core2DmemReqQ103H.address),
    .MatchCRMemRegionQ103H      (MatchCRMemRegionQ103H),
    .MatchVGAMemRegionQ103H     (MatchVGAMemRegionQ103H),
    .MatchCacheMemRegionQ103H   (MatchCacheMemRegionQ103H)
);


//================================================================
//                          D_CACHE     
//================================================================
t_req core2cache_reqQ103H;
assign core2cache_reqQ103H.valid       = Core2DmemReqQ103H.WrEN || Core2DmemReqQ103H.RdEN; 
assign core2cache_reqQ103H.reg_id      = 1'b0;  // TODO - change that to support OOR in the future
assign core2cache_reqQ103H.opcode      = Core2DmemReqQ103H.WrEN ? WR_OP : RD_OP;
assign core2cache_reqQ103H.address     = Core2DmemReqQ103H.address;
assign core2cache_reqQ103H.data        = Core2DmemReqQ103H.data;
assign core2cache_reqQ103H.byte_en     = Core2DmemReqQ103H.ByteEn;
assign core2cache_reqQ103H.sign_extend = 1'b1; // FIXME add support to sign_extend


d_cache d_cache
(
    .clk            (Clock),
    .rst            (Rst),
    //Core Interface
    .core2cache_req (core2cache_reqQ103H),
    .ready          (DMemReady),  // FIXME - consider how manage that in 6 stage pipeline when we have cache hit
    output  t_rd_rsp        cache2core_rsp, 
    // FM Interface
    .cache2fm_req_q3(),   // FIXME
    .fm2cache_rd_rsp()    // FIXME
);

//================================================================
//                          CR module     
//================================================================

logic [9:0] VGA_CounterX;
logic [9:0] VGA_CounterY;

 big_core_cr_mem big_core_cr_mem (
    .Clk              (Clock),
    .Rst              (Rst),
    .data             (Core2DmemReqQ103H.data),
    .address          (Core2DmemReqQ103H.address),
    .wren             (Core2DmemReqQ103H.WrEN && MatchCRMemRegionQ103H),
    .rden             (Core2DmemReqQ103H.RdEN && MatchCRMemRegionQ103H),
    .q                (PreCRMemRdDataQ104H),
    //Fabric access interface
    .data_b           (),
    .address_b        (),
    .wren_b           (),
    .q_b              (),
    // VGA info
    .VGA_CounterX     (VGA_CounterX), //input  logic [9:0] VGA_CounterX,
    .VGA_CounterY     (VGA_CounterY), //input  logic [9:0] VGA_CounterY,
    // Keyboard interface
    .kbd_data_rd      (kbd_data_rd),  
    .kbd_ctrl         (kbd_ctrl), 
    // FPGA interface
    .fpga_in          (fpga_in),  
    .fpga_out         (fpga_out)
);

//================================================================
//                          VGA controller     
//================================================================
big_core_vga_ctrl big_core_vga_ctrl (
   .Clk_50            (Clock),
   .Reset             (Rst),
   // Core interface
   // write
   .ReqDataQ503H       (VgaWrData),   // FIXME
   .ReqAddressQ503H    (VgaAdrsReq),  // FIXME
   .CtrlVGAMemByteEn   (VgaWrByteEn), // FIXME
   .CtrlVgaMemWrEnQ503 (VgaWrEn),     // FIXME
   // read
   .CtrlVgaMemRdEnQ503 (VgaWrEn),
   .VgaRspDataQ504H    (PreShiftVGAMemRdDataQ104H),
   // VGA output
   .VGA_CounterX      (VGA_CounterX)  , // output  logic [9:0] VGA_CounterX,
   .VGA_CounterY      (VGA_CounterY)  , // output  logic [9:0] VGA_CounterY,
   .inDisplayArea     (inDisplayArea) ,
   .RED               (vga_out.VGA_R) ,
   .GREEN             (vga_out.VGA_G) ,
   .BLUE              (vga_out.VGA_B) ,
   .h_sync            (vga_out.VGA_HS),
   .v_sync            (vga_out.VGA_VS)
);

endmodule