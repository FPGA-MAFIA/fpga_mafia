
module uart_tx_top_tb;
import uart_tx_pkg::*;

 // ./build.py -dut uart_tx -top uart_tx_top_tb -hw -sim  -clean
parameter MAX_TIMER_VALUE_FOR_DEBUG = 10;

logic       clk;
logic       resetN;
logic [7:0] din; 
logic       write_din;
logic       tx;
logic       tx_ready;

uart_tx_top
#(.MAX_TIMER_VALUE(MAX_TIMER_VALUE_FOR_DEBUG))
uart_tx_top
(
    .clk(clk),
    .resetN(resetN),
    .din(din), 
    .write_din(write_din),
    .tx(tx),
    .tx_ready(tx_ready)
);


// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen  

initial begin: main_tb
    din       = 8'b00111001;
    write_din = 0;
    resetN    = 0;
    #20;
    @(posedge clk);

    resetN    = 1;  // send '1' cause in idle state 
    #100;
    @(posedge clk);

    write_din = 1;
    #20;
    @(posedge clk);

    write_din = 0;
    #1500;
    @(posedge clk);

    din  = 8'b01101011;
    write_din = 1;
    $display("time %t", $time);  // for debug purpose
    #20;
    @(posedge clk);

    write_din = 0;
    #1500;
    @(posedge clk);


    $finish();

end
parameter V_TIMEOUT = 10000;

initial begin :time_out
    #V_TIMEOUT
    $display("timeout reached");
end

endmodule