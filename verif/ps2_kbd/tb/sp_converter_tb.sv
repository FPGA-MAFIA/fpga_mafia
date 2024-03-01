

// systemverilog file to create the task needed for driving the PS2 interface of the Core DUT
// will have a simple task that accepts a byte and sends it to the PS2 interface (clock and data lines)
//-----------------------------------------------------------------------------
// Title            : Serial to paraller PS2 data converter tb
// Project          : PS2 keyboard
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Created          : 2/2024
//-----------------------------------------------------------------------------
// Description :
// Converts  serial data bits comes from PS2 into parallel 8 bits
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------


module sp_converter_tb();
 
    logic Rst;
    logic ps2_clk, ps2_data; 
    logic [7:0]  ParallelData;
    logic        ParallelDataReady;
    
    // ========================
    // reset generation
    // ========================
    initial begin: reset_gen
          Rst = 1'b1;
    #100  Rst = 1'b0;
    end: reset_gen
    
    sp_converter sp_converter(
        .Rst(Rst),
        .KbdClk(ps2_clk),
        .KbdSerialData(ps2_data),
        .ParallelData(ParallelData),
        .ParallelDataReady(ParallelDataReady)    
    );

    initial begin: main 
        #80
        ps2_clk = 1'b0;
        #5 ps2_clk = 1'b1;
        #5 ps2_clk = 1'b0;
        #5 ps2_clk = 1'b1;
        send_byte_to_ps2(8'h1d);   // send 'w'
        send_byte_to_ps2(11'hf0);  // send 'release'
        $finish;

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
    #10;
endtask

endmodule
