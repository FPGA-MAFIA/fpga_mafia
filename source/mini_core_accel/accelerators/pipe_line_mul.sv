
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

    logic [16:0] acc [8:1];  
    logic [16:0] next_acc [7:0];  
    logic [7:0]  stored_multiplicand [8:0];
    logic [8:0]  pipe_is_full;
    logic [16:0] init_acc;


    assign pipe_is_full[0] = (rst || !start) ? 1'b0 : 1'b1;
    assign ready           = pipe_is_full[8]; // only after 8 stages the first result is ready

    // first stage (count from zero)
    assign stored_multiplicand[0]  = (start) ? multiplicand : 'b0;
    assign init_acc = (rst) ? 'b0 : (start) ? {8'b0, multiplier, 1'b0} : 'b0;
    assign next_acc[0] =  (init_acc[1:0] == 2'b01) ? $signed({init_acc[16:9]+stored_multiplicand[0], init_acc[8:1], init_acc[0]}) >>> 1 :
                          (init_acc[1:0] == 2'b10) ? $signed({init_acc[16:9]-stored_multiplicand[0], init_acc[8:1], init_acc[0]}) >>> 1 :
                                                                                                                $signed(init_acc) >>> 1 ;

    `MAFIA_DFF(acc[1], next_acc[0], clk)
    `MAFIA_DFF(pipe_is_full[1], pipe_is_full[0], clk)
    `MAFIA_DFF(stored_multiplicand[1], stored_multiplicand[0], clk)

    genvar stage_num;
    generate
        for(stage_num = 1; stage_num <=7; stage_num++) begin
            assign next_acc[stage_num] = (acc[stage_num][1:0] == 2'b01) ? $signed({acc[stage_num][16:9]+stored_multiplicand[stage_num], acc[stage_num][8:1], acc[stage_num][0]}) >>> 1 :
                                         (acc[stage_num][1:0] == 2'b10) ? $signed({acc[stage_num][16:9]-stored_multiplicand[stage_num], acc[stage_num][8:1], acc[stage_num][0]}) >>> 1 :
                                                                                                                                                         $signed(acc[stage_num]) >>> 1 ;   
            `MAFIA_DFF(acc[stage_num+1], next_acc[stage_num], clk)
            `MAFIA_DFF(pipe_is_full[stage_num+1], pipe_is_full[stage_num], clk)
            `MAFIA_DFF(stored_multiplicand[stage_num+1], stored_multiplicand[stage_num], clk)
        end
    endgenerate
    
    assign result = (!ready) ? 'b0 : (stored_multiplicand[8] == -8'd128) ? ~acc[8][16:1] + 1 : acc[8][16:1];

endmodule 

