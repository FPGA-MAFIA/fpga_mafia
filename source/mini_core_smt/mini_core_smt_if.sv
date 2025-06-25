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
    input  logic [31:0] AluOutQ102H,
    input  logic        CurrThread,
    output logic [31:0] PcQ100H,
    output logic [31:0] PcQ101H
);

logic [31:0] PcPlus4Q100H;
logic [31:0] NextPcQnnnH;

// Per-thread program counters
logic [31:0] PC_thread0;
logic [31:0] PC_thread1;


// Send current thread PC downstream (to decode stage)
//assign PcQ100H = (CurrThread == 1'b0) ? PC_thread0 : PC_thread1;

// Update selected thread's PC
always_ff @(posedge Clock) begin
    if (Rst) begin
        PC_thread0 <= 32'h00000000;
        PC_thread1 <= 32'h00008000;
    end else begin
        if (CurrThread == 1'b0)
            PC_thread0 <= PC_thread0 + 3'h4;
        else
            PC_thread1 <= PC_thread1 + 3'h4;
    end
end

assign PcPlus4Q100H = (CurrThread == 1'b0) ? (PC_thread0 ) : (PC_thread1 );
assign NextPcQnnnH  = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H : PcPlus4Q100H;



`MAFIA_EN_RST_DFF(PcQ100H, NextPcQnnnH, Clock, ReadyQ100H, Rst)
//`MAFIA_EN_RST_DFF(PcQ100H, NextPcQnnnH, Clock, 1'b1, Rst)
// Q100H to Q101H Flip Flops. 
`MAFIA_EN_DFF(PcQ101H, PcQ100H, Clock, ReadyQ101H)
//`MAFIA_EN_DFF(PcQ101H, PcQ100H, Clock, 1'b1)

endmodule