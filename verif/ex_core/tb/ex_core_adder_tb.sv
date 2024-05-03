// This is a testbench for the 4-bit adder module
module ex_core_adder_tb;
    reg [3:0] a;
    reg [3:0] b;
    wire [3:0] sum;

    // Instantiate the adder
    ex_core_adder u1 (
        .a(a),
        .b(b),
        .sum(sum)
    );

    // Apply stimulus
    initial begin
        a = 4'b0001; // 1
        b = 4'b0011; // 3
        #10;
        if (sum !== 4'b0100) // 4
            $display("Adder test failed!");
        else
            $display("the result of %h + %h is %h", a, b, sum);
            $display("Adder test passed!");

        $finish; // End the simulation
    end
endmodule