module mini_ex_core_pc_tb;

    import mini_ex_core_pkg::*;

    // Parameters
    parameter int DATA_WIDTH = 32;

    // Signals
    logic Clock;
    logic Rst;
    logic JmpEnableQ100H;
    logic [31:0] JmpAddressQ100H;
    logic [31:0] PcPlus4Q101H;
    logic [31:0] PcCurrQ101H;

    // Instantiate the mini_ex_core_pc module
    mini_ex_core_pc uut (
        .Clock(Clock),
        .Rst(Rst),
        .JmpEnableQ100H(JmpEnableQ100H),
        .JmpAddressQ100H(JmpAddressQ100H),
        .PcPlus4Q101H(PcPlus4Q101H),
        .PcCurrQ101H(PcCurrQ101H)
    );

    // Clock generation
    always #5 Clock = ~Clock;

    // Test sequence
    initial begin
        // Initialize signals
        Clock = 0;
        Rst = 1;
        JmpEnableQ100H = 0;
        JmpAddressQ100H = 32'd0;
        PcPlus4Q101H = 32'd0;
        PcCurrQ101H = 32'd0;

        // Apply reset
        #10;
        Rst = 0;

        // Jmp without enable
        JmpEnableQ100H = 0;
        JmpAddressQ100H = 32'h12345678;
        #10;

        // Jmp with enable
        JmpEnableQ100H = 1;
        #10;

        // Regular work
        JmpEnableQ100H = 0;
        #20;

        // Check the output
        $display("PcCurrQ101H = %h, PcPlus4Q101H = %h", PcCurrQ101H, PcPlus4Q101H);

        // Finish the simulation
        $finish;
    end

endmodule
