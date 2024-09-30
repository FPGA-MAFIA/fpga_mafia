module systolic_array_ctrl_tb;
import mini_core_accel_pkg::*;

//  ./build.py -dut mini_core_accel -top systolic_array_ctrl_tb -hw -sim
logic         clk;
logic         rst;
logic [127:0] all_weigths;
logic [127:0] all_activations;
logic         start;
logic         valid;


// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen

systolic_array_ctrl systolic_array_ctrl
(
    .clk(clk),
    .rst(rst),
    .all_weights(all_weigths),      
    .all_activations(all_activations),  
    .start(start),            
    .valid(valid),            
    .pe_results()

);

initial begin
    all_activations = 128'h0D_0E_09_0F_0A_05_10_0B_06_01_0C_07_02_08_03_04; 
    all_weigths     = 128'h05_09_04_0D_08_03_11_0C_07_02_10_0B_06_0F_0A_0E;
    rst   = 1;
    start = 0;
    #50
    @(posedge clk);

    rst   = 0;
    start = 0;
    #20
    @(posedge clk);

    start = 1;
    #150
    @(posedge clk);

    $finish();

end

endmodule