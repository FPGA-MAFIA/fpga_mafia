module accel_core_mul_top_tb;
import accel_core_pkg::*;  // Import your package
// Signals
logic Clock;
logic Rst;
t_buffer_inout input_vec;
t_buffer_weights w1;
t_buffer_weights w2;
t_buffer_weights w3;
t_buffer_inout output_vec;
logic release_w1;
logic release_w2;
logic release_w3;
logic done_layer;

  // Instantiate the DUT
accel_core_mul_top accel_core_instance (
    .Clock         (Clock),
    .Rst           (Rst),
    .input_vec     (input_vec),
    .w1            (w1),
    .w2            (w2),
    .w3            (w3),
    .output_vec    (output_vec),
    .release_w1    (release_w1),
    .release_w2    (release_w2),
    .release_w3    (release_w3),
    .done_layer    (done_layer)
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
    input_vec = '0;   // Assuming t_buffer_inout can be initialized with '0
    w1 = '0;          // Assuming t_buffer_weights can be initialized with '0
    w2 = '0;
    w3 = '0;


    // Test
    Rst = 1;
    #10;
    Rst = 0;
    #10;
    input_vec.meta_data.in_use_by_accel = 1;
    input_vec.meta_data.matrix_row_num = 2;
    input_vec.meta_data.matrix_col_num = 3;

    input_vec.data[0] = 8'h01;  
    input_vec.data[1] = 8'h02;

    w1.data[0] = 8'h03;  
    w1.data[1] = 8'h04;
    w1.data[2] = 8'h05; // bias
    w1.meta_data.data_len = 3;
    w1.meta_data.neuron_idx = 0;

    w2.data[0] = 8'h06;  
    w2.data[1] = 8'h07;
    w2.data[2] = 8'h08; // bias
    w2.meta_data.data_len = 3;
    w2.meta_data.neuron_idx = 1;


    w3.data[0] = 8'h09;  
    w3.data[1] = 8'h0A;
    w3.data[2] = 8'h0B; // bias
    w3.meta_data.data_len = 3;
    w3.meta_data.neuron_idx = 2;
    #100;
    w1.meta_data.in_use = 1;
    #20;
    w1.meta_data.in_use = 0;
    #80;
    w2.meta_data.in_use = 1;
    #20;
    w2.meta_data.in_use = 0;
    #80;
    w3.meta_data.in_use = 1;
    #20;
    w3.meta_data.in_use = 0;
    #500;
    input_vec.meta_data.in_use_by_accel = 0;
    #100;
    $finish;

  end
endmodule