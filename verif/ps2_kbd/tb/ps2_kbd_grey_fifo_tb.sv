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
logic empty, full;


//=======================================
// keyboard clock generator (slow domain)
//======================================
initial begin :kb2_clk_generator
    forever begin
        #5 kbd_clk = 1'b0;
        #5 kbd_clk = 1'b1;
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


ps2_kbd_grey_fifo #(.DEPTH(16), .WIDTH()) ps2_kbd_grey_fifo(
    .kbd_clk(kbd_clk),
    .cc_clk (cc_clk), 
    .data_in(data_in),
    .write_en(write_en),
    .read_en(read_en),
    .rst(rst),
    .data_out(data_out),
    .empty(empty),
    .full(full)
);

logic [3:0] data;

initial begin :main
    #100;
    for(data = 0; data <=4'hf; data++) begin : write_to_fifo
       write_en = 1'b1;
       @(posedge kbd_clk); 
       data_in = data;
       $display("empty: %1h, full = %1h", empty, full);
       if(full)
        break; 
    end

    while(!empty) begin: read_from_fifo
      read_en = 1'b1;
      write_en = 1'b0;
      @(posedge cc_clk);
      $display("data_out: %1h", data_out);   
      #10;  
    end
    
    $finish;

end

parameter V_TIMEOUT = 1000;
initial begin : time_out
    #V_TIMEOUT;
    $display("finished with timeout");
    $finish;
end
endmodule