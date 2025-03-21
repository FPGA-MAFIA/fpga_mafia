

`include "macros.vh"
import mini_core_pkg::*;

module mini_core_di_idu (
    input  logic        Clock,
    input  logic        Rst,

    // jmp feedback
    input  var t_ctrl_if    Ctrl,

    input  logic [31:0] AluOutQ102H,
    input  logic        ReadyQ100H,
    input  logic        ReadyQ101H,

    input  logic        ReadyQ201H,
    input  logic        ReadyQ200H,

    output logic [31:0] PcQ100H,
    output logic [31:0] PcQ101H,

    output logic [31:0] PcQ200H,
    output logic [31:0] PcQ201H
);

logic [31:0] PcPlus8Q100H;
logic [31:0] PcPlus8Q200H;

logic [31:0] iduPCQ100H;
logic [31:0] iduPCQ200H;
logic [31:0] NextPcQ1nnH;
logic [31:0] NextPcQ2nnH;

assign PcPlus8Q100H = PcQ100H + 3'h8;
assign PcPlus8Q200H = PcQ200H + 3'h8;
idu idu (
        .instr1(PcPlus8Q100H),
        .instr2(PcPlus8Q200H),
        .issue_instr1(iduPCQ100H)
        .issue_instr2(iduPCQ200H)
);

assign NextPcQ1nnH  = Ctrl.SelNextPcAluOutQ102H ? AluOutQ102H : iduPCQ100H;
assign NextPcQ2nnH  = iduPCQ200H;
`MAFIA_EN_RST_DFF(PcQ100H, NextPcQ1nnH, Clock, ReadyQ100H, Rst)
`MAFIA_EN_RST_DFF(PcQ200H, NextPcQ2nnH, Clock, ReadyQ200H, Rst)

// Q100H to Q101H Flip Flops. 
`MAFIA_EN_DFF(PcQ101H, PcQ100H, Clock, ReadyQ101H)
`MAFIA_EN_DFF(PcQ201H, PcQ200H, Clock, ReadyQ201H)

endmodule
