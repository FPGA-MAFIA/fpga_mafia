`include "macros.vh"

// ./build.py -dut mini_core_rrv -top mini_core_rrv_ri_type_tb -hw -sim

module mini_core_rrv_ri_type_tb;
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
    // nop - we need to reset flashQ102H register
    IMEM[0]  = 8'h13; IMEM[1]  = 8'h00; IMEM[2]  = 8'h00; IMEM[3]  = 8'h00;
    // addi x3,x0,1
    IMEM[4]  = 8'h93; IMEM[5]  = 8'h01; IMEM[6]  = 8'h10; IMEM[7]  = 8'h00;
    // addi x4,x0,2
    IMEM[8]  = 8'h13; IMEM[9]  = 8'h02; IMEM[10] = 8'h20; IMEM[11] = 8'h00;
    // addi x5,x0,3
    IMEM[12] = 8'h93; IMEM[13] = 8'h02; IMEM[14] = 8'h30; IMEM[15] = 8'h00;
    // addi x6,x0,4
    IMEM[16] = 8'h13; IMEM[17] = 8'h03; IMEM[18] = 8'h40; IMEM[19] = 8'h00;
    // addi x7,x0,5
    IMEM[20] = 8'h93; IMEM[21] = 8'h03; IMEM[22] = 8'h50; IMEM[23] = 8'h00;
    // addi x8,x0,6
    IMEM[24] = 8'h13; IMEM[25] = 8'h04; IMEM[26] = 8'h60; IMEM[27] = 8'h00;
    // addi x9,x0,7
    IMEM[28] = 8'h93; IMEM[29] = 8'h04; IMEM[30] = 8'h70; IMEM[31] = 8'h00;
    // add x9,x3,x4
    IMEM[32] = 8'hb3; IMEM[33] = 8'h84; IMEM[34] = 8'h41; IMEM[35] = 8'h00;
    // sub x10,x3,x4
    IMEM[36] = 8'h33; IMEM[37] = 8'h85; IMEM[38] = 8'h41; IMEM[39] = 8'h40;
    // and x11,x5,x6
    IMEM[40] = 8'hb3; IMEM[41] = 8'hf5; IMEM[42] = 8'h62; IMEM[43] = 8'h00;
    // or x12,x7,x8
    IMEM[44] = 8'h33; IMEM[45] = 8'he6; IMEM[46] = 8'h83; IMEM[47] = 8'h00;
    // xor x13,x8,x9
    IMEM[48] = 8'hb3; IMEM[49] = 8'h46; IMEM[50] = 8'h94; IMEM[51] = 8'h00;

    // Checking forwarding
    // add x9,x3,x4
    IMEM[52] = 8'hb3; IMEM[53] = 8'h84; IMEM[54] = 8'h41; IMEM[55] = 8'h00;
    // add x10,x9,x3
    IMEM[56] = 8'h33; IMEM[57] = 8'h85; IMEM[58] = 8'h34; IMEM[59] = 8'h00;
    // add x13,x8,x9
    IMEM[60] = 8'hb3; IMEM[61] = 8'h06; IMEM[62] = 8'h94; IMEM[63] = 8'h00;
end


integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    #10    
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