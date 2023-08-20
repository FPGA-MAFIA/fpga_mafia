`include "macros.sv"
module big_core_mem_wrap 
import common_pkg::*;
(
    input  logic       kbd_Clk,
    input  logic       core_Clk,
    input  logic       Rst, 
    input  logic       data_in,
    output logic [7:0] data_out, 
    output logic       valid, 
    output logic       extention,
    output logic       error
);

logic release_flag; 
logic struct_flag_0, struct_flag_1, struct_flag_2;
logic odd_parity_flag_0, odd_parity_flag_1, odd_parity_flag_2;

logic [32:0] shift_regs;
`MAFIA_DFF(shift_regs, {shift_regs[31:0], data_in}, kbd_Clk)


big_core_kbd_release_checker big_core_kbd_release_checker(
    .Clk            (core_Clk           ),
    .Rst            (Rst                ),
    .Data           (shift_reg[20:13]   ),
    .Release_flag   (release_flag       )
);

big_core_kbd_struct_checker struct_checker_0(
    .Clk            (core_Clk),
    .Rst            (Rst),
    .Data           ({shift_reg[10], shift_reg[0]}),
    .Struct_flag    (struct_flag_0)
);
big_core_kbd_struct_checker struct_checker_1(
    .Clk            (core_Clk),
    .Rst            (Rst),
    .Data           ({shift_reg[21], shift_reg[11]}),
    .Struct_flag    (struct_flag_1)
);
big_core_kbd_struct_checker struct_checker_2(
    .Clk            (core_Clk),
    .Rst            (Rst),
    .Data           ({shift_reg[32], shift_reg[22]}),
    .Struct_flag    (struct_flag_2)
);

big_core_kbd_odd_parity_checker odd_parity_checker_0(
    .Clk                (core_Clk),
    .Rst                (Rst),
    .Data               (shift_reg[9:1]),
    .odd_parity_flag    (odd_parity_flag_0)
);
big_core_kbd_odd_parity_checker odd_parity_checker_1(
    .Clk                (core_Clk),
    .Rst                (Rst),
    .Data               (shift_reg[20:12]),
    .odd_parity_flag    (odd_parity_flag_1)
);
big_core_kbd_odd_parity_checker odd_parity_checker_2(
    .Clk                (core_Clk),
    .Rst                (Rst),
    .Data               (shift_reg[31:23]),
    .odd_parity_flag    (odd_parity_flag_2)
);


endmodule