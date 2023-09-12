`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS IMM GENERATOR AS PART OF DECODE STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
///////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module imm_generator(
    input      [`INST_WIDTH-1:0]  instruction,
    output reg [`IMM_ID-1:0]      immidiate
);

   always @(*) begin
    immidiate = 32'h00000000;
    case(`op_code)
        `i_type_arithm: 
            immidiate = {{20{`msb}},`imm_i};
        `s_type:
            immidiate = {{20{`msb}},`imm_sl,`imm_sr};
        `i_type_dmem:
            immidiate = {{20{`msb}},`imm_i};
        `b_type: 
            immidiate = {{20{`msb}}, `b_bit, `imm_bl, `imm_br, 1'b0};
        `i_type_jalr:
            immidiate = {{20{`msb}},`imm_i};  
        `j_type:
            immidiate = {{12{`msb}}, `imm_jr, `l_bit, `imm_jl, 1'b0};
        `u_type_auipc: 
            immidiate = {`imm_u, {12{1'b0}}};
        `u_type_lui:
            immidiate = {`imm_u, {12{1'b0}}};
    endcase
   end 

endmodule
