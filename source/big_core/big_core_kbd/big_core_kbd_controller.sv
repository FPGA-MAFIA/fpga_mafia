`include "macros.sv"
module big_core_kdb_controller 
import common_pkg::*;
(
    input  logic       kbd_Clk,
    input  logic       core_Clk,
    input  logic       Rst, 
    input  logic       data_in,
    output logic [7:0] data_out, 
    output logic       valid, 
    output logic       extension,
    output logic       error
);

logic release_flag; 
logic struct_flag_0, struct_flag_1, struct_flag_2;
logic odd_parity_flag_0, odd_parity_flag_1, odd_parity_flag_2;

logic [32:0] shift_regs;
`MAFIA_DFF(shift_regs[32:0], {shift_regs[31:0], data_in}, kbd_Clk)

logic [3:0] serial_count;
logic RstSerialCount;
assign RstSerialCount = Rst | (serial_count == 4'd10);
`MAFIA_RST_VAL_DFF(serial_count, serial_count+1, kbd_Clk, RstSerialCount, 4'd0)

logic [7:0] release_code;
logic [1:0] struct_code_0, struct_code_1, struct_code_2;


assign release_code = shift_regs[20:13];
assign struct_code_0 = {shift_regs[0 ], shift_regs[10] };
assign struct_code_1 = {shift_regs[11], shift_regs[21]};
assign struct_code_2 = {shift_regs[22], shift_regs[32]};
assign data_out = shift_regs[8:1];


big_core_kbd_release_checker big_core_kbd_release_checker(
    .Clk            (kbd_Clk       ),
    .Rst            (Rst           ),
    .Data           (release_code  ),
    .Release_flag   (release_flag  )
);

big_core_kbd_struct_checker struct_checker_0(
    .Clk            (kbd_Clk),
    .Rst            (Rst),
    .Data           (struct_code_0),
    .Struct_flag    (struct_flag_0)
);
big_core_kbd_struct_checker struct_checker_1(
    .Clk            (kbd_Clk),
    .Rst            (Rst),
    .Data           (struct_code_1),
    .Struct_flag    (struct_flag_1)
);
big_core_kbd_struct_checker struct_checker_2(
    .Clk            (kbd_Clk),
    .Rst            (Rst),
    .Data           (struct_code_2),
    .Struct_flag    (struct_flag_2)
);

big_core_kbd_odd_parity_checker odd_parity_checker_0(
    .Clk                (kbd_Clk),
    .Rst                (Rst),
    .Data               ({shift_regs[8],data_out}),
    .odd_parity_flag    (odd_parity_flag_0)
);
big_core_kbd_odd_parity_checker odd_parity_checker_1(
    .Clk                (kbd_Clk),
    .Rst                (Rst),
    .Data               (shift_regs[20:12]),
    .odd_parity_flag    (odd_parity_flag_1)
);
big_core_kbd_odd_parity_checker odd_parity_checker_2(
    .Clk                (kbd_Clk),
    .Rst                (Rst),
    .Data               (shift_regs[31:23]),
    .odd_parity_flag    (odd_parity_flag_2)
);


endmodule