// ./build.py -sim -dut ex_core -top ex_core_alu_tb -hw -clean
module ex_core_alu_tb();

    // Define signals
    logic [31:0] operand1, operand2;
    logic [3:0] op;
    logic [31:0] result;
    logic zero;

    // Define opcode as a word
    typedef enum logic [3:0] {
        ADD  = 4'b0000,
        SUB  = 4'b0001,
        AND  = 4'b0010,
        OR   = 4'b0011,
        XOR  = 4'b0100,
        SLL  = 4'b0101,
        SRL  = 4'b0110,
        SRA  = 4'b0111,
        SLT  = 4'b1000,
        SLTU = 4'b1001
    } opcode_t;

    opcode_t opcode;

    // Define opcode_name function
    function string opcode_name(opcode_t opcode);
        case (opcode)
            ADD:  return "ADD";
            SUB:  return "SUB";
            AND:  return "AND";
            OR:   return "OR";
            XOR:  return "XOR";
            SLL:  return "SLL";
            SRL:  return "SRL";
            SRA:  return "SRA";
            SLT:  return "SLT";
            SLTU: return "SLTU";
            default: return "UNKNOWN";
        endcase
    endfunction

    // Instantiate ALU
    ex_core_alu dut(
    .operand1   (operand1),
    .operand2   (operand2),
    .op         (op),
    .result     (result),
    .zero       (zero)
    );

    // Aplly Random stimulus
    initial begin
        #10
        repeat (15) begin
            operand1 = $urandom_range(0, 10);
            operand2 = $urandom_range(0, 10);
            opcode = opcode_t'($urandom_range(0, 9)); // Generate a random operation code
            op = opcode;
            #10;
            $display("The result of %4b and %4b with operation %s is %4b", operand1, operand2, opcode_name(opcode), result);
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