module ALU_TB();

   // Define signals
   logic [31:0] operand1, operand2;
   logic [2:0] op;
   logic [31:0] result;
   logic zero;
   
   // Instantiate ALU
   ALU dut(.operand1(operand1), .operand2(operand2),
           .op(op), .result(result), .zero(zero));
   
   // Apply stimulus
   initial begin
      // Test case 1: ADD operation
      operand1 = 10;
      operand2 = 5;
      op = 3'b000; // ADD
      #10; // Delay for combinational logic to settle
      // Verify result
      if (result !== 15) $display("ADD test failed!");
      else $display("ADD test passed!");
   end
   
   // Other test cases...
   
endmodule
