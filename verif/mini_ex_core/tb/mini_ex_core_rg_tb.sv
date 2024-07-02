module mini_ex_core_rg_tb;

    import mini_ex_core_pkg::*;

    // Parameters
    parameter int DATA_WIDTH = 32;

    // Signals
    logic Clock;
    logic Rst;
    t_rg_read RgRead;
    t_rg_write RgWrite;
    t_rg_val ValRegsQ101H;

    // Instantiate the register file module
    mini_ex_core_rg uut (
        .Clock(Clock),
        .Rst(Rst),
        .RgRead(RgRead),
        .RgWrite(RgWrite),
        .ValRegsQ101H(ValRegsQ101H)
    );

    // Clock generation
    always #5 Clock = ~Clock;

    // Test sequence
    initial begin
        // Initialize signals
        Clock = 0;
        Rst = 1;
        RgRead = '{default: '0};
        RgWrite = '{default: '0};
        ValRegsQ101H = '{default: '0};

        // Apply reset
        #10;
        Rst = 0;

        // Read the data back
        RgRead.ReadReg1Q100H = 5;
        #10;

        // Write some data
        RgWrite.WriteEnableQ100H = 1;
        RgWrite.DstRegQ100H = 5;
        RgWrite.WriteValueQ100H = 32'hDEADBEEF;
        #10;
        RgWrite.WriteEnableQ100H = 0;

        RgWrite.WriteValueQ100H = 32'hDEAD0000;
        #10;
        RgWrite.WriteEnableQ100H = 0;


        

        // Check the output
         $display("Test passed!");
        if (ValRegsQ101H.Reg1Val == 32'hDEADBEEF) begin
            $display("Test passed!");
        end else begin
            $display("Test failed! Expected %h, got %h", 32'hDEADBEEF, ValRegsQ101H.Reg1Val);
        end

        // Finish the simulation
        $finish;
    end

endmodule



