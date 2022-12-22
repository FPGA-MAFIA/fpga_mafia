//
// File Name: fifo.sv
// Description: The fifo module.
//
module fifo #(parameter int DATA_WIDTH = 8, 
			  parameter int FIFO_DEPTH = 3)
	(
	 input 					 clk,
	 input 					 mrst_n,
	 input 					 srst_n,
	 input 					 wr,
	 input [DATA_WIDTH-1:0]  wr_data,
	 input 					 rd,
	 output [DATA_WIDTH-1:0] rd_data,
	 output 				 full,
	 output 				 empty
	 );
reg [DATA_WIDTH-1:0] rd_data;
//INTERNAL VARIABLES
reg [FIFO_DEPTH-1:0] w_counter;//point to next cell in memory that will be writen  
reg [FIFO_DEPTH-1:0] r_counter;//point to next cell will readen
reg [FIFO_DEPTH:0] fifo_status;//flag to empty and full
reg [DATA_WIDTH-1:0] memory [0:FIFO_DEPTH-1];


assign full=(fifo_status==(FIFO_DEPTH));
assign empty=(fifo_status==0);
assign rd_data= memory[r_counter];

always @(posedge clk or negedge mrst_n)
begin:WRITE_COUNTER
	if(!mrst_n || !srst_n) begin
		w_counter<=0;
	end
	else if((wr && !full)||(wr && rd && full)) begin
		if (w_counter==FIFO_DEPTH-1)begin
			w_counter<=0;
		end
		else begin
			w_counter<=w_counter+1;
		end
	end
end

always @(posedge clk or negedge mrst_n)
begin: READ_COUNTER
	if(!mrst_n || !srst_n)begin
		r_counter<=0;
	end
	else if((rd && !empty)||(rd && wr && empty))begin
		if(r_counter==FIFO_DEPTH-1)begin
			r_counter<=0;
		end
		else begin
			r_counter<=r_counter+1;
		end
	end
end


always @(posedge clk or negedge mrst_n)
begin: STATUS
	if(!mrst_n ||!srst_n) begin
		fifo_status<=0;
	end
	else begin
		if((wr && !full) && !(rd && !empty)) begin
			fifo_status<= fifo_status +1;
		end
		if((rd && !empty) && !(wr && !full)) begin
			fifo_status<= fifo_status -1;
		end
	end
end

always @(posedge clk or negedge mrst_n)
begin: MEMORY_WRITE
	if (!srst_n || !mrst_n) begin
		for(int i=0; i<FIFO_DEPTH; i = i+1) begin
			memory[i]<=0;
		end
	end
	else if((wr && !full)||(wr && full && rd))begin
		memory[w_counter]<=wr_data;
	end
end

endmodule : fifo

