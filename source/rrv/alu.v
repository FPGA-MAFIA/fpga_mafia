`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS ALU CORE FOR RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
// op-code - IR[30] + IR[14:12] 
// flag    - zero, less(unsigned), less(signed)
// 0000 - add
// 1000 - sub
// 0001 - sll
// 0010 - slt
// 0011 - sltu
// 0100 - xor
// 0101 - srl
// 1101 - sra
// 0110 - or
// 0111 - and
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module alu (
    input       [`FUNC_SIZE-1:0]   func_code,
    input       [`REG_WIDTH-1:0]   in1, in2,
    output reg  [`REG_WIDTH-1:0]   result,
    output      [`FLAGN-1 :0]      flag      
);

always @(*) begin
    case(func_code)
        `add     : result = in1 + in2;
        `sub     : result = in1 - in2;
        `sll     : result = in1 << in2;
        `slt     : 
                    if(flag[0])
                       result = 32'h00000001;
                    else
                       result = 32'h00000000;
        `sltu    : 
                    if(flag[1])
                       result = 32'h00000001;
                    else
                       result = 32'h00000000;
        `rxor    : result = in1 ^ in2;
        `srl     : result = in1 >> in2;
        `sra     : result = $signed(in1) >>> $signed(in2);
        `ror     : result = in1 | in2;
        `rand    : result = in1 & in2;
         default : result = 32'h00000000;
        
    endcase    

end

assign flag[2] = (in1 == in2) ? 1 : 0;
assign flag[1] = (in1 < in2)  ? 1 : 0;
assign flag[0] = (in1[31] & !in2[31])    ? 1 :  
                    (!in1[31] & in2[31]) ? 0 :
                    (in1 < in2)          ? 1 : 0;                 

endmodule
