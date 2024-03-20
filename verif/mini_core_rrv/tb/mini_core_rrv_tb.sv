`include "macros.vh"

module mini_core_rrv_tb;
import mini_core_rrv_pkg::*;

logic Clock;
logic Rst;
logic  [7:0] IMem     [I_MEM_SIZE + I_MEM_OFFSET - 1 : I_MEM_OFFSET];


// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 Clock = 1'b0;
        #5 Clock = 1'b1;
    end //forever
end//initial clock_gen

// ========================
// reset generation
// ========================
initial begin: reset_gen
     Rst = 1'b1;
#100 Rst = 1'b0;
end: reset_gen

string test_name;
`include "core_rrv_trk.vh"

integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the DUT & reference model
    //======================================
    // Make sure inst_mem.sv exists
    file = $fopen({"../../../target/mini_core_rrv/tests/",test_name,"/gcc_files/inst_mem.sv"}, "r");
    if (!file) begin
        $error("the file: ../../../target/mini_core_rrv/tests/%s/gcc_files/inst_mem.sv does not exist", test_name);
        $display("ERROR: inst_mem.sv file does not exist");
        $finish;
    end
    $readmemh({"../../../target/mini_core_rrv/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    force mini_core_rrv_top.mini_core_rrv_mem_wrap.i_mem.mem = IMem; //backdoor to actual memory  
end // test_seq

mini_core_rrv_top mini_core_rrv_top
(
    .Clock(Clock),
    .Rst(Rst)
);


parameter V_TIMEOUT = 10000;

initial begin: time_out
    #V_TIMEOUT
    $display("time out reached");
    $finish;
end




endmodule