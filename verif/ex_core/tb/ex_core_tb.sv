module ex_core_tb;
    // Clock and reset signals
    logic Clk;
    logic Rst;

    // Instantiate the DUT (Device Under Test)
    ex_core ex_core (
        .Clk(Clk),
        .Rst(Rst)
    );

    // Clock generation
    always #5 Clk = ~Clk; // 10ns clock period

    initial begin
        // Initialize signals
        Clk = 0;
        Rst = 1;

        // Reset the CPU
        #20 Rst = 0;

        // Wait for a few clock cycles
        #1000;

        // Finish simulation
        $finish;
    end

string test_name;
logic  [7:0] IMem   [1023:0];
integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the DUT & reference model
    //======================================
    // Make sure inst_mem.sv exists
    file = $fopen({"../../../target/ex_core/tests/",test_name,"/gcc_files/inst_mem.sv"}, "r");
    if (!file) begin
        $error("the file: ../../../target/ex_core/tests/%s/gcc_files/inst_mem.sv does not exist", test_name);
        $display("ERROR: inst_mem.sv file does not exist");
        $finish;
    end
    $readmemh({"../../../target/ex_core/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    force ex_core.i_mem.mem = IMem; //backdoor to actual memory
end // test_seq

    // Memory Initialization with R-Type instructions
    initial begin
        // Memory contents for R-Type instruction test
        // This part needs to be aligned with the actual memory implementation and loading mechanism
        // E.g., you might have an I_MEM file with assembly instructions

        // Example R-Type Instructions (binary format):
        // ADD x1, x2, x3   -> 0000000 00101 00010 000 00001 0110011
        // SUB x4, x5, x6   -> 0100000 00110 00101 000 00100 0110011
        // AND x7, x8, x9   -> 0000000 01001 01000 111 00111 0110011
        // OR  x10, x11, x12 -> 0000000 01100 01011 110 01010 0110011
        // XOR x13, x14, x15 -> 0000000 01111 01110 100 01101 0110011

        // Example: You might load these instructions into instruction memory
        // (e.g., using $readmemb or $readmemh to load from a file)
    end
endmodule
