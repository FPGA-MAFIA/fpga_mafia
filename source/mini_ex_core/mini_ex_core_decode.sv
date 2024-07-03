`include "macros.vh"

module mini_ex_core_decode
import mini_ex_core_pkg::*;
(
    input logic         Clock,
    input logic         Rst,
    input logic [31:0]  instrQ101H,
    output logic [6:0]  OperationTypeQ101H,
    output logic [3:0]  aluopQ101H,
    output logic [4:0]  Rg1IdxQ101H,
    output logic [4:0]  Rg2IdxQ101H,
    output logic [4:0]  RdIdxQ101H
);

t_instr_fields instr_fieldsQ101H; // Declare t_instr_fields variable
assign instr_fieldsQ101H.opcode    = instrQ101H[6:0];
assign instr_fieldsQ101H.rd_idx    = instrQ101H[11:7];
assign instr_fieldsQ101H.func3     = instrQ101H[14:12];
assign instr_fieldsQ101H.rs1_idx   = instrQ101H[19:15];
assign instr_fieldsQ101H.rs2_idx   = instrQ101H[24:20];
assign instr_fieldsQ101H.func7     = instrQ101H[31:25];

logic [3:0] aluop; // Declare t_alu_op variable
always_comb begin
    case (instr_fieldsQ101H.opcode)
        R_TYPE: begin
            aluop = {instr_fieldsQ101H.func7[5], instr_fieldsQ101H.func3};
        end 
        default: begin
            aluop = ADD;
        end
    endcase
end

assign OperationTypeQ101H = instr_fieldsQ101H.opcode;
assign aluopQ101H = aluop;
assign RdIdxQ101H = instr_fieldsQ101H.rd_idx;
assign Rg1IdxQ101H = instr_fieldsQ101H.rs1_idx;
assign Rg2IdxQ101H = instr_fieldsQ101H.rs2_idx;

endmodule
