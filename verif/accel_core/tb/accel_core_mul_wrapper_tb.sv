module accel_core_mul_wrapper_tb;
import accel_core_pkg::*;  // Import your package
  // Signals
  logic Clock;
  logic Rst;
  logic clear;
  t_buffer_inout neuron_in;  // Defined in accel_core_pkg
  t_buffer_weights w1;       // Defined in accel_core_pkg
  logic [7:0] result;
  logic out_valid;

  // Instantiate the DUT
  accel_core_mul_wrapper dut (
      .Clock(Clock),
      .Rst(Rst),
      .clear(clear),
      .neuron_in(neuron_in),
      .w1(w1),
      .result(result),
      .out_valid(out_valid)
  );
  // Clock generation: 10ns period (100MHz)
  always #5 Clock = ~Clock;

  // Test stimulus
  initial begin
    // Initialize signals
    Clock = 0;
    Rst = 0;
    clear = 0;
    neuron_in = '{default: '0};
    w1 = '{default: '0};
    // Apply reset
    Rst = 1;
    #10;  // Hold reset for 10ns
    Rst = 0;

    // Initialize neuron_in and w1 data
    neuron_in.data[0] = 8'h1;
    neuron_in.data[1] = 8'h2;
    neuron_in.data[2] = 8'h3;
    neuron_in.data[3] = 8'h4;
    neuron_in.data[4] = 8'h5;
    neuron_in.data[5] = 8'h6;
    w1.data[0] = 8'h1;
    w1.data[1] = 8'h2;
    w1.data[2] = 8'h3;
    w1.data[3] = 8'h4;
    w1.data[4] = 8'h5;
    w1.data[5] = 8'h6;   
    w1.meta_data.data_len = 4;  // Number of elements in the weights buffer
    #10; 
    #300; 
    clear=1;
    neuron_in.data[0] = 8'h10;
    neuron_in.data[1] = 8'h20;
    neuron_in.data[2] = 8'h3;
    neuron_in.data[3] = 8'h4;
    neuron_in.data[4] = 8'h5;
    neuron_in.data[5] = 8'h6;
    w1.data[0] = 8'h10;
    w1.data[1] = 8'h20;
    w1.data[2] = 8'h3;
    w1.data[3] = 8'h4;
    w1.data[4] = 8'h5;
    w1.data[5] = 8'h6;   
    w1.meta_data.data_len = 4;  // Number of elements in the weights buffer
    #10
    clear=0;
    #300; 
    clear=1;
    neuron_in.data[0] = -8'h10;
    neuron_in.data[1] = -8'h20;
    neuron_in.data[2] = 8'h3;
    neuron_in.data[3] = 8'h4;
    neuron_in.data[4] = 8'h5;
    neuron_in.data[5] = 8'h6;
    w1.data[0] = 8'h10;
    w1.data[1] = 8'h20;
    w1.data[2] = 8'h3;
    w1.data[3] = 8'h4;
    w1.data[4] = 8'h5;
    w1.data[5] = 8'h6;   
    w1.meta_data.data_len = 4;  // Number of elements in the weights buffer
    #10
    clear=0;
    #300
    // Finish simulation
    $finish;
  end

endmodule
