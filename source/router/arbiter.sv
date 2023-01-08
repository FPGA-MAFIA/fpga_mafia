//
// File Name: arbiter.sv
// Description: The arbiter module.
//
module arbiter #(parameter int NUM_CLIENTS=4,
				parameter int DATA_WIDTH=8)
	(
	 input  logic                           clk,
	 input  logic                           rst,
	 input  logic                           req [NUM_CLIENTS-1:0],
	 input  logic [DATA_WIDTH-1:0]          din [0:NUM_CLIENTS-1],
	 output logic [$clog2(NUM_CLIENTS-1):0] src_num,           
	 output logic                           valid,
	 output logic [NUM_CLIENTS-1:0]         ack ,
	 output logic	[DATA_WIDTH-1:0]	    dout 
	);
logic [$clog2(NUM_CLIENTS-1):0]  src_num;	
logic  [NUM_CLIENTS-1:0]         ack;
logic [DATA_WIDTH-1:0]           dout ;
//INTERNAL VARIABLE
logic  [$clog2(NUM_CLIENTS-1):0] counter;	
logic                            valid;
logic [$clog2(NUM_CLIENTS-1):0]  nxt_cnt;
logic [$clog2(NUM_CLIENTS-1):0]  nxt_counter;
logic [$clog2(NUM_CLIENTS-1):0]  former_counter;
logic                            next_valid;
//counter
assign nxt_counter=(counter+1)%NUM_CLIENTS;
`RVC_RST_DFF(counter,nxt_counter,clk,rst);

//ack and reset former ack
assign former_counter=(counter==0)? (NUM_CLIENTS-1):(counter-1); //maybe needed another ff
`RVC_RST_DFF(ack[former_counter],'0,clk,rst);
`RVC_EN_RST_DFF(ack[counter],1'b1,clk,req[counter],rst);

//valid
assign next_valid = req[counter] ? 1'b1 : 0;
`RVC_RST_DFF(valid,next_valid,clk,rst);

//src_num
`RVC_EN_RST_DFF(src_num, counter, clk, req[counter], rst);

//dout
`RVC_EN_RST_DFF(dout, din[counter], clk, req[counter], rst);

endmodule : arbiter

