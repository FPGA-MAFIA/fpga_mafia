module systolic_array_ctrl_tb;
import mini_core_accel_pkg::*;

//  ./build.py -dut mini_core_accel -top systolic_array_ctrl_tb -hw -sim
logic         clk;
logic         rst;
logic [127:0] all_weigths;
logic [127:0] all_activations;
logic         start;


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
    .valid(),            
    .pe_results()

);

initial begin
    all_weigths     = 128'h11_22_33_44_55_66_77_88_99_aa_bb_cc_dd_ee_ff_10;
    all_activations = 128'h10_ff_ee_dd_cc_bb_aa_99_88_77_66_55_44_33_22_11; 
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