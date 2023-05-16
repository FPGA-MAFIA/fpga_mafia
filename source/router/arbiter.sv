//-----------------------------------------------------------------------------
// Title            : 
// Project          : 
//-----------------------------------------------------------------------------
// File             : <TODO>
// Original Author  : 
// Code Owner       : 
// Created          : 
//-----------------------------------------------------------------------------
// Description : 
//
//
//-----------------------------------------------------------------------------

// File Name: arbiter.sv
// Description: The arbiter module.
`include "macros.sv"

module arbiter #(parameter int NUM_CLIENTS=4,
                parameter int DATA_WIDTH=32)
    (
     input  logic                   clk,
     input  logic                   rst,
     // ctrl path
     input  var   [NUM_CLIENTS-1:0] valid_candidate ,
     output logic [NUM_CLIENTS-1:0] winner_dec_id
    );

logic                   valid_winner;
logic [NUM_CLIENTS-1:0] last_winner;
logic [NUM_CLIENTS-1:0] mask_out;
logic [NUM_CLIENTS-1:0] mask_candidate;
logic [NUM_CLIENTS-1:0] first_top;
logic [NUM_CLIENTS-1:0] first_bottom;
logic hit_top;
logic [3:0] enc_last_winner;
logic [3:0] next_enc_last_winner;


`MAFIA_EN_RST_DFF(last_winner  , winner_dec_id        , clk, valid_winner, rst)
`MAFIA_RST_DFF(enc_last_winner , next_enc_last_winner , clk,               rst)
always_comb begin
        mask_out = '0;
    for(int i =0; i < NUM_CLIENTS; i++ )begin
        if(enc_last_winner >= i)begin
        mask_out[i] = 1'b1;
        end
 // $display("##################################### mask_out[%0d] = %b last_winner = %0d %b enc_last_winner = %0d at time %0t",i, mask_out[i],last_winner,last_winner,enc_last_winner,$time);
    end
end


assign mask_candidate = (valid_candidate & (~mask_out));
`FIND_FIRST(first_top    , mask_candidate)
`FIND_FIRST(first_bottom , valid_candidate)

assign hit_top = (|first_top);
assign winner_dec_id = hit_top ? first_top : first_bottom;
assign valid_winner = (|winner_dec_id);

//`ENCODER(winner_dec_id,next_enc_last_winner)
always_comb begin
case (winner_dec_id)
4'b0001 : next_enc_last_winner = 4'd0;
4'b0010 : next_enc_last_winner = 4'd1;
4'b0100 : next_enc_last_winner = 4'd2;
4'b1000 : next_enc_last_winner = 4'd3;
default : next_enc_last_winner = 4'd0;
endcase
end

//====================
// winner_dec_id[1:0]       = 2'b10  ;
// mask_out[3:0]     = 4'b0011;
// candidate[3:0]    = 4'b1101;
// first_top[3:0]    = 4'b0100;
// first_bottom[3:0] = 4'b0001;
endmodule

