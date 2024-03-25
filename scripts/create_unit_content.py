# Define the content as raw strings with placeholders. 
# Make sure all the text is within the triple quotes.

SOURCE_PKG_CONTENT = ''' 
//-----------------------------------------------------------------------------
// Title            : Package file for the {unit} unit
// Project          : Placeholder
//-----------------------------------------------------------------------------
// File             : {unit}_pkg.sv
// Original Author  : Placeholder
// Code Owner       : Placeholder
// Created          : MM/YYYY
//-----------------------------------------------------------------------------
// Description :
// the package file for the ALU unit
//-----------------------------------------------------------------------------
`ifndef {unit}_PKG_SV
`define {unit}_PKG_SV
package {unit}_pkg;
typedef enum logic [2:0] {{
    ADD         = 3'b000,
    SUB         = 3'b001,
    AND         = 3'b010,
    OR          = 3'b011,
    XOR         = 3'b100,
    NULL_101    = 3'b101,
    NULL_110    = 3'b110,
    NULL_111    = 3'b111
}} t_opcode ;
endpackage
`endif
'''

SOURCE_UNIT_CONTENT = ''' 
//-----------------------------------------------------------------------------
// Title            : Example ALU unit
// Project          : Placeholder
//-----------------------------------------------------------------------------
// File             : {unit}.sv
// Original Author  : Placeholder
// Code Owner       : Placeholder
// Created          : MM/YYYY
//-----------------------------------------------------------------------------
// Description :
// Simple ALU unit that supports ADD,SUB,AND,OR,XOR operations
//-----------------------------------------------------------------------------
`ifndef {unit}_SV
`define {unit}_SV

`include "macros.sv"

module {unit}
import {unit}_pkg::*;
(
    input logic         clk,
    input logic         rst,
    input logic  [31:0] alu_in1,
    input logic  [31:0] alu_in2,
    input t_opcode      opcode,
    output logic [31:0] alu_out
);

logic [31:0] pre_alu_out;
always_comb begin
    case(opcode)
        ADD:     pre_alu_out = alu_in1 + alu_in2;
        SUB:     pre_alu_out = alu_in1 - alu_in2;
        AND:     pre_alu_out = alu_in1 & alu_in2;
        OR:      pre_alu_out = alu_in1 | alu_in2;
        XOR:     pre_alu_out = alu_in1 ^ alu_in2;
        default: pre_alu_out = 32'b0;
    endcase
end

// Sample DFF of the output
`MAFIA_RST_DFF(alu_out, pre_alu_out, clk, rst)

endmodule
`endif
'''

RTL_FILE_LIST_CONTENT = '''
+incdir+../../../source/{unit}/
+incdir+../../../source/common/

//package files
../../../source/{unit}/{unit}_pkg.sv

//RTL files
../../../source/{unit}/{unit}.sv

'''


TB_FILE_CONTENT = '''
//-----------------------------------------------------------------------------
// Title            : Example TB
// Project          : Placeholder
//-----------------------------------------------------------------------------
// File             : {unit}_tb.sv
// Original Author  : Placeholder
// Code Owner       : Placeholder
// Created          : MM/YYYY
//-----------------------------------------------------------------------------
// Description :
//-----------------------------------------------------------------------------
`ifndef {unit}_TB_SV
`define {unit}_TB_SV

`include "macros.sv"

module {unit};
import {unit}_pkg::*;
logic Clk;
logic Rst;
// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 Clk = 1'b0;
        #5 Clk = 1'b1;
    end //forever
end//initial clock_gen

// ========================
// reset generation
// ========================
initial begin: reset_gen
    Rst = 1'b1;
#40 Rst = 1'b0;
end: reset_gen

logic [31:0] alu_in1;
logic [31:0] alu_in2;
t_opcode opcode;
logic [31:0] alu_out;

// ========================
string test_name;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    // EOT - end of test
    //======================================
    #1000;
    $error("ERROR: TIMEOUT");
    eot("ERROR: TIMEOUT");
end // test_seq


// ========================
// DUT - Design Under Test
// ========================
{unit} {unit}_dut (
    .clk(Clk),
    .rst(Rst),
    .alu_in1(alu_in1),
    .alu_in2(alu_in2),
    .opcode(opcode),
    .alu_out(alu_out)
);

initial begin
forever begin
    monitor("monitor", $time, Clk, Rst, alu_in1, alu_in2, opcode, alu_out);
endmodule
`endif
'''
