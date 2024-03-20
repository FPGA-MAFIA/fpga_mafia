`include "macros.vh"

// ./build.py -dut mini_core_rrv -top mini_core_rrv_r_type_tb -hw -sim

module mini_core_rrv_r_type_tb;
import mini_core_rrv_pkg::*;

logic Clock;
logic Rst;
logic  [7:0] IMEM     [I_MEM_SIZE + I_MEM_OFFSET - 1 : I_MEM_OFFSET];


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

initial begin: I_mem_init
    IMEM[0]  =  32'h00100193;        //addi	x3,x0,1
    IMEM[1]  =  32'h00200213;        //addi	x4,x0,2
    IMEM[2]  =	32'h00300293;        //addi	x5,x0,3
    IMEM[3]  =	32'h00400313;        //addi	x6,x0,4
    IMEM[4]  =	32'h00500393;        //addi	x7,x0,5
    IMEM[5]  =	32'h00600413;        //addi	x8,x0,6
    IMEM[6]  =	32'h00700493;        //addi	x9,x0,7
    IMEM[7]  =	32'h004184b3;        //add	x9,x3,x4
    IMEM[8]  =	32'h40418533;        //sub	x10,x3,x4
    IMEM[9]  =	32'h0062f5b3;        //and	x11,x5,x6
    IMEM[10] =	32'h0083e633;        //or	x12,x7,x8
    IMEM[11] =	32'h009446b3;        //xor	x13,x8,x9
end

integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    force mini_core_rrv_top.mini_core_rrv_mem_wrap.i_mem.mem = IMEM; //backdoor to actual memory  
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