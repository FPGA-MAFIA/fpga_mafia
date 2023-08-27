`include "macros.sv"
module big_core_kdb_controller 
import common_pkg::*;
(
    input  logic       kbd_clk,
    input  logic       core_clk,
    input  logic       core_rst, 
    input  logic       data_in,
    input  logic       core_read_en,
    output logic [7:0] data_out, 
    output logic       valid, 
    output logic       extension,
    output logic       error
);

logic [32:0] shift_regs;
`MAFIA_DFF(shift_regs[32:0], {shift_regs[31:0], data_in}, kbd_clk)

logic [7:0] async_data_out;
assign async_data_out = shift_regs[8:1];

logic [3:0] word_count, pre_word_count; 
logic word_flag;
logic core_rstWordCount;
`MAFIA_DFF(pre_word_count, word_count, kbd_clk)

assign word_flag = (word_count == 4'd0) & (pre_word_count == 4'd10);
assign core_rstWordCount = core_rst | (word_count == 4'd10);
`MAFIA_RST_VAL_DFF(word_count, word_count+1, kbd_clk, core_rstWordCount, 4'd0)

logic release_flag; 
logic [7:0] release_data;
assign release_data = shift_regs[20:13];
assign release_flag = (release_data == 8'hFE);

`MAFIA_RST_DFF(valid, release_flag, word_flag, core_rstWordCount)

logic [1:0] struct_data_0, struct_data_1, struct_data_2;
logic struct_error_flag;
assign struct_data_0 = {shift_regs[0 ], shift_regs[10]};
assign struct_data_1 = {shift_regs[11], shift_regs[21]};
assign struct_data_2 = {shift_regs[22], shift_regs[32]};
assign struct_error_flag = (struct_data_0 != 2'b10) | (struct_data_1 != 2'b10) | (struct_data_2 != 2'b10); 

logic [8:0] odd_parity_data_0, odd_parity_data_1, odd_parity_data_2;
logic odd_parity_flag_0, odd_parity_flag_1, odd_parity_flag_2;
logic odd_parity_error_flag;
assign odd_parity_data_0 = {shift_regs[9], async_data_out};
assign odd_parity_data_1 =  shift_regs[20:12];
assign odd_parity_data_2 =  shift_regs[31:23];
assign odd_parity_error_flag = (odd_parity_flag_0 | odd_parity_flag_1 | odd_parity_flag_2);

logic error_next;
always_comb begin : error_flag
    error_next = '0;
    if (struct_error_flag | odd_parity_error_flag) error_next = '1;
end
`MAFIA_DFF(error, error_next, word_flag)

big_core_kbd_odd_parity_checker odd_parity_checker_0(
    .Clk                      (word_flag),
    .Data                     (odd_parity_data_0),
    .odd_parity_error_flag    (odd_parity_flag_0)
);
big_core_kbd_odd_parity_checker odd_parity_checker_1(
    .Clk                      (word_flag),
    .Data                     (odd_parity_data_1),
    .odd_parity_error_flag    (odd_parity_flag_1)
);
big_core_kbd_odd_parity_checker odd_parity_checker_2(
    .Clk                      (word_flag),
    .Data                     (odd_parity_data_2),
    .odd_parity_error_flag    (odd_parity_flag_2)
);



big_core_kbd_gray_fifo big_core_kbd_gray_fifo(
  .kbd_clk_write (kbd_clk        ), // input  logic       kbd_clk_write,
  .core_clk_read (core_clk       ), // input  logic       core_clk_read,
  //.Rst           (Rst          ), // input  logic       Rst,
  .write_en      (valid          ), // input  logic       write_en,
  .read_en       (core_read_en   ), // input  logic       read_en,
  .data_in       (async_data_out ), // input  logic [7:0] data_in,
  .data_out      (data_out       ) // output logic [7:0] data_out
); 

endmodule