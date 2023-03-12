//
// File Name: arbiter.sv
// Description: The arbiter module.
//
`include "macros.sv"

module arbiter #(parameter int NUM_CLIENTS=4,
				parameter int DATA_WIDTH=32)
	(
	 input  logic                           clk,
	 input  logic                           rst,
	 input  var   [NUM_CLIENTS-1:0]  				  valid_candidate ,
	 input  var   [NUM_CLIENTS-1:0]  [DATA_WIDTH-1:0] candidate ,
	 output logic [NUM_CLIENTS-1:0] winner_dec_id,           
	 output logic                           valid,
	 //output logic [NUM_CLIENTS-1:0]         ack ,
	 output logic	[DATA_WIDTH-1:0]	    winner 
	);
//logic [$clog2(NUM_CLIENTS-1):0]  winner_id;	
//logic  [NUM_CLIENTS-1:0]         ack;
//logic [DATA_WIDTH-1:0]           winner ;
//INTERNAL VARIABLE
logic  [$clog2(NUM_CLIENTS-1):0] counter;	
logic [$clog2(NUM_CLIENTS-1):0]  nxt_counter;
logic [$clog2(NUM_CLIENTS-1):0]  former_counter;
logic                            next_valid;
logic [$clog2(NUM_CLIENTS)-1:0] winner_id;           
//counter
always@(*) // counter% NUM_CLIENTS
begin
	nxt_counter = counter;
	if (counter == NUM_CLIENTS-1)
	nxt_counter = '0;
	else 
	nxt_counter = counter + 1;
end
`MAFIA_RST_DFF(counter,nxt_counter,clk,rst)

//ack and reset former ack - TODO - 
//assign former_counter=(counter==0)? (NUM_CLIENTS-1):(counter-1); //maybe needed another ff
//`MAFIA_RST_DFF(ack[former_counter],'0,clk,rst);
//`MAFIA_EN_RST_DFF(ack[counter],1'b1,clk,valid_candidate[counter],rst);

//valid 
assign next_valid = valid_candidate[counter] ? 1'b1 : 0;
`MAFIA_RST_DFF(valid,next_valid,clk,rst)

//winner_id
`MAFIA_EN_RST_DFF(winner_id, counter, clk, valid_candidate[counter], rst)
always_comb begin
	winner_dec_id = '0;
	if(valid) winner_dec_id[winner_id] = 1'b1;
end
//winner
`MAFIA_EN_RST_DFF(winner, candidate[counter], clk, valid_candidate[counter], rst)

endmodule : arbiter

