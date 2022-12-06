module test_tb ();
logic in_0;
logic in_1;
logic  out;
initial begin : assign_input
    in_0 = 1'b0;
    in_1 = 1'b0; // 0^0
    
#4 $display("XOR (%b, %b)= %b\n" ,in_0, in_1,out);
#4 in_1 = 1'b1; // 0^1
#4 $display("XOR (%b, %b)= %b\n" ,in_0, in_1,out);
#4 in_0 = 1'b1; 
#4 in_1 = 1'b0; // 1^0
#4 $display("XOR (%b, %b)= %b\n" ,in_0, in_1,out);
#4 in_0 = 1'b1; 
#4 in_1 = 1'b1; // 1^1
#4 $display("XOR (%b, %b)= %b\n" ,in_0, in_1,out);
#4 $finish;
end// initial
test test_xor (
    .in_0(in_0),
    .in_1(in_1),
    .out(out)
);





endmodule // test_tb
