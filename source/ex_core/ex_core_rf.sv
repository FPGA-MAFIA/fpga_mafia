// ./build.py -sim -dut ex_core -top ex_core_rf_tb -hw -clean
`include "macros.vh"

module ex_core_rf
import ex_core_pkg::*;
(
    input  logic        clk,          // Clock signal
    /* Control signals:
    *  RegSrc1
    *  RegSrc2
    *  RegDst
    *  RegWrEn */
    input  var t_ctrl_rf Ctrl,         // Corrected type name here
    input  logic [31:0] RegWrData,    // Data to write to the register
    output logic [31:0] RegRdData1,   // Data from the first read register
    output logic [31:0] RegRdData2    // Data from the second read register
);

    // Register file with 32 registers, each 32 bits wide
    logic [31:0] registers [31:0];  
    
    // Write operation (register 0 is hardwired to 0)
    `MAFIA_EN_DFF(registers[Ctrl.RegDst], RegWrData, clk, Ctrl.RegWrEn & (Ctrl.RegDst != 5'h0));
    
    // Read operation
    assign RegRdData1 = (Ctrl.RegSrc1 != 0) ? registers[Ctrl.RegSrc1] : 32'b0; //(register 0 is hardwired to 0)
    assign RegRdData2 = (Ctrl.RegSrc2 != 0) ? registers[Ctrl.RegSrc2] : 32'b0; //(register 0 is hardwired to 0)

endmodule
