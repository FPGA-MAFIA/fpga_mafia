

// systemverilog file to create the task needed for driving the PS2 interface of the Core DUT
// will have a simple task that accepts a byte and sends it to the PS2 interface (clock and data lines)

task send_byte_to_ps2 (input logic [7:0] data);
    #10;
    // Clock for release
    //Start bit
    #40 ps2_data = 1'b0;// 40
    #10 ps2_clk = 1'b0;// 50
    #50 ps2_clk = 1'b1;// 100
    // bit[0]
    #40 ps2_data = data[0];//140
    #10 ps2_clk = 1'b0;// 150
    #50 ps2_clk = 1'b1;// 200
    // bit[1]
    #40 ps2_data = data[1];// 240
    #10 ps2_clk = 1'b0;// 250
    #50 ps2_clk = 1'b1;// 300
    // bit[2]
    #40 ps2_data = data[2];// 340
    #10 ps2_clk = 1'b0;// 350
    #50 ps2_clk = 1'b1;// 400
    // bit[3]
    #40 ps2_data = data[3];// 440
    #10 ps2_clk = 1'b0;// 450
    #50 ps2_clk = 1'b1;// 500
    // bit[4]
    #40 ps2_data = data[4];//540
    #10 ps2_clk = 1'b0;// 550
    #50 ps2_clk = 1'b1;// 600
    // bit[5]
    #40 ps2_data = data[5];// 640
    #10 ps2_clk = 1'b0;// 650
    #50 ps2_clk = 1'b1;// 700
    // bit[6]
    #40 ps2_data = data[6];//740
    #10 ps2_clk = 1'b0;// 750
    #50 ps2_clk = 1'b1;// 800
    // bit[7]
    #40 ps2_data = data[7];//840
    #10 ps2_clk = 1'b0;// 850
    #50 ps2_clk = 1'b1;// 900
    // Parity bit
    #40 ps2_data = !(data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7]);//940
    #10 ps2_clk = 1'b0;// 950
    #50 ps2_clk = 1'b1;// 1000
    // Stop bit
    #40 ps2_data = 1'b1;//1040
    #10 ps2_clk = 1'b0;// 1050
    #50 ps2_clk = 1'b1;// 1100
    #300;
endtask
