//
// File Name: fifo.sv
// Description: The fifo module.
//
`include "macros.sv"
module fifo #(parameter int DATA_WIDTH = 8, 
			  parameter int FIFO_DEPTH = 3)
	(
	 input  logic					 clk,
	 input  logic				     rst,
	 input  logic					 push,
	 input  logic[DATA_WIDTH-1:0]    push_data,
	 input  logic					 pop,
	 output logic [DATA_WIDTH-1:0]   pop_data,
	 output logic				     full,
	 output logic				     empty
	 );
logic [DATA_WIDTH-1:0] pop_data;
//INTERNAL VARIABLES
logic [FIFO_DEPTH-1:0] w_counter;//point to next cell in memory that will be writen  
logic [FIFO_DEPTH-1:0] r_counter;//point to next cell will readen
logic [FIFO_DEPTH:0]   fifo_status;//flag to empty and full
logic [DATA_WIDTH-1:0] memory [0:FIFO_DEPTH-1];
logic                  en_push_fifo;
logic [FIFO_DEPTH-1:0] next_w_counter;
logic                  en_pop_fifo;
logic [FIFO_DEPTH-1:0] next_r_counter;
logic                  en_status_plus;
logic                  en_status_minus;
logic                  en_status;
logic [FIFO_DEPTH:0]   next_fifo_status;

//assigning to full, empty, pop_data
assign full=(fifo_status==(FIFO_DEPTH));
assign empty=(fifo_status==0);
assign pop_data= memory[r_counter];

//pointer to the next place to push to it
assign en_push_fifo =(push &&!full)||(push && pop && full);
assign next_w_counter=(w_counter==FIFO_DEPTH-1)? '0 : (w_counter+1);
`RVC_EN_RST_DFF(w_counter, next_w_counter, clk, en_push_fifo, rst);

//pointer to the next place to pop from it
assign en_pop_fifo=(pop && !empty)||(pop && push && empty);
assign next_r_counter=(r_counter==FIFO_DEPTH-1)?'0 : (r_counter+1);
`RVC_EN_RST_DFF(r_counter, next_r_counter, clk, en_pop_fifo, rst);

//fifo_status
assign en_status_plus=(push && !full) && !(pop && !empty);
assign en_status_minus=(pop && !empty)&& !(push && !full);
assign en_status=en_status_plus |en_status_minus;
assign next_fifo_status=en_status_plus ? (fifo_status+1):(fifo_status-1);
`RVC_EN_RST_DFF(fifo_status, next_fifo_status, clk, en_status, rst);

always @(posedge clk)
begin: MEMORY_WRITE
	if (rst) begin
		for(int i=0; i<FIFO_DEPTH; i = i+1) begin
			memory[i]<=0;
		end
	end
	else if((push && !full)||(push && full && pop))begin
		memory[w_counter]<=push_data;
	end
end


endmodule : fifo

