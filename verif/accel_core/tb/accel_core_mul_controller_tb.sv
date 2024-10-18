module accel_core_mul_controller_tb;
import accel_core_pkg::*;  // Import your package
  // Signals
// Clock and Reset
logic Clock;
logic Rst;

// Metadata signals for input, weights, and output
t_metadata_inout input_meta_data;
t_metadata_weights w1_meta_data;
t_metadata_weights w2_meta_data;
t_metadata_weights w3_meta_data;
t_metadata_inout output_meta_data;

// Control signals
logic move_out_to_in;
logic done_layer;
logic clear_output;

// Signals for m1
logic clear_m1;
logic start_m1;
t_buffer_sel assign_m1; // Assuming t_buffer_sel is the correct enum type
logic out_valid_m1;

// Signals for m2
logic clear_m2;
logic start_m2;
t_buffer_sel assign_m2; // Assuming t_buffer_sel is the correct enum type
logic out_valid_m2;

  // Instantiate the DUT
  accel_core_mul_controller mul_controller (
    .Clock(Clock),
    .Rst(Rst),
    .input_metadata(input_meta_data),
    .w1_metadata(w1_meta_data),
    .w2_metadata(w2_meta_data),
    .w3_metadata(w3_meta_data),
    .out_metadata(output_meta_data),
    .move_out_to_in(move_out_to_in),
    .done_layer(done_layer),
    .clear_output(clear_output),
    ///////// m1 port
    .clear_m1(clear_m1),
    .start_m1(start_m1),
    .assign_m1(assign_m1),
    .out_valid_m1(out_valid_m1),
    ///////// m2 port
    .clear_m2(clear_m2),
    .start_m2(start_m2),
    .assign_m2(assign_m2),
    .out_valid_m2(out_valid_m2)
);
    int test;
  // Clock generation: 10ns period (100MHz)
  always #5 Clock = ~Clock;
 

  // Test stimulus
  initial begin
    test = 0;
    // Initialize signals
    Clock = 0;
    Rst = 0;
     // Metadata signals for input, weights, and output
    input_meta_data = '0; // Assuming t_metadata_inout supports '0 initialization
    w1_meta_data = '0; // Assuming t_metadata_weights supports '0 initialization
    w2_meta_data = '0;
    w3_meta_data = '0;
    output_meta_data = '0;

    // Control signals
    move_out_to_in = 1'b0;
    done_layer = 1'b0;

    // Signals for m1
    out_valid_m1 = 1'b0;

    // Signals for m2
    out_valid_m2 = 1'b0;


    Rst = 1;
    #10;
    Rst = 0;
    #10;
    input_meta_data.in_use_by_accel=1;
    #980;
    /*
    // test 1
    test = 1;
    w1_meta_data.in_use=1;
    #50;
    w1_meta_data.in_use=0;
    #10;
    out_valid_m1 = 1;
    #10
    out_valid_m1 = 0;
    #10;

    w1_meta_data.in_use=1;
    #50;
    w1_meta_data.in_use=0;
    #10;
    out_valid_m1 = 1;
    #10
    out_valid_m1 = 0;
    #10;

    
    //test 2 
    test = 2;
    w1_meta_data.in_use=1;
    w2_meta_data.in_use=1;
    #100;
    w1_meta_data.in_use=0;
    w2_meta_data.in_use=0;
    #30;
    out_valid_m1 = 1;
    out_valid_m2 = 1;
    #10
    out_valid_m1 = 0;
    out_valid_m2 = 0;
    #10
    w1_meta_data.in_use=1;
    w2_meta_data.in_use=1;
    #100;
    w1_meta_data.in_use=0;
    w2_meta_data.in_use=0;
    #30;
    out_valid_m1 = 1;
    out_valid_m2 = 1;
    #10
    out_valid_m1 = 0;
    out_valid_m2 = 0;
    #10

*/
//test 3 
    test = 3;
    w1_meta_data.in_use=0;
    w2_meta_data.in_use=0;
    w3_meta_data.in_use=0;
    #150;
    w1_meta_data.in_use=1;
    #150;
    w2_meta_data.in_use=1;
    #90;
    w1_meta_data.in_use=0;
    #10;
    out_valid_m1=1; // 400
    #10;
    out_valid_m1=0; // 410
    #40;
    w3_meta_data.in_use=1; // 450
    #90;
    w2_meta_data.in_use=0; // 540
    #10;
    out_valid_m2=1; // 550
    #10;
    out_valid_m2=0; // 560
    #40;
    w1_meta_data.in_use=1; // 600
    #90;
    w3_meta_data.in_use=0; // 690
    #10;
    out_valid_m1=1; // 700
    #10;
    out_valid_m1=0; // 710
    #40;
    w2_meta_data.in_use=1; // 750
    #90;
    w1_meta_data.in_use=0; // 840
    #10;
    out_valid_m2=1; // 850
    #10;
    out_valid_m2=0; // 860
    #40; 
    w3_meta_data.in_use=1; // 900
    #90;
    w2_meta_data.in_use=0; // 990
    #10;
    out_valid_m1=1; // 1000
    #10;
    out_valid_m1=0; // 1010
    #40;
    w3_meta_data.in_use=0; // 1050
    #10;
    out_valid_m2=1; // 1060
    #10;
    out_valid_m2=0; // 1070









   
    // Finish simulation
    $finish;
  end

endmodule
