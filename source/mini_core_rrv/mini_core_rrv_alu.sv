`include "macros.vh"

module mini_core_rrv_alu
import mini_core_rrv_pkg::*;
(
    input logic Clock, 
    input logic Rst, 
    input logic [31:0]   PcQ101H,
    input var t_ctrl_alu Ctrl,
    input logic [31:0]   PreRegRdData1Q101H,
    input logic [31:0]   PreRegRdData2Q101H,
    input logic [31:0]   ImmediateQ101H,
    output logic [31:0]  AluOutQ101H,
    output logic [31:0]  AluOutQ102H,
    output logic [31:0]  DMemWrDataQ101H,
    output logic         BranchCondMetQ101H,
    output logic [31:0]  PcQ102H,
    output logic [31:0]  PcPlus4Q102H
);

     logic  DataHazard1Q101H, DataHazard2Q101H;
     logic [31:0] RegRdData1Q101H, RegRdData2Q101H;
     logic [31:0] AluIn1Q101H, AluIn2Q101H;

    // data hazard detection and handaling
    assign DataHazard1Q101H = (Ctrl.RegSrc1Q101H == Ctrl.RegDstQ102H) & (Ctrl.RegWrEnQ102H) & (Ctrl.RegSrc1Q101H != 5'b0);
    assign DataHazard2Q101H = (Ctrl.RegSrc2Q101H == Ctrl.RegDstQ102H) & (Ctrl.RegWrEnQ102H) & (Ctrl.RegSrc2Q101H != 5'b0);

    assign RegRdData1Q101H  = (DataHazard1Q101H) ? AluOutQ102H : PreRegRdData1Q101H;
    assign RegRdData2Q101H  = (DataHazard2Q101H) ? AluOutQ102H : PreRegRdData2Q101H;

    assign AluIn1Q101H      = (Ctrl.SelAluPcQ101H)  ? PcQ101H : RegRdData1Q101H;
    assign AluIn2Q101H      = (Ctrl.ImmInstrQ101H)  ? ImmediateQ101H  : RegRdData2Q101H;
                                                              

    always_comb begin : alu_op
        case(Ctrl.AluOpQ101H)
            ADD: AluOutQ101H = AluIn1Q101H + AluIn2Q101H;
            SUB: AluOutQ101H = AluIn1Q101H - AluIn2Q101H;
            SLT: AluOutQ101H = ($signed(AluIn1Q101H) < $signed(AluIn2Q101H)) ? 1 : 0;
            SLTU: AluOutQ101H = (AluIn1Q101H < AluIn2Q101H) ? 1 : 0;
            SLL: AluOutQ101H = AluIn1Q101H << AluIn2Q101H[4:0];
            SRL: AluOutQ101H = AluIn1Q101H >> AluIn2Q101H[4:0];
            SRA: AluOutQ101H = $signed(AluIn1Q101H) >>> AluIn2Q101H[4:0];
            XOR: AluOutQ101H = AluIn1Q101H ^ AluIn2Q101H;
            OR: AluOutQ101H = AluIn1Q101H | AluIn2Q101H;
            AND: AluOutQ101H = AluIn1Q101H & AluIn2Q101H;
            default: AluOutQ101H = AluIn1Q101H + AluIn2Q101H;   
        endcase
    end

    always_comb begin : branch_comp
    // Check branch condition
    case ({Ctrl.BranchOpQ101H})
        BEQ     : BranchCondMetQ101H =  (RegRdData1Q101H == RegRdData2Q101H);                  // BEQ
        BNE     : BranchCondMetQ101H = !(RegRdData1Q101H == RegRdData2Q101H);                  // BNE
        BLT     : BranchCondMetQ101H =  ($signed(RegRdData1Q101H) < $signed(RegRdData2Q101H)); // BLT
        BGE     : BranchCondMetQ101H = !($signed(RegRdData1Q101H) < $signed(RegRdData2Q101H)); // BGE
        BLTU    : BranchCondMetQ101H =  (RegRdData1Q101H < RegRdData2Q101H);                   // BLTU
        BGEU    : BranchCondMetQ101H = !(RegRdData1Q101H < RegRdData2Q101H);                   // BGEU
        default : BranchCondMetQ101H = 1'b0;
    endcase
    end

    // to dmem
    assign DMemWrDataQ101H = RegRdData2Q101H;
    
    `MAFIA_DFF_RST(AluOutQ102H, AluOutQ101H, Clock, Rst)
    `MAFIA_DFF_RST(PcQ102H, PcQ101H, Clock, Rst)
    `MAFIA_DFF_RST(PcPlus4Q102H, PcQ101H + 32'h4, Clock, Rst)

endmodule

