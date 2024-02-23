
`include "macros.sv"

module core_rrv_kbd_release_checker
import core_rrv_pkg::*;
(
    input   logic       Clk,
    input   logic       Rst,
    input   logic [7:0] Data,
    output  logic       Release_flag
);

logic rls_flag;
assign rls_flag = (Data == 8'hFE);
`MAFIA_RST_DFF(Release_flag, rls_flag, Clk, Rst)

endmodule