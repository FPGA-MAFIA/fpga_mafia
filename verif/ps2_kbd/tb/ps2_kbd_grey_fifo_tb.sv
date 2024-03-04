//-----------------------------------------------------------------------------
// Title            : FIFO TB
// Project          : PS2 keyboard
//-----------------------------------------------------------------------------
// File             : 
// Original Author  : Amichai Ben-David
// Created          : 3/2024
//-----------------------------------------------------------------------------
// Description :
// Implementation of FIFO with two clock domains. To decrease a probability for 
// metastability we use two FF synchronizer and Encodes write/read pointers
// to grey code
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------

module ps2_kbd_grey_fifo_tb;

logic kbd_clk;
logic cc_clk;
logic rst;
logic [7:0] data_in, data_out;
logic write_en, read_en;
logic empty, empty_sync, full;

logic [7:0] fifo_data[0:7];
initial begin : data_init
    fifo_data[0] = 8'h00;
    fifo_data[1] = 8'h01;
    fifo_data[2] = 8'h02;
    fifo_data[3] = 8'h03;
    fifo_data[4] = 8'h04;
    fifo_data[5] = 8'h05;
    fifo_data[6] = 8'h06;
    fifo_data[7] = 8'h07;
end : data_init

//=======================================
// keyboard clock generator (slow domain)
//======================================
initial begin :kb2_clk_generator
    forever begin
        #10 kbd_clk = 1'b0;
        #10 kbd_clk = 1'b1;
    end
end

//=======================================
// cpu clock generator (fast domain)
//======================================
initial begin :cpu_clk_generator
    forever begin
        #5 cc_clk = 1'b0;
        #5 cc_clk = 1'b1;
    end
end

//===================
// reset generate
//===================
initial begin : rst_generator
     rst = 1'b1;
#100 rst = 1'b0; 
end


ps2_kbd_grey_fifo #(.DEPTH(8), .WIDTH(8)) ps2_kbd_grey_fifo(
    .kbd_clk(kbd_clk),
    .cc_clk (cc_clk), 
    .data_in(data_in),
    .write_en(write_en),
    .read_en(read_en),
    .rst(rst),
    .data_out(data_out),
    .empty(empty),
    .empty_sync(empty_sync),
    .full(full)
);

logic [3:0] data;

initial begin :main
    #100;
    push_data(fifo_data[0]);
    push_data(fifo_data[1]);
    push_data(fifo_data[2]);
    push_data(fifo_data[3]);
    push_data(fifo_data[4]);
    push_data(fifo_data[5]);
    push_data(fifo_data[6]);
    push_data(fifo_data[7]);

    pop_data();
    pop_data();
    pop_data();
    pop_data();
    pop_data();
    pop_data();
    pop_data();
    pop_data();
    
    $finish;

end

parameter V_TIMEOUT = 1000;
initial begin : time_out
    #V_TIMEOUT;
    $display("finished with timeout");
    $finish;
end

task push_data(input logic[7:0] data);
    write_en = 1'b1;
    @(posedge kbd_clk);
    data_in = data;
    #20; 
endtask

task pop_data();
      read_en = 1'b1;
      @(posedge cc_clk);
      #10;  
endtask

endmodule