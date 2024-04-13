module sdram_top_tb;
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
    #2000

    $finish;
end

parameter V_TIMEOUT = 10000; 
initial begin: time_out_detection
    #V_TIMEOUT
    $error("time out reached");
    $finish;
end

sdram_top sdram_top(
  .Clock(Clk),
  .Rst(!Rst),
  .Busy(Busy)
);

endmodule