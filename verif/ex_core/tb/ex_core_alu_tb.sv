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
      assert (result === 15) else $error("ADD test failed!");

      // Other test cases...
   end
   
   // Random stimulus
   initial begin
      repeat (100) begin
         operand1 = $random;
         operand2 = $random;
         op = $random % 8; // Generate a random operation code
         #10;
         // Check result (this will depend on the operation)
      end
   end

endmodule