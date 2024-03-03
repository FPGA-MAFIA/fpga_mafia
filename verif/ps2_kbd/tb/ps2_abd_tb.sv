module ps2_abd_tb;
 
    logic Rst;
    logic ps2_clk, ps2_data; 
    logic [7:0]  ParallelData;
    logic        ParallelDataReady;
    

logic core_clk;
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
          Rst = 1'b1;
    #50  Rst = 1'b0;
    end: reset_gen
    

    initial begin: main 
        ps2_clk = 1'b1;
        #80
        send_byte_to_ps2(11'h1d); // send 'w'
        send_byte_to_ps2(11'h3d); // 
        send_byte_to_ps2(11'h5d); // 
        send_byte_to_ps2(11'hf0); // send 'release'
    end

    parameter V_TIMEOUT = 100000;
    initial begin : time_out
        #V_TIMEOUT
        $display("finished with timeout");
        $finish;

    end

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

logic [7:0] data_out_cc; 
logic       valid_cc; 
logic data_ready;

ps2_abd ps2_abd
(
    // PS2 interface
    .kbd_clk     (ps2_clk ) , //input  logic       kbd_clk,
    .data_in_kc  (ps2_data) , //input  logic       data_in_kc,
    // Core interface
    .core_clk      (core_clk   ) , //input  logic       core_clk,
    .core_rst      (Rst        ) , //input  logic       core_rst, 
    .core_read_en  (1'b0       ) , //input  logic       core_read_en,
    .data_out_cc   (data_out_cc) , //output logic [7:0] data_out_cc, 
    .valid_cc      (valid_cc   ) , //output logic       valid_cc, 
    .error         (           ) , //output logic       error,
    //CR - Control register & indications
    .data_ready    (data_ready ) , //output logic       data_ready,
    .scanf_en      (1'b1       )   //input  logic       scanf_en   
);
    
// monitor every time the data_out_cc 
always @(posedge core_clk) begin
    if (valid_cc) begin
        $display("data_out_cc = %h", data_out_cc);
    end
end

endmodule

