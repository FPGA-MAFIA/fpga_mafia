
module ps2_kbd_hw_top
import ps2_kbd_pkg::*;
(   input logic        kbd_clk,
    input logic        cc_clk,
    input logic        rst,
    input logic        kbd_data,
    input logic        kbd_scanf_en,
    input logic        kbd_pop,
    output logic       kbd_ready,
    output logic [7:0] kbd_scan_code_data
);

logic [7:0] parallel_data;
logic parallel_data_ready;
logic push_en;

assign push_en =  (kbd_scanf_en & parallel_data_ready);

//============================================
//       kbd_sp_converter interface             
//============================================
sp_converter sp_converter(
    .Rst(rst),
    .KbdClk(kbd_clk),
    .KbdSerialData(kbd_data),
    .ParallelData(parallel_data),
    .ParallelDataReady(parallel_data_ready)    
);

//============================================
//       kbd_grey_fifo interface              
//============================================
ps2_kbd_grey_fifo #(.DEPTH(FIFO_DEPTH), .WIDTH(FIFO_WIDTH)) ps2_kbd_grey_fifo(
    .kbd_clk(kbd_clk),
    .cc_clk (cc_clk), 
    .data_in(parallel_data),
    .write_en(push_en),
    .read_en(kbd_pop), 
    .rst(rst),
    .data_out(kbd_scan_code_data), 
    .empty(),
    .empty_sync(kbd_ready), 
    .full()
);

endmodule