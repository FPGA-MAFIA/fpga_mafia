// ./build.py -sim -dut ex_core -top ex_core_alu_tb -hw -clean
module ex_core_alu(input logic [31:0] operand1,
           input logic [31:0] operand2,
           input logic [3:0] op,
           output logic [31:0] result,
           output logic zero);

   always_comb begin
      case(op)
         4'b0000: result = operand1 + operand2; // ADD
         4'b0001: result = operand1 - operand2; // SUB
         4'b0010: result = operand1 & operand2; // AND
         4'b0011: result = operand1 | operand2; // OR
         4'b0100: result = operand1 ^ operand2; // XOR
         4'b0101: result = operand1 << operand2; // SLL
         4'b0110: result = operand1 >> operand2; // SRL
         4'b0111: result = operand1 >>> operand2; // SRA
         4'b1000: result = ($signed(operand1) < $signed(operand2)) ? 1 : 0; // SLT
         4'b1001: result = ($unsigned(operand1) < $unsigned(operand2)) ? 1 : 0; // SLTU
         default: result = 0; // Default case
      endcase
      zero = (result == 0);
   end

endmodule
