// ./build.py -sim -dut ex_core -top ex_core_alu_tb -hw -clean
`include "ex_core_pkg.sv"

module ex_core_alu
import ex_core_pkg::*;
(
   input logic [31:0] operand1,
   input logic [31:0] operand2,
   input var t_ctrl_alu Ctrl,
   output logic [31:0] result,
   output logic zero
);

   always_comb begin
      case(Ctrl.AluOp)
         ADD : result = operand1 +   operand2;
         SUB : result = operand1 -   operand2;
         AND : result = operand1 &   operand2;
         OR  : result = operand1 |   operand2;
         XOR : result = operand1 ^   operand2;
         SLL : result = operand1 <<  operand2;
         SRL : result = operand1 >>  operand2;
         SRA : result = operand1 >>> operand2;
         SLT : result = ($signed(operand1) < $signed(operand2)) ? 1 : 0;
         SLTU: result = ($unsigned(operand1) < $unsigned(operand2)) ? 1 : 0;
         default: result = 0; // Default case
      endcase
      zero = (result == 0);
   end

endmodule
