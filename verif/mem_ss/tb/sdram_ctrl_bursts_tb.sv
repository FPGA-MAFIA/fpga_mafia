module sdram_ctrl_bursts_tb;
import sdram_ctrl_pkg::*;
 
// to run  ./build.py -dut mem_ss -top sdram_ctrl_bursts_tb -hw

logic Clk;
logic Rst;
// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 Clk = 1'b0;
        #5 Clk = 1'b1;
    end //forever
end//initial clock_gen

// ========================
// reset generation
// ========================
initial begin: reset_gen
     Rst = 1'b1;
#100 Rst = 1'b0;
end: reset_gen

    logic        Busy;
    logic [31:0] Address;
    logic        ReadReq;
    logic        WriteReq;
	logic [15:0] DataIn, DataOut;

    logic  [12:0]   DRAM_ADDR;  
	logic  [1:0]	DRAM_BA;   
	logic		   	DRAM_CAS_N; 
	logic	      	DRAM_CKE;   
	logic	     	DRAM_CLK;   
	logic     		DRAM_CS_N;  
	logic  [15:0]	DRAM_DQ;    
	logic		    DRAM_DQML;  
	logic			DRAM_RAS_N; 
	logic		    DRAM_DQMH;  
	logic		    DRAM_WE_N;   

sdram_ctrl_bursts sdram_ctrl_bursts(   
    .Clock(Clk),  
    .Rst(Rst),
    .Busy(Busy), 
    .Address(Address),
    .ReadReq(ReadReq),
    .WriteReq(WriteReq),
	.DataIn(DataIn),
	.DataOut(DataOut),
	//********************************
    //       SDRAM INTERFACE        
    //******************************** 
	.DRAM_ADDR(DRAM_ADDR),  
	.DRAM_BA(DRAM_BA),    
	.DRAM_CAS_N(DRAM_CAS_N), 
	.DRAM_CKE(DRAM_CKE),   
	.DRAM_CLK(DRAM_CLK),   
	.DRAM_CS_N(DRAM_CS_N), 
	.DRAM_DQ(),    
	.DRAM_DQML(DRAM_DQML),  
	.DRAM_RAS_N(DRAM_RAS_N), 
	.DRAM_DQMH(DRAM_DQMH),   
	.DRAM_WE_N(DRAM_WE_N)   
);

initial begin: main
	begin
		wait(sdram_ctrl_bursts.State==IDLE);
	end
	#10
	WriteReq = 1'b1;
	DataIn   = 16'h1234;
	Address  = 0;
	#100
	WriteReq = 1'b0;
	ReadReq  = 1'b1;
	Address  = 0;
	#200

	$finish;

end

parameter V_TIMEOUT = 10000; 
initial begin: time_out_detection
    #V_TIMEOUT
    $error("time out reached");
    $finish;
end

endmodule