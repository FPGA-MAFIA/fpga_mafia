`include "macros.vh"

module d_mem_ss 
import big_core_pkg::*;
import d_cache_param_pkg::*;
(
    input logic              Clock,
    input logic              Rst,
    //============================================
    //      Dmem interface
    //============================================ 
    input var t_core2mem_req Core2DmemReqQ103H,
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
    // FM interface
    //============================================
    output  t_fm_req        cache2fm_req_q3, 
    input   var t_fm_rd_rsp fm2cache_rd_rsp,
    //============================================
    //      fpga interface
    //============================================             
    input  var t_fpga_in   fpga_in,  // CR_MEM
    output t_fpga_out      fpga_out      // CR_MEM       
);

//================================================================
//                   Memory region detection     
//================================================================
t_dmem_region MatchDmemRegionQ103H;

d_mem_region_detect d_mem_region_detect
(
    .Clock                      (Clock),
    .Rst                        (Rst),
    .Core2DmemReqQ103H          (Core2DmemReqQ103H),
    .MatchDmemRegionQ103H       (MatchDmemRegionQ103H)
);


//================================================================
//              dmem re-issue and dmem2core data     
//================================================================

logic [31:0]  ShiftVgaDMemWrDataQ103H;
logic [3:0]   ShiftVgaDMemByteEnQ103H; 
logic [31:0]  CRMemRdDataQ104H;
logic [31:0]  PreShiftVGAMemRdDataQ104H;
logic [31:0]  Cache2coreRespDataQ105H;

d_mem_reissue d_mem_reissue
(
    .Clock                              (Clock),
    .Rst                                (Rst),
    .DMemReady                          (DMemReady),
    .MatchDmemRegionQ103H               (MatchDmemRegionQ103H),
    .Core2DmemReqQ103H                  (Core2DmemReqQ103H),  
    // cr interface
    .CRMemRdDataQ104H                   (CRMemRdDataQ104H),
    // vga interface
    .ShiftVgaDMemWrDataQ103H            (ShiftVgaDMemWrDataQ103H),
    .ShiftVgaDMemByteEnQ103H            (ShiftVgaDMemByteEnQ103H),
    .PreShiftVGAMemRdDataQ104H          (PreShiftVGAMemRdDataQ104H),
    // cache interface
    .Cache2coreRespDataQ105H            (Cache2coreRespDataQ105H),
    // read response to core
    .DMemRdRspQ105H                     (DMemRdRspQ105H)
);

//================================================================
//                          D_CACHE     
//================================================================
t_req    core2cache_reqQ103H;
t_rd_rsp cache2core_rspQ105H;

// core to cache request
assign core2cache_reqQ103H.valid       = MatchDmemRegionQ103H.MathcDcacheRegion && (Core2DmemReqQ103H.WrEn || Core2DmemReqQ103H.RdEn) && DMemReady; 
assign core2cache_reqQ103H.reg_id      = 1'b0;  // TODO - add logic to cache to support oor exevution
assign core2cache_reqQ103H.address     = Core2DmemReqQ103H.Address;
assign core2cache_reqQ103H.data        = Core2DmemReqQ103H.WrData;
assign core2cache_reqQ103H.byte_en     = Core2DmemReqQ103H.ByteEn;
assign core2cache_reqQ103H.sign_extend = Core2DmemReqQ103H.SignExt;

assign core2cache_reqQ103H.opcode      =  (Core2DmemReqQ103H.WrEn) ? WR_OP : 
                                          (Core2DmemReqQ103H.RdEn) ? RD_OP : RD_OP;

// cache to core response
assign Cache2coreRespDataQ105H = cache2core_rspQ105H.data;

d_cache d_cache
(
    .clk              (Clock),
    .rst              (Rst),
    //Core Interface
    .core2cache_req   (core2cache_reqQ103H),
    .ready            (DMemReady),  
    .cache2core_rsp   (cache2core_rspQ105H), 
    // FM Interface
    .cache2fm_req_q3(cache2fm_req_q3),
    .fm2cache_rd_rsp(fm2cache_rd_rsp)  
);

//================================================================
//                          CR module     
//================================================================

logic [9:0] VGA_CounterX;
logic [9:0] VGA_CounterY;


 big_core_cr_mem big_core_cr_mem (
    .Clk              (Clock),
    .Rst              (Rst),
    .data             (Core2DmemReqQ103H.WrData),
    .address          (Core2DmemReqQ103H.Address),
    .wren             (Core2DmemReqQ103H.WrEn && MatchDmemRegionQ103H.MatchCrRegion),
    .rden             (Core2DmemReqQ103H.RdEn && MatchDmemRegionQ103H.MatchCrRegion),
    .q                (CRMemRdDataQ104H),
    //Fabric access interface
    .data_b           ('0),  
    .address_b        ('0),
    .wren_b           ('0),
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
logic VgaWrEn;
logic [31:0] VgaAddressWithOffsetQ103H;

assign VgaWrEn = Core2DmemReqQ103H.WrEn && MatchDmemRegionQ103H.MatchVgaRegion;
assign VgaAddressWithOffsetQ103H = Core2DmemReqQ103H.Address - VGA_MEM_REGION_FLOOR;

big_core_vga_ctrl big_core_vga_ctrl (
   .Clk_50            (Clock),
   .Reset             (Rst),
   // Core interface
   // write
   .ReqDataQ503H       (ShiftVgaDMemWrDataQ103H),   
   .ReqAddressQ503H    (VgaAddressWithOffsetQ103H),  
   .CtrlVGAMemByteEn   (ShiftVgaDMemByteEnQ103H), 
   .CtrlVgaMemWrEnQ503 (VgaWrEn),     
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