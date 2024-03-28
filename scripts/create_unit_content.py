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

`include "macros.vh"

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

VERIF_FILE_LIST_CONTENT = '''
+incdir+../../../source/common/
+incdir+../../../verif/{unit}/tb/
+incdir+../../../verif/{unit}/tb/trk
+incdir+../../../verif/{unit}/tb/tasks
+incdir+../../../verif/{unit}/tb/hw_seq
+incdir+../../../verif/{unit}/tests
../../../verif/{unit}/tb/{unit}_tb.sv

'''

FILE_LIST_CONTENT = '''
+define+SIM_ONLY
-f ../../../source/{unit}/{unit}_rtl_list.f
-f ../../../verif/{unit}/file_list/{unit}_verif_list.f

'''
VERIF_TASKS_CONTENT = '''
// set ALU inputs
task set_alu_inputs(
    input logic [31:0] in1,
    input logic [31:0] in2,
    input t_opcode op
);
    @(posedge Clk);
    alu_in1 = in1;
    alu_in2 = in2;
    opcode  = op;
endtask
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

`include "macros.vh"

module {unit}_tb;
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
`include "{unit}_tasks.vh"


// ========================
string test_name;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    // EOT - end of test
    //======================================
    //default DUT input values
    alu_in1 = 32'h0;
    alu_in2 = 32'h0;
    opcode  = ADD;
    #10;
    set_alu_inputs(32'h1, 32'h2, ADD);
    set_alu_inputs(32'h1, 32'h2, SUB);
    set_alu_inputs(32'h1, 32'h2, AND);
    set_alu_inputs(32'h1, 32'h2, OR);
    set_alu_inputs(32'h1, 32'h2, XOR);
    #10;
    $display("ALU test sequence completed");
    #10;
    $finish;
    //$error("ERROR: TIMEOUT");
    //eot("ERROR: TIMEOUT");
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

parameter V_TIMEOUT = 100000;
initial begin: detect_timeout
    //=======================================
    // timeout
    //=======================================
    #V_TIMEOUT 
    $error("test ended with timeout");
    $display("ERROR: No data integrity running - try to increase the timeout value");
    $finish;
end

endmodule
`endif
'''
