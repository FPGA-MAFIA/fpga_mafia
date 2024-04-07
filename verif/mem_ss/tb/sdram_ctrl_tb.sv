module sdram_ctrl_tb;
import sdram_ctrl_pkg::*;
 
// FIXME !!!!!!!!!!!
// FIXME - Draft TB used only for checking error in compilation!!!!
// FIXME !!!!!!!!!!!!

// to run  ./build.py -dut mem_ss -top sdram_ctrl_tb -hw

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


sdram_ctrl sdram_ctrl(   
    .Clock(),  
    .Rst(),
    .Busy(), 
	//********************************
    //       SDRAM INTERFACE        
    //******************************** 
	.DRAM_ADDR(),  
	.DRAM_BA(),    
	.DRAM_CAS_N(), 
	.DRAM_CKE(),   
	.DRAM_CLK(),   
	.DRAM_CS_N(), 
	.DRAM_DQ(),    
	.DRAM_DQML(),  
	.DRAM_RAS_N(), 
	.DRAM_DQMH(),   
	.DRAM_WE_N()   
);

parameter V_TIMEOUT = 1000;
initial begin: time_out_detection
    #V_TIMEOUT
    $error("time out reached");
    $finish;
end

endmodule