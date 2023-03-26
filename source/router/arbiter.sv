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
	 input  logic                        		      clk,
	 input  logic                         			  rst,
	 // ctrl path
	 input  var   [NUM_CLIENTS-1:0]  				  valid_candidate ,
	 output logic [NUM_CLIENTS-1:0] 				  winner_dec_id,           
	 // data path
	 input  var   [NUM_CLIENTS-1:0]  [DATA_WIDTH-1:0] candidate ,
	 output logic                          			  valid_winner,
	 output logic [DATA_WIDTH-1:0]	   			 	  data_winner 
	);

logic [NUM_CLIENTS-1:0] last_winner;
logic [NUM_CLIENTS-1:0] mask_out;
logic [NUM_CLIENTS-1:0] mask_candidate;
logic [NUM_CLIENTS-1:0] first_top;
logic [NUM_CLIENTS-1:0] first_bottom;
logic hit_top;

`MAFIA_EN_RST_DFF(last_winner , winner_dec_id , clk, valid_winner, rst)
always_comb begin
        mask_out = '0;
    for(int i =0; i < NUM_CLIENTS; i++ )begin
        mask_out[i] = (last_winner > i);
    end
end
assign mask_candidate = (valid_candidate & (~mask_out));
`FIND_FIRST(first_top    , mask_candidate)
`FIND_FIRST(first_bottom , valid_candidate)

assign hit_top = (|first_top);
assign winner_dec_id = hit_top ? first_top : first_bottom;
assign valid_winner = (|winner_dec_id);

//====================
// Mux out the data_winner
//====================
always_comb begin
	data_winner = '0;
	for(int i =0; i < NUM_CLIENTS; i++ )begin
		data_winner = winner_dec_id[i] ? candidate[i] : data_winner;
	end
end

//====================
// winner_dec_id[1:0]       = 2'b10  ;
// mask_out[3:0]     = 4'b0011;
// candidate[3:0]    = 4'b1101;
// first_top[3:0]    = 4'b0100;
// first_bottom[3:0] = 4'b0001;
endmodule

