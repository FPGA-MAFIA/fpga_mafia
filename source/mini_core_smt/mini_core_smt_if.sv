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

`include "macros.vh"

module mini_core_smt_if
import mini_core_smt_pkg::*;
(
    input  logic        Clock,
    input  logic        Rst,
    input  var t_ctrl_if    Ctrl,
    input  logic        ReadyQ100H,
    input  logic        ReadyQ101H,
    input  logic [31:0] AluOutQ103H,
    input  logic        CurrThread,
    input  logic        ThreadIDQ100H,
    input  logic        ThreadIDQ102H,
    output logic [31:0] PcQ100H,
    output logic [31:0] PcQ101H
);

logic [31:0] PC_thread0, PC_thread1;
logic [31:0] SelectedPC;
logic [31:0] NextPcQnnnH;
logic [31:0] AluOut; // added

// Pick PC based on current thread
assign SelectedPC = (CurrThread == 1'b0) ? (PC_thread0) : (PC_thread1) ;

// Compute PC+4 or branch target
assign NextPcQnnnH = ( Ctrl.SelNextPcAluOutQ102H ) ? AluOutQ103H : (SelectedPC + 3'h4) ;

// Feed to pipeline (only if ReadyQ100H)
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQnnnH, Clock, ReadyQ100H, Rst)

// Register PCQ100H to Q101H
`MAFIA_EN_DFF(PcQ101H, PcQ100H, Clock, ReadyQ101H)

// Update thread PC after fetch success
always_ff @(posedge Clock or posedge Rst) begin
    if (Rst) begin
        PC_thread0 <= 32'h00000000;
        PC_thread1 <= 32'h00000200;
    end else if (ReadyQ100H) begin
        if (CurrThread == 1'b0)
            PC_thread0 <= NextPcQnnnH;
        else
            PC_thread1 <= NextPcQnnnH;
    end
end

endmodule