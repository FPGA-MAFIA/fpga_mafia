
// implementation of 8 stage pipe lined booth multiplier

`include "macros.vh"

module pipe_line_mul 
import mini_core_accel_pkg::*;
(

    input logic         clk, 
    input logic         rst,
    input logic         start,
    input logic [7:0]   multiplier,
    input logic [7:0]   multiplicand,
    output logic        ready,
    output logic [15:0] result
);

    logic [16:0] acc [7:0];
    logic [16:0] next_acc [7:0];
    logic [7:0]  pre_ready;
    logic [16:0] pre_acc;

    assign pre_ready[0] = (rst) ? 1'b0 : 1'b1;
    assign ready        = pre_ready[7]; // onlu after 7 stages the result can be ready

    // first stage
    assign pre_acc = (rst) ? 'b0 : (start) ? {8'b0, multiplier, 1'b0} : 'b0;
    assign next_acc[0] =  (pre_acc[1:0] == 2'b01) ? $signed({pre_acc[16:9]+multiplicand, pre_acc[8:1], pre_acc[0]}) >>> 1 :
                          (pre_acc[1:0] == 2'b10) ? $signed({pre_acc[16:9]-multiplicand, pre_acc[8:1], pre_acc[0]}) >>> 1 :
                                                                                                  $signed(pre_acc) >>> 1 ;

    `MAFIA_DFF(acc[1], next_acc[0], clk)
    `MAFIA_DFF(pre_ready[1], pre_ready[0], clk)

    genvar stage_num;
    generate
        for(stage_num = 1; stage_num < 7; stage_num++) begin
            assign next_acc[stage_num] = (acc[stage_num][1:0] == 2'b01) ? $signed({acc[stage_num][16:9]+multiplicand, acc[stage_num][8:1], acc[stage_num][0]}) >>> 1 :
                                         (acc[stage_num][1:0] == 2'b10) ? $signed({acc[stage_num][16:9]-multiplicand, acc[stage_num][8:1], acc[stage_num][0]}) >>> 1 :
                                                                                                                                       $signed(acc[stage_num]) >>> 1 ;   
            `MAFIA_DFF(acc[stage_num+1], next_acc[stage_num], clk)
            `MAFIA_DFF(pre_ready[stage_num+1], pre_ready[stage_num], clk)
        end
    endgenerate
    
    logic [16:0] pre_result;
    assign pre_result =   (acc[7][1:0] == 2'b01) ? $signed({acc[7][16:9]+multiplicand, acc[7][8:1], acc[7][0]}) >>> 1 :
                          (acc[7][1:0] == 2'b10) ? $signed({acc[7][16:9]-multiplicand, acc[7][8:1], acc[7][0]}) >>> 1 :
                                                                                               $signed(pre_acc) >>> 1 ;
    assign result = (!ready) ? 'b0 : pre_result[16:1];

endmodule 

