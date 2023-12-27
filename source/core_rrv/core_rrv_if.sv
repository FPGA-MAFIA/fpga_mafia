//-----------------------------------------------------------------------------
// Title            : 
// Project          : mafia_asap
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Adviser          : Amichai Ben-David
// Created          : 7/2023
//-----------------------------------------------------------------------------

`include "macros.sv"

module core_rrv_if 
import common_pkg::*;
(
    input  logic                Clock,
    input  logic                Rst,
    input  logic                RstPc,
    input  var t_ctrl_if        Ctrl,
    input  logic                ReadyQ100H,
    input  logic                ReadyQ101H,
    input  var t_csr_pc_update  CsrPcUpdateQ102H,
    input  logic [31:0]         AluOutQ102H,
    output logic [31:0]         PcQ100H,
    output logic [31:0]         PcQ101H
);

logic [31:0] PcPlus4Q100H;
logic [31:0] NextPcQnnnH;
assign PcPlus4Q100H = PcQ100H + 3'h4;

assign NextPcQnnnH = CsrPcUpdateQ102H.InterruptJumpQ102H  ? CsrPcUpdateQ102H.InterruptJumpAddressQ102H         :
                     CsrPcUpdateQ102H.InteruptReturnQ102H ? CsrPcUpdateQ102H.InteruptReturnAddressQ102H + 3'h4 :
                     Ctrl.SelNextPcAluOutQ102H            ? AluOutQ102H                                        :
                                                            PcPlus4Q100H;
//assign NextPcQnnnH  = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H : PcPlus4Q100H;
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQnnnH, Clock, ReadyQ100H, Rst | RstPc)
// Q100H to Q101H Flip Flops. 
`MAFIA_EN_DFF(PcQ101H, PcQ100H, Clock, ReadyQ101H)

endmodule

