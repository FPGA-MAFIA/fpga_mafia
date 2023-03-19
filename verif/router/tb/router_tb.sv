`include "macros.sv"
module router_tb;
import router_pkg::*;
logic              clk;
logic              rst;

task delay(input int cycles);
  for(int i =0; i< cycles; i++) begin
    @(posedge clk);
  end
endtask

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end


`include "fifo_arb_tb.vh"

endmodule

