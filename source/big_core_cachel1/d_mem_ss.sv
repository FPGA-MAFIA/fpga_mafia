`include "macros.vh"

module d_mem_ss 
import big_core_pkg::*;
(
    input logic              Clock,
    input logic              Rst,
    input var t_core2mem_req Core2DmemReqQ103H
    output logic [31:0]      DMemRdRspQ105H,  // data from d_mem regions(cache, vga or csr)
    output logic             DMemReady,       // data from d_mem region is ready (back pressure)
    output logic             inDisplayArea,
    output t_vga_out         vga_out
);


//================================================================
//                          D_CACHE     
//====================================    ============================
d_cache d_cache
(
    .clk(Clock),
    .rst(Rst),
    //Core Interface
    input   var t_req       core2cache_req,
    output  logic           ready,
    output  t_rd_rsp        cache2core_rsp, //RD Response
    // FM Interface
    output  t_fm_req        cache2fm_req_q3, 
    input   var t_fm_rd_rsp fm2cache_rd_rsp
);



//================================================================
//                          CR module     
//================================================================
 big_core_cr_mem big_core_cr_mem (
    .Clk              (Clock),
    .Rst              (Rst),
    .data             (DMemWrDataQ103H),
    .address          (DMemAddressQ103H),
    .wren             (DMemWrEnQ103H && MatchCRMemRegionQ103H),
    .rden             (DMemRdEnQ103H && MatchCRMemRegionQ103H),
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
    .kbd_data_rd      (kbd_data_rd), //input  t_kbd_data_rd kbd_data_rd,
    .kbd_ctrl         (kbd_ctrl   ), //output t_kbd_ctrl    kbd_ctrl,
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
   .ReqDataQ503H       (VgaWrData),
   .ReqAddressQ503H    (VgaAdrsReq),
   .CtrlVGAMemByteEn   (VgaWrByteEn),
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