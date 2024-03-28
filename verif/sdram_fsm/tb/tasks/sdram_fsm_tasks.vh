
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
