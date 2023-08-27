`include "macros.sv"
module big_core_kdb_controller 
import common_pkg::*;
(
    // PS2 interface
    input  logic       kbd_clk,
    input  logic       data_in_kc,
    // Core interface
    input  logic       core_clk,
    input  logic       core_rst, 
    input  logic       core_read_en,
    output logic [7:0] data_out, 
    output logic       valid, 
    output logic       extension,
    output logic       error,
    //CR - Control register & indications
    output logic       data_ready,
    input  logic       scanf_en   
);




logic test;
`MAFIA_METAFLOP(test, scanf_en, kbd_clk)


logic        async_rst_core_sw;
logic        async_rst_core_hw;

logic        async_core_rst;
logic [32:0] shift_regs_kc;
logic [7:0]  data_out_kc;
logic [3:0]  word_count_kc, pre_word_count_kc; 
logic        word_flag_kc;
logic        release_flag_kc; 
logic [7:0]  release_data_kc;
logic [3:0]  next_word_count_kc;

//Shift register the serial ps2 input - Using the kbd_clk input as will
`MAFIA_DFF(shift_regs_kc[32:0], {shift_regs_kc[31:0], data_in_kc}, kbd_clk)
// Each word is 8 bit, but we have 11 bit transfer:
// 1 start bit, 8 data bits, 1 parity bit, 1 stop bit 
assign data_out_kc = shift_regs_kc[8:1];

// Using a specific async reset flops 
// using the core domain reset to reset the async reset flops of the kbd_clk domain
assign async_core_rst = core_rst;

//To achieve a counter of 11 bits need some special handling - FIXME review why
`MAFIA_DFF(pre_word_count_kc, word_count_kc, kbd_clk)
assign word_flag_kc = (word_count_kc == 4'd0) & (pre_word_count_kc == 4'd10);

// We have a async reset for the word count that is triggered from the core
// and a sync reset that is triggered from the kbd_clk
// The sync is entering the flop from the data pin
assign next_word_count_kc = (word_count_kc == 4'd10) ? 4'd0 : word_count_kc + 4'd1;
`MAFIA_EN_ASYNC_RST_VAL_DFF(word_count_kc, next_word_count_kc, kbd_clk, 1'b1, async_core_rst, 4'd0)

// bits 20:13 are the release data - when the release data is 0xFE we have a release and we can sample the data which is the [8:1]
assign release_data_kc = shift_regs_kc[20:13];
assign release_flag_kc = (release_data_kc == 8'hFE);

logic core_rstWordCount;
logic valid_kc;
`MAFIA_RST_DFF(valid_kc, release_flag_kc, word_flag_kc, core_rstWordCount)

logic [1:0] struct_data_0, struct_data_1, struct_data_2;
logic struct_error_flag;
assign struct_data_0 = {shift_regs_kc[0 ], shift_regs_kc[10]};
assign struct_data_1 = {shift_regs_kc[11], shift_regs_kc[21]};
assign struct_data_2 = {shift_regs_kc[22], shift_regs_kc[32]};
assign struct_error_flag = (struct_data_0 != 2'b10) | (struct_data_1 != 2'b10) | (struct_data_2 != 2'b10); 

logic [8:0] odd_parity_data_0, odd_parity_data_1, odd_parity_data_2;
logic odd_parity_flag_0, odd_parity_flag_1, odd_parity_flag_2;
logic odd_parity_error_flag;
assign odd_parity_data_0 = {shift_regs_kc[9], data_out_kc};
assign odd_parity_data_1 =  shift_regs_kc[20:12];
assign odd_parity_data_2 =  shift_regs_kc[31:23];
assign odd_parity_error_flag = (odd_parity_flag_0 | odd_parity_flag_1 | odd_parity_flag_2);

logic error_next;
always_comb begin : error_flag
    error_next = '0;
    if (struct_error_flag | odd_parity_error_flag) error_next = '1;
end
`MAFIA_DFF(error, error_next, word_flag_kc)

big_core_kbd_odd_parity_checker odd_parity_checker_0(
    .Clk                      (word_flag_kc),
    .Data                     (odd_parity_data_0),
    .odd_parity_error_flag    (odd_parity_flag_0)
);
big_core_kbd_odd_parity_checker odd_parity_checker_1(
    .Clk                      (word_flag_kc),
    .Data                     (odd_parity_data_1),
    .odd_parity_error_flag    (odd_parity_flag_1)
);
big_core_kbd_odd_parity_checker odd_parity_checker_2(
    .Clk                      (word_flag_kc),
    .Data                     (odd_parity_data_2),
    .odd_parity_error_flag    (odd_parity_flag_2)
);



big_core_kbd_gray_fifo big_core_kbd_gray_fifo(
  .kbd_clk_write (kbd_clk     ), // input  logic       kbd_clk_write,
  .core_clk_read (core_clk    ), // input  logic       core_clk_read,
  // kc clock domain will write the data
  .write_en      (valid_kc    ), // input  logic       write_en,
  .data_in       (data_out_kc ), // input  logic [7:0] data_in,
  // core clock domain will read the data
  .read_en       (core_read_en), // input  logic       read_en,
  .data_valid    (data_ready  ), // output logic       data_valid,
  .data_out      (data_out    )  // output logic [7:0] data_out
); 
assign valid = data_ready & core_read_en;

endmodule