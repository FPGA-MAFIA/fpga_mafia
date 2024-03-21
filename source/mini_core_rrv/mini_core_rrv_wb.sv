`include "macros.vh"

module mini_core_rrv_wb
import mini_core_rrv_pkg::*;
(
    input  logic Clock,
    input  logic Rst,
    input  logic [31:0] AluOutQ102H,
    input  logic [31:0] PcQ102H,
    input  logic [31:0] PcPlus4Q102H,
    input var t_ctrl_wb Ctrl,
    output logic [31:0] RegWrDataQ102H,
    input logic [31:0] DMemRdRspQ102H

);
    logic [31:0] PostSxDMemRdDataQ102H;
    // Sign extend taking care of
    assign PostSxDMemRdDataQ102H[7:0]   =  Ctrl.ByteEnQ102H[0] ? DMemRdRspQ102H[7:0]             : 8'b0;
    assign PostSxDMemRdDataQ102H[15:8]  =  Ctrl.ByteEnQ102H[1] ? DMemRdRspQ102H[15:8]            :
                                           Ctrl.SignExtQ102H   ? {8{PostSxDMemRdDataQ102H[7]}}    : 8'b0;
    assign PostSxDMemRdDataQ102H[23:16] =  Ctrl.ByteEnQ102H[2] ? DMemRdRspQ102H[23:16]           :
                                           Ctrl.SignExtQ102H   ? {8{PostSxDMemRdDataQ102H[15]}}   : 8'b0;
    assign PostSxDMemRdDataQ102H[31:24] =  Ctrl.ByteEnQ102H[3] ? DMemRdRspQ102H[31:24]           :
                                           Ctrl.SignExtQ102H   ? {8{PostSxDMemRdDataQ102H[23]}}   : 8'b0;

    // ---- Select what write to the register file ----
    assign RegWrDataQ102H = (Ctrl.e_SelWrBackQ102H == WB_DMEM) ? PostSxDMemRdDataQ102H : // TODO - Conseder using unique case instead of priority mux, to improve timing by reduce number of logical steps for the mux out.
                            (Ctrl.e_SelWrBackQ102H == WB_ALU)  ? AluOutQ102H           :
                            (Ctrl.e_SelWrBackQ102H == WB_PC4)  ? PcPlus4Q102H          : 
                                                            32'b0;

endmodule