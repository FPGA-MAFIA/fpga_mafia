`include "macros.vh"

module mini_core_rrv_mem_acs
import mini_core_rrv_pkg::*;
(
    input Clock,
    input Rst,
    input var t_ctrl_mem Ctrl,
    input logic [31:0] AluOutQ101H,
    input logic [31:0] DMemWrDataQ101H,
    output var t_core2mem_req Core2DmemReqQ101H

);

    assign Core2DmemReqQ101H.WrData  = DMemWrDataQ101H;
    assign Core2DmemReqQ101H.Address = AluOutQ101H;
    assign Core2DmemReqQ101H.WrEn    = Ctrl.DMemWrEnQ101H;
    assign Core2DmemReqQ101H.RdEn    = Ctrl.DMemRdEnQ101H;
    assign Core2DmemReqQ101H.ByteEn  = Ctrl.DMemByteEnQ101H;


endmodule