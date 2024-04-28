module ALU(input logic [31:0] operand1,
           input logic [31:0] operand2,
           input logic [2:0] op,
           output logic [31:0] result,
           output logic zero);

   always_comb begin
      case(op)
         3'b000: result = operand1 + operand2; // ADD
         3'b001: result = operand1 - operand2; // SUB
         // Other operations...
         default: result = 0; // Default case
      endcase
      zero = (result == 0);
   end

endmodule
