`include "macros.vh"

module core_rrv_kbd_odd_parity_checker
import core_rrv_pkg::*;
(
    input   logic       Clk,
    input   logic [8:0] Data,
    output  logic       odd_parity_error_flag
);

logic [3:0] set_bit_amount;
logic odd_error_flag;
always_comb begin
    set_bit_amount = 4'b0;
    for(int i = 0; i<9 ; i=i+1) begin
        set_bit_amount = set_bit_amount + Data[i];
    end
    odd_error_flag = ~set_bit_amount[0];
end

`MAFIA_DFF(odd_parity_error_flag, odd_error_flag, Clk)

endmodule