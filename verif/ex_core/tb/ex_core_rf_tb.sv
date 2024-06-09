/* to run that TB:
 * ./build.py -sim -dut ex_core -top ex_core_rf_tb -hw -clean
 */

module ex_core_rf_tb;
import ex_core_pkg::*;

    // Clock signal
    logic clk;
    
    // Control signals
    var t_ctrl_rf Ctrl;
    
    // Data signals
    logic [31:0] RegWrData;
    logic [31:0] RegRdData1;
    logic [31:0] RegRdData2;
    
    // Instantiate the module under test (MUT)
    ex_core_rf MUT (
        .clk(clk),
        .Ctrl(Ctrl),
        .RegWrData(RegWrData),
        .RegRdData1(RegRdData1),
        .RegRdData2(RegRdData2)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end

    // Test procedure
    initial begin
        // Initialize control signals
        Ctrl.RegSrc1 = 0;
        Ctrl.RegSrc2 = 0;
        Ctrl.RegDst = 0;
        Ctrl.RegWrEn = 0;
        RegWrData = 0;
        
        // Wait for a few clock cycles
        #20;
        
        // Test writing to a register
        Ctrl.RegDst = 1;
        RegWrData = 32'hA5A5A5A5;
        Ctrl.RegWrEn = 1;
        #10;  // Wait for one clock cycle
        Ctrl.RegWrEn = 0;
        
        // Test reading from a register
        Ctrl.RegSrc1 = 1;
        #10;  // Wait for one clock cycle
        $display("RegRdData1 = %h (Expected: A5A5A5A5)", RegRdData1);
        
        // Test writing to register 0 (should have no effect)
        Ctrl.RegDst = 0;
        RegWrData = 32'hFFFFFFFF;
        Ctrl.RegWrEn = 1;
        #10;  // Wait for one clock cycle
        Ctrl.RegWrEn = 0;
        
        // Test reading from register 0 (should always be 0)
        Ctrl.RegSrc1 = 0;
        #10;  // Wait for one clock cycle
        $display("RegRdData1 = %h (Expected: 00000000)", RegRdData1);
        
        // Test reading from another register
        Ctrl.RegDst = 2;
        RegWrData = 32'h12345678;
        Ctrl.RegWrEn = 1;
        #10;  // Wait for one clock cycle
        Ctrl.RegWrEn = 0;
        
        Ctrl.RegSrc1 = 2;
        #10;  // Wait for one clock cycle
        $display("RegRdData1 = %h (Expected: 12345678)", RegRdData1);
        
        // Additional test case: Write and read from different registers
        Ctrl.RegDst = 3;
        RegWrData = 32'h87654321;
        Ctrl.RegWrEn = 1;
        #10;
        Ctrl.RegWrEn = 0;
        
        Ctrl.RegSrc1 = 3;
        Ctrl.RegSrc2 = 2;
        #10;
        $display("RegRdData1 = %h (Expected: 87654321)", RegRdData1);
        $display("RegRdData2 = %h (Expected: 12345678)", RegRdData2);
        
        // End of test
        $finish;
    end

endmodule
