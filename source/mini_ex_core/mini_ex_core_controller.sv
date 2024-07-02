

`include "macros.vh"

module mini_ex_core_controller
import mini_ex_core_pkg::*;
(
    input logic                 Clock,
    input logic                 Rst,
    input var t_op_type         OpType,
    input logic [4:0]           AluInstr,
    output var  t_contoller_out CntrlOut,
);

//current cycle is Q101H - getting info from decode
//Info to WB Mux + RegWrEnable needs to go into DFF (Q102H)

always_comb begin 
    if(Rst) begin
        CntrlOut.JmpEnableQ100H = 0;
        RegWrEnableQ101H = 0;
        AluMux1SelQ101H = 0;
        AluMux2SelQ101H = 0;
        WbMuxSelQ102H = 0;
    end

end 

endmodule