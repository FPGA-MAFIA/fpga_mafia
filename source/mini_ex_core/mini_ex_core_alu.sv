//========================
// basic example of ALU
// =======================

`include "macros.vh"

module mini_ex_core_alu
    import mini_ex_core_pkg::*;
(
    input logic          Clock,
    input logic          Rst,
    input var t_alu_in   AluInputs,
    output logic [31:0]  AluOutQ102H
);
    logic [31:0] AluOutQ101H;

    always_comb begin: main_alu_mux
        case (AluInputs.AluOp)
            ADD  : AluOutQ101H = AluInputs.RegSrc1Q101H + AluInputs.RegSrc2Q101H;
            SUB  : AluOutQ101H = AluInputs.RegSrc1Q101H - AluInputs.RegSrc2Q101H;
            SLT  : AluOutQ101H = {31'b0, ($signed(AluInputs.RegSrc1Q101H) < $signed(AluInputs.RegSrc2Q101H))}; 
            SLTU : AluOutQ101H = {31'b0, AluInputs.RegSrc1Q101H < AluInputs.RegSrc2Q101H};
            SLL  : AluOutQ101H = AluInputs.RegSrc1Q101H << AluInputs.RegSrc2Q101H;
            SRL  : AluOutQ101H = AluInputs.RegSrc1Q101H >> AluInputs.RegSrc2Q101H;
            SRA  : AluOutQ101H = $signed(AluInputs.RegSrc1Q101H) >>> AluInputs.RegSrc2Q101H;
            XOR  : AluOutQ101H = AluInputs.RegSrc1Q101H ^ AluInputs.RegSrc2Q101H;
            OR   : AluOutQ101H = AluInputs.RegSrc1Q101H | AluInputs.RegSrc2Q101H;
            AND  : AluOutQ101H = AluInputs.RegSrc1Q101H & AluInputs.RegSrc2Q101H; 
            default : AluOutQ101H = 32'b0;
        endcase
    end

    `MAFIA_DFF(AluOutQ102H, AluOutQ101H, Clock);

endmodule
