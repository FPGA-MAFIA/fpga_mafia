//========================
// basic example of ALU
// =======================

`include "macros.vh"

module mini_ex_alu
import mini_ex_core_pkg::*;
(
    input logic          Clock,
    input logic          Rst,
    input logic [31:0]   PcQ101H,
    input var t_alu_ctrl Ctrl,
    output logic [31:0]  AluOutQ102H,
    output logic [31:0]  PcQ102H

);

    always_comb begin: main_alu_mux
        case(Ctrl.AluOp)
            ADD     : Ctrl.AluOutQ101H = Ctrl.RegSrc1Q101H + Ctrl.RegSrc2Q101H;
            SLT     : Ctrl.AluOutQ101H = {31'b0, ($signed(Ctrl.RegSrc1Q101H) < $signed(Ctrl.RegSrc2Q101H))}; // SLT
            SLTU    : Ctrl.AluOutQ101H = {31'b0 , Ctrl.RegSrc1Q101H < Ctrl.RegSrc2Q101H};                    // SLTU
            default : Ctrl.AluOutQ101H = Ctrl.RegSrc1Q101H + Ctrl.RegSrc2Q101H;
        endcase
    end

    logic [31:0] NextPcQ101H;
    assign NextPcQ101H = PcQ101H  + 32'h4; // TODO - remove

    `MAFIA_DFF(AluOutQ102H, Ctrl.AluOutQ101H, Clock)
    `MAFIA_DFF(PcQ102H, NextPcQ101H, Clock)


endmodule