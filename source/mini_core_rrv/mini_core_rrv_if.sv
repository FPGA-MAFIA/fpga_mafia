//=====================================
// Instruction Fetch stage Q100H
//=====================================

`include "macros.vh"

module mini_core_if
import mini_core_rrv_pkg::*;
(
    input logic         Clock,
    input logic         Rst,
    input var t_ctrl_if Ctrl,
    input logic [31:0]  AluOutQ101H,
    output logic [31:0] PcQ100H,  // to I_MEM
    output logic [31:0] PcQ101H  // to Q101H stage
);

    logic [31:0] NextPcQ100H;

    // pc value can be updaded also when branch or jump occured
    assign NextPcQ100H = (Ctrl.SelNextPcAluOutQ101H) ? AluOutQ101H : PcQ100H + 32'h4;
    `MAFIA_DFF_RST(PcQ100H, NextPcQ100H, Clock, Rst)
    `MAFIA_DFF(PcQ101H, PcQ100H, Clock)


endmodule