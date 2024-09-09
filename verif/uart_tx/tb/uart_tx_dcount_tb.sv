module uart_tx_dcount_tb;

logic clk;
logic resetN;
logic en_cnt;
logic clr;
logic eoc_dcount;


// ./build.py -dut uart_tx -top uart_tx_dcount_tb -hw -sim  -clean -gui &

uart_tx_dcount uart_tx_dcount 
(
    .clk(clk),
    .resetN(resetN),
    .en_cnt(en_cnt),
    .clr(clr),
    .eoc_dcount(eoc_dcount)
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
    clr    = 1;
    #20
    @(posedge clk);

    clr     = 0;
    en_cnt  = 1;
    #100
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