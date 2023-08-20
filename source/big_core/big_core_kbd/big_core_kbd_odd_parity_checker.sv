`include "macros.sv"

module big_core_kbd_odd_parity_checker
import common_pkg::*;
(
    input   logic       Clk,
    input   logic       Rst,
    input   logic [8:0] Data,
    output  logic       odd_parity_flag
);

logic [3:0] set_bit_amount;
logic odd_flag;
always_comb begin
    set_bit_amount = 4'b0;
    for(int i = 0; i<9 ; i=i+1) begin
        set_bit_amount = set_bit_amount + Data[i];
    end
    odd_flag = (^set_bit_amount);
end

`MAFIA_RST_DFF(odd_parity_flag, odd_flag, Clk, Rst);

endmodule