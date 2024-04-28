module ex_core_alu_tb();

   // Define signals
   logic [31:0] operand1, operand2;
   logic [2:0] op;
   logic [31:0] result;
   logic zero;
   
   // Instantiate ALU
   ex_core_alu dut(.operand1(operand1), .operand2(operand2),
           .op(op), .result(result), .zero(zero));
   
   // Apply stimulus
   initial begin
      // Test case 1: ADD operation
      operand1 = 10;
      operand2 = 5;
      op = 3'b000; // ADD
      #10; // Delay for combinational logic to settle
      $display("The result of %1h ADD %1h is %1h", operand1, operand2, result);
      // Verify result
      //assert (result === 15) else $error("ADD test failed!");

      // Other test cases...
   end
   
   // Random stimulus
   initial begin
      #10
      repeat (10) begin
         operand1 = $urandom_range(0, 10);
         operand2 = $urandom_range(0, 10);
         op = $urandom_range(0, 7); // Generate a random operation code
         #10;
         $display("The result of %1h and %1h with op %1h is %1h", operand1, operand2, op, result);
         // Check result (this will depend on the operation)
      end
      $finish;
   end

   parameter V_TIMEOUT = 10000;

   initial begin: detec_timeout
      #V_TIMEOUT
      $error("time out reached");
      $finish;
   end

endmodule