// ./build.py -sim -dut ex_core -top ex_core_alu_tb -hw -clean
`include "ex_core_pkg.sv"

module ex_core_alu_tb();
import ex_core_pkg::*;

    // Define signals
    logic [31:0] operand1, operand2;
    var t_ctrl_alu Ctrl;
    logic [31:0] result;
    logic zero;

    // Instantiate ALU
    ex_core_alu dut(
    .operand1   (operand1),
    .operand2   (operand2),
    .Ctrl         (Ctrl),
    .result     (result),
    .zero       (zero)
    );

    // Aplly Random stimulus
    t_alu_op alu_ops[10] = '{ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU};
    initial begin
        #10
        repeat (15) begin
            operand1 = $urandom_range(0, 10);
            operand2 = $urandom_range(0, 10);
            Ctrl.AluOp = alu_ops[$urandom_range(0, 9)]; // Generate a random operation code
            #10;
            $display("The result of %4b and %4b with operation %s is %4b", operand1, operand2, Ctrl.AluOp, result);
            // Check result (this will depend on the operation)
        end
        $finish;
    end

    parameter V_TIMEOUT = 10000;

    initial begin: detec_timeout
        #V_TIMEOUT
        $error("time out reached");
        $finish;
    end

endmodule