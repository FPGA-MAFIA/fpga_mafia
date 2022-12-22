//
// File Name: arbiter.sv
// Description: The arbiter module.
//
module arbiter #(parameter int NUM_CLIENTS=4,
				parameter int DATA_WIDTH=8)
	(
	 input 						clk,
	 input 						mrst_n,
	 input 						srst_n,
	 input req [NUM_CLIENTS-1:0],
	 input [DATA_WIDTH-1:0] din [0:NUM_CLIENTS-1],
	 output [$clog2(NUM_CLIENTS-1):0]src_num,           
	 output 					valid,
	 output [NUM_CLIENTS-1:0] ack ,
	 output 	[DATA_WIDTH-1:0]	dout 
	);
reg [$clog2(NUM_CLIENTS-1):0] src_num;	
reg  [NUM_CLIENTS-1:0] ack;
reg [DATA_WIDTH-1:0]dout ;
//INTERNAL VARIABLE
reg  [$clog2(NUM_CLIENTS-1):0] counter;	
reg valid;
wire[$clog2(NUM_CLIENTS-1):0]  nxt_cnt;
	


	always @(posedge clk or negedge mrst_n )
	begin : COUNTER
		if (!mrst_n) begin
			counter<=0;
		end
		else if(!srst_n)begin
			counter<=0;
		end
		else begin
			 counter<=(counter+1)%NUM_CLIENTS;
		end
		
	end


	always @ (posedge clk or negedge mrst_n)                   
	begin : OUTPUTS

		if (!mrst_n || !srst_n) begin
			valid<=0;
			src_num<=0;
			dout<=0;
			ack<=0;
		end
		else begin
			ack<=0;
			if (req[counter]) begin
				valid<=1;
				src_num<=counter;
				dout<=din[counter];
				ack[counter]<=1;
			end
		
			else begin
				valid<=0;
			end
		end
	end



endmodule : arbiter

