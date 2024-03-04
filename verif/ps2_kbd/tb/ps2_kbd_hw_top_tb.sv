module ps2_kbd_hw_top_tb;
    
    logic core_clk;
    logic ps2_clk;
    logic rst;
    logic core_read_en;
    logic [7:0] kbd_scan_code_data;
    logic kbd_ready;
    logic kbd_scanf_en;
    logic ps2_data;

    // ===================
    // Clock generation
    // ===================
    initial begin: clk_gen
            core_clk = 1'b0;
        forever #1 core_clk = ~core_clk; 
    end: clk_gen

    // ========================
    // reset generation
    // ========================
    initial begin: reset_gen
          rst = 1'b1;
    #50  rst = 1'b0;
    end: reset_gen
    

    initial begin: main 
        ps2_clk = 1'b1;
        #80
        send_byte_to_ps2(11'h1d); // send 'w'
        pop_data();
        send_byte_to_ps2(11'h3d); // 
        pop_data();
        send_byte_to_ps2(11'h5d); // 
        pop_data();
        send_byte_to_ps2(11'hf0); // send 'release'
        pop_data();
    end

    parameter V_TIMEOUT = 100000;
    initial begin : time_out
        #V_TIMEOUT
        $display("finished with timeout");
        $finish;

    end

assign kbd_scanf_en = 1'b1; // we assume that rvc_scanf eas called
ps2_kbd_hw_top ps2_kbd_hw_top
(   .kbd_clk(ps2_clk),
    .cc_clk(core_clk),
    .rst(rst),
    .kbd_data(ps2_data),
    .kbd_scanf_en(kbd_scanf_en),
    .kbd_pop(core_read_en),
    .kbd_ready(kbd_ready),
    .kbd_scan_code_data(kbd_scan_code_data)
);
    
task pop_data ();
    @(posedge core_clk);
        core_read_en = 1'b1;
    @(posedge core_clk);
        core_read_en = 1'b0;
    $display("data_out_cc = %h", kbd_scan_code_data);
endtask

task send_byte_to_ps2 (input logic [7:0] data);
    // Clock for release
    //Start bit
    #4 ps2_data = 1'b0;// 4
    #1 ps2_clk = 1'b0;// 5
    #5 ps2_clk = 1'b1;// 10
    // bit[0]
    #4 ps2_data = data[0];//14  
    #1 ps2_clk = 1'b0;// 15
    #5 ps2_clk = 1'b1;// 20
    // bit[1]
    #4 ps2_data = data[1];// 24
    #1 ps2_clk = 1'b0;// 25
    #5 ps2_clk = 1'b1;// 30
    // bit[2]
    #4 ps2_data = data[2];// 34
    #1 ps2_clk = 1'b0;// 35
    #5 ps2_clk = 1'b1;// 40
    // bit[3]
    #4 ps2_data = data[3];// 44
    #1 ps2_clk = 1'b0;// 45
    #5 ps2_clk = 1'b1;// 50
    // bit[4]
    #4 ps2_data = data[4];//54
    #1 ps2_clk = 1'b0;// 55
    #5 ps2_clk = 1'b1;// 60
    // bit[5]
    #4 ps2_data = data[5];// 64
    #1 ps2_clk = 1'b0;// 65
    #5 ps2_clk = 1'b1;// 70
    // bit[6]
    #4 ps2_data = data[6];//74
    #1 ps2_clk = 1'b0;// 75
    #5 ps2_clk = 1'b1;// 80
    // bit[7]
    #4 ps2_data = data[7];//84
    #1 ps2_clk = 1'b0;// 85
    #5 ps2_clk = 1'b1;// 90
    // Parity bit
    #4 ps2_data = !(data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]);//94
    #1 ps2_clk = 1'b0;// 95
    #5 ps2_clk = 1'b1;// 100
    // Stop bit
    #4 ps2_data = 1'b1;//104
    #1 ps2_clk = 1'b0;// 105
    #5 ps2_clk = 1'b1;// 110
    #100;
endtask

endmodule

