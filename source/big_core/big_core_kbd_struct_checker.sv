`include "macros.sv"

module big_core_kbd_struct_checker
import common_pkg::*;
(
    input   logic       Clk,
    input   logic       Rst,
    input   logic [1:0] Data,
    output  logic       Struct_flag
);

logic st_flag;
assign st_flag = (Data == 1'b10);
MAFIA_RST_DFF(Struct_flag, st_flag, Clk, Rst);

endmodule