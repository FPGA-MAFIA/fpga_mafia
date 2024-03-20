`include "macros.vh"

module mini_core_rrv_alu
import mini_core_rrv_pkg::*;
(
    input logic Clock, 
    input logic Rst, 
    input logic [31:0] PcQ101H,
    input var t_ctrl_alu Ctrl,
    output logic [31:0] AluOutQ101H,
    output logic [31:0] AluOutQ102H,
    output logic BranchCondMetQ101H,
    output logic [31:0] PcQ102H
);

    always_comb begin : alu_op
        case(Ctrl.AluOpQ101H)
            ADD: AluOutQ101H = Ctrl.AluIn1Q101H + Ctrl.AluIn2Q101H;
            SUB: AluOutQ101H = Ctrl.AluIn1Q101H - Ctrl.AluIn2Q101H;
            SLT: AluOutQ101H = ($signed(Ctrl.AluIn1Q101H) < $signed(Ctrl.AluIn2Q101H)) ? 1 : 0;
            SLTU: AluOutQ101H = (Ctrl.AluIn1Q101H < Ctrl.AluIn2Q101H) ? 1 : 0;
            SLL: AluOutQ101H = Ctrl.AluIn1Q101H << Ctrl.AluIn2Q101H[4:0];
            SRL: AluOutQ101H = Ctrl.AluIn1Q101H >> Ctrl.AluIn2Q101H[4:0];
            SRA: AluOutQ101H = $signed(Ctrl.AluIn1Q101H) >>> Ctrl.AluIn2Q101H[4:0];
            XOR: AluOutQ101H = Ctrl.AluIn1Q101H ^ Ctrl.AluIn2Q101H;
            OR: AluOutQ101H = Ctrl.AluIn1Q101H | Ctrl.AluIn2Q101H;
            AND: AluOutQ101H = Ctrl.AluIn1Q101H & Ctrl.AluIn2Q101H;
            default: AluOutQ101H = Ctrl.AluIn1Q101H + Ctrl.AluIn2Q101H;   
        endcase
    end

    always_comb begin : branch_comp
    // Check branch condition
    case ({Ctrl.BranchOpQ101H})
        BEQ     : BranchCondMetQ101H =  (Ctrl.AluIn1Q101H == Ctrl.AluIn2Q101H);                  // BEQ
        BNE     : BranchCondMetQ101H = !(Ctrl.AluIn1Q101H == Ctrl.AluIn2Q101H);                  // BNE
        BLT     : BranchCondMetQ101H =  ($signed(Ctrl.AluIn1Q101H) < $signed(Ctrl.AluIn2Q101H)); // BLT
        BGE     : BranchCondMetQ101H = !($signed(Ctrl.AluIn1Q101H) < $signed(Ctrl.AluIn2Q101H)); // BGE
        BLTU    : BranchCondMetQ101H =  (Ctrl.AluIn1Q101H < Ctrl.AluIn2Q101H);                   // BLTU
        BGEU    : BranchCondMetQ101H = !(Ctrl.AluIn1Q101H < Ctrl.AluIn2Q101H);                   // BGEU
        default : BranchCondMetQ101H = 1'b0;
    endcase
    end

    `MAFIA_DFF_RST(AluOutQ102H, AluOutQ101H, Clock, Rst)
    `MAFIA_DFF_RST(PcQ102H, PcQ101H, Clock, Rst)

endmodule