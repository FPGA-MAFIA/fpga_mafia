module uart_tx_timer_tb;

// ./build.py -dut uart_tx -top uart_tx_timer_tb -hw -sim  -clean -gui &

logic clk;
logic te;
logic resetN;
logic t1;

uart_tx_timer #(.MAX_VALUE(10))
uart_tx_timer
(
    .clk(clk),
    .te(te),  // when te=0 timer clears. when te=1 timer counts
    .resetN(resetN), 
    .t1(t1)

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

initial begin : main_test
    resetN = 0;
    #20
    @(posedge clk);

    resetN = 1;
    te    =  0;
    #50
    @(posedge clk);

    te     = 1;
    #200
    @(posedge clk)

    $finish();



end

parameter V_TIMEOUT = 1000;

initial begin :time_out
    #V_TIMEOUT
    $display("timeout reached");
    $finish();
end

endmodule

