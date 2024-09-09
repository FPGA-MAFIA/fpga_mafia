module uart_tx_ctrl_tb;
import uart_tx_pkg::*;

// ./build.py -dut uart_tx -top uart_tx_ctrl_tb -hw -sim  -clean -gui &

logic              clk;
logic              resetN;
logic              write_din;
t_uart_tx_ctrl_in  uart_tx_ctrl_in;
t_uart_tx_ctrl_out uart_tx_ctrl_out;

uart_tx_ctrl uart_tx_ctrl
(
    .clk(clk),
    .resetN(resetN),
    .write_din(write_din),
    .uart_tx_ctrl_in(uart_tx_ctrl_in),
    .uart_tx_ctrl_out(uart_tx_ctrl_out)
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

initial begin
    resetN          = 0;
    write_din       = 0;
    uart_tx_ctrl_in = 0;
    #20
    @(posedge clk);

    resetN     = 1;
    write_din  = 0;
    #40
    @(posedge clk);  //must be in IDLE

    write_din  = 1;
    #80
    @(posedge clk); // goes to SEND_START and stays there

    uart_tx_ctrl_in.t1  = 1;
    #100
    @(posedge clk); // moves roundly CLEAR_TIMER -> SEND_DATA -> TEST_EOC -> SHIFT_COUNT

    uart_tx_ctrl_in.eoc_dcount = 1;
    write_din                  = 0;
    #100
    @(posedge clk); // will eventually goes to SEND_STOP -> IDLE
    
    $finish();

end


parameter V_TIMEOUT = 1000;

initial begin :time_out
    #V_TIMEOUT
    $display("timeout reached");
    $finish();
end


endmodule