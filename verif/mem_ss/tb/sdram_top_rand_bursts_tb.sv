module sdram_top_rand_bursts_tb;
import sdram_ctrl_pkg::*;

logic Clk;
logic Rst;
logic Busy;

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
initial begin: negative_reset_gen  // immitates pressed key in FPGA
     Rst = 1'b0;
#100 Rst = 1'b1;
end: negative_reset_gen

initial begin:main
    Busy     = 1;
    #100
    Busy = 0;
    #3000

    $finish;
end

parameter V_TIMEOUT = 10000; 
initial begin: time_out_detection
    #V_TIMEOUT
    $error("time out reached");
    $finish;
end

	logic [12:0]    DRAM_ADDR;  
	logic [1:0]	    DRAM_BA;    
	logic		    DRAM_CAS_N; 
	logic	      	DRAM_CKE;   
	logic	     	DRAM_CLK;   
	logic     		DRAM_CS_N;  
	logic		    DRAM_DQML;  
	logic			DRAM_RAS_N; 
	logic		    DRAM_DQMH;  
	logic		    DRAM_WE_N;   
sdram_top_rand_bursts sdram_top_rand_bursts(
    .Clock133(Clk),
    .Rst_N(!Rst),
    .Busy(Busy),
    // DRAM INTERFACE
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

endmodule