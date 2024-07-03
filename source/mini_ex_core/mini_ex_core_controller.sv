

`include "macros.vh"

module mini_ex_core_controller
import mini_ex_core_pkg::*;
(
    input logic                 Clock,
    input logic                 Rst,
    input var t_op_type         OpType,
    output var  t_contoller_out CntrlOut
);

logic WbMuxSelQ101H;
logic JmpEnableQ101H;
//current cycle is Q101H - getting info from decode
//Info to WB Mux + RegWrEnable needs to go into DFF (Q102H)
// clock work
always_comb begin 
    if (Rst) begin
        JmpEnableQ101H            = 1'b0;
        CntrlOut.RegWrEnableQ101H = 1'b0;
        CntrlOut.AluMux1SelQ101H  = 1'b0;
        CntrlOut.AluMux2SelQ101H  = 1'b0;
        WbMuxSelQ101H             = 2'b01; // Default to pc+4. 0 -> AluOut , 1-> pc+4, 2-> MemOut
    end else begin
        case (OpType)
            I_TYPE: begin //Arithmetic
                JmpEnableQ101H            = 1'b0; // No jump for I_TYPE1
                CntrlOut.RegWrEnableQ101H = 1'b1; // Enable register write
                CntrlOut.AluMux1SelQ101H  = 1'b0; // ALU MUX1 select is rs1
                CntrlOut.AluMux2SelQ101H  = 1'b1; // ALU MUX2 select is immediate
                CntrlOut.MemWrEnableQ101H = 1'b0; // No mem write
                WbMuxSelQ101H             = 2'b00; // Write back from AluOut
            end
            L_TYPE: begin //Load
                JmpEnableQ101H            = 1'b0; // No jump for I_TYPE2
                CntrlOut.RegWrEnableQ101H = 1'b1; // Enable register write
                CntrlOut.AluMux1SelQ101H  = 1'b0; // ALU MUX1 select is rs1
                CntrlOut.AluMux2SelQ101H  = 1'b1; // ALU MUX2 select is immediate
                CntrlOut.MemWrEnableQ101H = 1'b0; // No mem write
                WbMuxSelQ101H             = 2'b10; // Write back from Mem
            end
            R_TYPE: begin
                JmpEnableQ101H            = 1'b0; // No jump for R_TYPE
                CntrlOut.RegWrEnableQ101H = 1'b1; // Enable register write
                CntrlOut.AluMux1SelQ101H  = 1'b0; // ALU MUX1 select is rs1
                CntrlOut.AluMux2SelQ101H  = 1'b0; // ALU MUX2 select is rs2
                CntrlOut.MemWrEnableQ101H = 1'b0; // No mem write
                WbMuxSelQ101H             = 2'b00; // Write back from AluOut
            end
            B_TYPE: begin //branch
                JmpEnableQ101H            = 1'b1; // Jump for B_TYPE
                CntrlOut.RegWrEnableQ101H = 1'b0; // Disable register write
                CntrlOut.AluMux1SelQ101H  = 1'b1; // ALU MUX1 select is PC
                CntrlOut.AluMux2SelQ101H  = 1'b1; // ALU MUX2 select is immediate
                CntrlOut.MemWrEnableQ101H = 1'b0; // No mem write
                WbMuxSelQ101H             = 2'b00; // Default to AluOut
            end
            S_TYPE: begin // store
                JmpEnableQ101H            = 1'b0; // No jump for S_TYPE
                CntrlOut.RegWrEnableQ101H = 1'b0; // Disable register write
                CntrlOut.AluMux1SelQ101H  = 1'b0; // ALU MUX1 select is rs1
                CntrlOut.AluMux2SelQ101H  = 1'b1; // ALU MUX2 select is immediate
                CntrlOut.MemWrEnableQ101H = 1'b1; // Mem write
                WbMuxSelQ101H             = 2'b00; // Default to AluOut
            end
            J_TYPE: begin // jal
                JmpEnableQ101H            = 1'b1; // Enable jump for J_TYPE
                CntrlOut.RegWrEnableQ101H = 1'b1; // Enable register write
                CntrlOut.AluMux1SelQ101H  = 1'b1; // ALU MUX1 select is pc
                CntrlOut.AluMux2SelQ101H  = 1'b1; // ALU MUX2 select is immediate
                CntrlOut.MemWrEnableQ101H = 1'b0; // No mem write
                WbMuxSelQ101H             = 2'b01; // Default to pc+4
            end
            JR_TYPE: begin // jalr
                JmpEnableQ101H            = 1'b1; // Enable jump for J_TYPE
                CntrlOut.RegWrEnableQ101H = 1'b1; // Enable register write
                CntrlOut.AluMux1SelQ101H  = 1'b0; // ALU MUX1 select is rs1
                CntrlOut.AluMux2SelQ101H  = 1'b1; // ALU MUX2 select is immediate
                CntrlOut.MemWrEnableQ101H = 1'b0; // No mem write
                WbMuxSelQ101H             = 2'b01; // Default to pc+4
            end
            default: begin
                JmpEnableQ101H            = 1'b0; // Default: No jump
                CntrlOut.RegWrEnableQ101H = 1'b0; // Default: Disable register write
                CntrlOut.AluMux1SelQ101H  = 1'b0; // Default: ALU MUX1 select is rs1
                CntrlOut.AluMux2SelQ101H  = 1'b0; // Default: ALU MUX2 select is rs2
                CntrlOut.MemWrEnableQ101H = 1'b0; // No mem write
                WbMuxSelQ101H             = 2'b00; // Default: Default to ALU out
            end
        endcase
    end
end
 `MAFIA_DFF(CntrlOut.JmpEnableQ100H, JmpEnableQ101H, Clock);
 `MAFIA_DFF(CntrlOut.WbMuxSelQ102H,  WbMuxSelQ101H, Clock);

endmodule
