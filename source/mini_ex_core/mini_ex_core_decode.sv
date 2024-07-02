

`include "macros.vh"

module mini_ex_core_decode
import mini_ex_core_pkg::*;
(
    input logic             Clock,
    input logic             Rst,
    input logic [31:0]      instrQ101H,
    output var t_instr_type instr_type,
    output [3:0]            instr
    output logic            aluop,
    output var              t_rg_read
    out
);

var t_instr_fields instr_fieldsQ101H

assign instr_fieldsQ101H.opcode    = instrQ101H[6:0];
assign instr_fieldsQ101H.rd_idx    = instrQ101H[11:7];
assign instr_fieldsQ101H.func3     = instrQ101H[14:12];
assign instr_fieldsQ101H.rs1_idx   = instrQ101H[19:15];
assign instr_fieldsQ101H.rs2_idx   = instrQ101H[24:20];
assign instr_fieldsQ101H.func7     = instrQ101H[31:25];
assign instr_fieldsQ101H.immItype  = instrQ101H[31:20];
assign instr_fieldsQ101H.immStype5 = instrQ101H[11:7];
assign instr_fieldsQ101H.immStype7 = instrQ101H[31:25];
assign instr_fieldsQ101H.immUtype  = instrQ101H[31:12];

always_comb begin
    instr_type = instr_fieldsQ101H.opcode
    case (instr_type)
            I_TYPE1: begin
            I_TYPE2: begin 
            I_TYPE3: begin 
            R_TYPE : begin
                instr = {instr_fieldsQ101H.func3 , instr_fieldsQ101H.func7(5)};
                aluop = instr;
            B_TYPE : begin 
            S_TYPE : begin
            J_TYPE : begin 
end

endmodule