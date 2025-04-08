

`include "macros.vh"
import mini_core_di_pkg::*;

module mini_core_di_idu (
    input  logic        Clock,
    input  logic        Rst,

    // jmp feedback
    input  var t_ctrl_idu    Ctrl,

    input logic [31:0] PcQ101H,
    input logic [31:0] PcQ201H,

    input  logic        ReadyQ101H,
    input  logic [31:0] PreInstructionQ101H,

    input  logic        ReadyQ201H,
    input  logic [31:0] PreInstructionQ201H,

    output logic [31:0] PostPcQ101H,
    output logic [31:0] PreInstructionQ101H_issued,

    //output logic [31:0] PcQ200H, // we don't need it exposed, only used for memory request, we have that covered bu PcQ100H
    output logic [31:0] PostPcQ201H,
    output logic [31:0] PreInstructionQ201H_issued,

    output logic issue2ValidN
);


logic [31:0] InstructionBufferQ101H;
logic [31:0] PcBufferQ101H;
logic        BufferSel;
logic        BufferValid;
// logic        PreBufferSel;
logic        issue2ValidN_idu;
logic        HoldFlushBufferQ102;

logic [31:0] PrePcQ101H;
logic [31:0] PrePcQ201H;
logic [31:0] PreInstructionQ101H_idu;
logic [31:0] PreInstructionQ201H_idu;


assign PrePcQ101H = BufferSel ? PcBufferQ101H : PcQ101H;
assign PrePcQ201H = BufferSel ? PcQ101H       : PcQ201H;                    
assign PreInstructionQ101H_idu = BufferSel ? InstructionBufferQ101H : PreInstructionQ101H;
assign PreInstructionQ201H_idu = BufferSel ? PreInstructionQ101H    : PreInstructionQ201H;

idu idu (
        .PC1_in(PrePcQ101H),
        .PC2_in(PrePcQ201H),
        .instr1(PreInstructionQ101H_idu),
        .instr2(PreInstructionQ201H_idu),
        .issue_instr1(PreInstructionQ101H_issued),
        .issue_instr2(PreInstructionQ201H_issued),
        .PC1_out(PostPcQ101H),
        .PC2_out(PostPcQ201H),
        .issue2ValidN(issue2ValidN_idu)
);

assign issue2ValidN = issue2ValidN_idu && !(Ctrl.FlushBufferQ102H || HoldFlushBufferQ102);
assign BufferSel = BufferValid && !Ctrl.FlushBufferQ102H;

`MAFIA_EN_RST_DFF(InstructionBufferQ101H, PreInstructionQ201H_idu, Clock, issue2ValidN_idu && ReadyQ101H, Rst || Ctrl.FlushBufferQ102H)
`MAFIA_EN_RST_DFF(PcBufferQ101H, PrePcQ201H, Clock, issue2ValidN_idu && ReadyQ101H, Rst || Ctrl.FlushBufferQ102H)
`MAFIA_RST_DFF(BufferValid, issue2ValidN_idu && ReadyQ101H, Clock, Rst || Ctrl.FlushBufferQ102H)

`MAFIA_EN_RST_DFF(HoldFlushBufferQ102, Ctrl.FlushBufferQ102H && !HoldFlushBufferQ102, Clock, ReadyQ101H , Rst)

endmodule
