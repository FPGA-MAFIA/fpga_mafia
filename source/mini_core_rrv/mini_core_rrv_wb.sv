`include "macros.vh"

module mini_core_rrv_wb
import mini_core_rrv_pkg::*;
(
    input  logic Clock,
    input  logic Rst,
    input  logic [31:0] AluOutQ102H,
    input  logic [31:0] PcQ102H,
    input var t_ctrl_wb Ctrl,
    output logic [31:0] RegWrDataQ102H,
    input logic [31:0] DMemRdRspQ102H

);
    assign RegWrDataQ102H = AluOutQ102H;

endmodule