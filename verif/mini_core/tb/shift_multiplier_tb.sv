module shift_multiplier_tb;

  // Parameters
  localparam int M_width = 24;
  localparam int Q_width = 8;

  // Testbench signals
  logic Clock;
  logic Rst;
  logic signed [M_width - 1:0] Mu; // Multiplicand 2's complement
  logic signed [Q_width - 1:0] Qu; // Multiplier 2's complement
  logic signed [M_width + Q_width - 1:0] product; // 2's complement

  // Instantiate the DUT
  shift_multiplier
  #(
    .M_width(M_width),
    .Q_width(Q_width)
  )
  dut (
    .Clock(Clock),
    .Rst(Rst),
    .Mu(Mu),
    .Qu(Qu),
    .product(product)
  );

  // Clock generation
  always #5 Clock = ~Clock; // 10ns clock period

  // Test stimulus
  initial begin
    // Initialize signals
    Clock = 0;
    Rst = 0;
    Mu = 0;
    Qu = 0;

    // Reset the DUT
    Rst = 1;
    #10;
    Rst = 0;

    // Test case 1: 5 * 3
    Mu = 5;
    Qu = 3;
    #10;

    // Test case 2: -5 * 3
    Mu = -5;
    Qu = 3;
    #10;

    // Test case 3: 0 * 7
    Mu = 0;
    Qu = 7;
    #10;

    // Test case 4: -7 * -3
    Mu = -7;
    Qu = -3;
    #10;

    // Test case 5: 15 * -4
    Mu = 15;
    Qu = -4;
    #10;

    // Test case 6: -15 * -4
    Mu = -15;
    Qu = -4;
    #10;

    // Test case 7: 2^23 * 2^7 (max values for width)
    Mu = (1 << (M_width - 1));
    Qu = (1 << (Q_width - 1));
    #10;

    // Test case 8: -2^23 * 2^7 (min and max values)
    Mu = -(1 << (M_width - 1));
    Qu = (1 << (Q_width - 1));
    #10;

    // Test case 9: 2^23 * -2^7
    Mu = (1 << (M_width - 1));
    Qu = -(1 << (Q_width - 1));
    #10;

    // Test case 10: -2^23 * -2^7
    Mu = -(1 << (M_width - 1));
    Qu = -(1 << (Q_width - 1));
    #150;

    // Finish simulation
    $finish;
end

endmodule