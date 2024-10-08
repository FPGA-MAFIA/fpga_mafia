module systolic_array_net_tb;
import mini_core_accel_pkg::*;

// ./build.py -dut mini_core_accel -top systolic_array_net_tb -hw -sim
logic        clk;
logic        rst;
logic        first_done;
logic [31:0] weights;
logic [31:0] activation;
logic        valid;
logic        start;

t_pe_results pe_results;

// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen

systolic_array_net systolic_array_net
(
    .clk(clk),
    .rst(rst),
    .weights(weights),     
    .activation(activation),  
    .first_done(first_done),
    .start(start),
    .pe_results(pe_results),  
    .valid(valid)       
);

initial begin: main_tb
    rst   = 1;
    start = 1;
    #50
    @(posedge clk);
    first_done       = 0;
    rst              = 0;

    activation = 32'h00_00_00_04;
    weights    = 32'h00_00_00_0E;
    #10
    @(posedge clk);

    activation = 32'h00_00_08_03;
    weights    = 32'h00_00_0F_0A;
    #10
    @(posedge clk);

    activation = 32'h00_0C_07_02;
    weights    = 32'h00_10_0B_06;
    #10
    @(posedge clk);

    activation = 32'h10_0B_06_01;
    weights    = 32'h11_0C_07_02;
    #10
    @(posedge clk);
    

    first_done = 1;  // done after 4 completed calculations
    activation = 32'h0F_0A_05_00;
    weights    = 32'h0D_08_03_00;
    #10
    @(posedge clk);
    
    activation = 32'h0E_09_00_00;
    weights    = 32'h09_04_00_00;
    #10
    @(posedge clk);
   
    activation = 32'h0D_00_00_00;
    weights    = 32'h05_00_00_00;
    
    wait(systolic_array_net.valid) begin
        #10
        @(posedge clk);
    end

    $display("The expected value of a00 is : 100, the value is: %8d", pe_results.pe00_result);
    $display("The expected value of a01 is : 110, the value is: %8d", pe_results.pe01_result);
    $display("The expected value of a02 is : 120, the value is: %8d", pe_results.pe02_result);
    $display("The expected value of a03 is : 130, the value is: %8d", pe_results.pe03_result);
    $display("The expected value of a10 is : 228, the value is: %8d", pe_results.pe10_result);
    $display("The expected value of a11 is : 254, the value is: %8d", pe_results.pe11_result);
    $display("The expected value of a12 is : 280, the value is: %8d", pe_results.pe12_result);
    $display("The expected value of a13 is : 306, the value is: %8d", pe_results.pe13_result);
    $display("The expected value of a20 is : 356, the value is: %8d", pe_results.pe20_result);
    $display("The expected value of a21 is : 398, the value is: %8d", pe_results.pe21_result);
    $display("The expected value of a22 is : 440, the value is: %8d", pe_results.pe22_result);
    $display("The expected value of a23 is : 482, the value is: %8d", pe_results.pe23_result);
    $display("The expected value of a30 is : 484, the value is: %8d", pe_results.pe30_result);
    $display("The expected value of a31 is : 542, the value is: %8d", pe_results.pe31_result);
    $display("The expected value of a32 is : 600, the value is: %8d", pe_results.pe32_result);
    $display("The expected value of a33 is : 658, the value is: %8d", pe_results.pe33_result);

    $finish();

end
parameter V_TIMEOUT = 10000;
initial begin:timeout_logic
    #V_TIMEOUT
    $display("timeout reached");
    $finish();

end

endmodule