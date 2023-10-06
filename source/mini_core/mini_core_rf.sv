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

module mini_core_rf 
import common_pkg::*;
#(parameter RF_NUM_MSB) 
(
    input logic Clock,
    input logic Rst,
    // input control path
    input var t_ctrl_rf Ctrl,
    // input data path
    input  logic        ReadyQ102H,
    input  logic [31:0] PcQ101H,
    input  logic [31:0] ImmediateQ101H,
    input  logic [31:0] RegWrDataQ104H,
    // output data path
    output logic [31:0] PcQ102H,
    output logic [31:0] ImmediateQ102H,
    output logic [31:0] RegRdData1Q102H,
    output logic [31:0] RegRdData2Q102H
);


logic [RF_NUM_MSB:1][31:0]  Register;
logic                       MatchRd1AftrWrQ101H;
logic                       MatchRd2AftrWrQ101H;
logic [31:0]                RegRdData1Q101H;
logic [31:0]                RegRdData2Q101H;
//===================
//  Register File
//===================
//---- The Register File ----
 `MAFIA_EN_DFF(Register[Ctrl.RegDstQ104H] , RegWrDataQ104H , Clock , (Ctrl.RegWrEnQ104H && (Ctrl.RegDstQ104H!=5'b0)))
// ---- Read Register File ----
assign MatchRd1AftrWrQ101H = (Ctrl.RegSrc1Q101H == Ctrl.RegDstQ104H) && (Ctrl.RegWrEnQ104H);
assign RegRdData1Q101H = (Ctrl.RegSrc1Q101H == 5'b0) ? 32'b0                      : // Reading from Register[0] should result in '0
                         MatchRd1AftrWrQ101H         ? RegWrDataQ104H             : // forwards WrDataQ104H -> RdDataQ101H
                                                       Register[Ctrl.RegSrc1Q101H]; // Common Case - reading from Register file

assign MatchRd2AftrWrQ101H = (Ctrl.RegSrc2Q101H == Ctrl.RegDstQ104H) && (Ctrl.RegWrEnQ104H);
assign RegRdData2Q101H = (Ctrl.RegSrc2Q101H == 5'b0) ? 32'b0                      : // Reading from Register[0] should result in '0 
                         MatchRd2AftrWrQ101H         ? RegWrDataQ104H             : // forwards WrDataQ104H -> RdDataQ101H
                                                       Register[Ctrl.RegSrc2Q101H]; // Common Case - reading from Register file

`MAFIA_EN_DFF(ImmediateQ102H,  ImmediateQ101H,  Clock, ReadyQ102H)
`MAFIA_EN_DFF(PcQ102H,         PcQ101H,         Clock, ReadyQ102H)
`MAFIA_EN_DFF(RegRdData1Q102H, RegRdData1Q101H, Clock, ReadyQ102H)
`MAFIA_EN_DFF(RegRdData2Q102H, RegRdData2Q101H, Clock, ReadyQ102H)

endmodule