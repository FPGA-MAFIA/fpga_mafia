module debouncer_tb;

logic clk;
logic resetN;
logic trigger_in;
logic trigger_out;

// ./build.py -dut uart_tx -top debouncer_tb -hw -sim  -clean -gui &

// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 clk = 1'b0;
        #5 clk = 1'b1;
    end // forever
end // initial clock_gen   

debouncer
#(.CLK_DIVIDER(4)) 
debouncer
(
    .clk(clk),
    .resetN(resetN),
    .trigger_in(trigger_in),
    .trigger_out(trigger_out)
);

initial begin: main_tb
    resetN = 0;
    #50
    @(posedge clk);

    resetN = 1;
    trigger_in = 0;
    #500
    @(posedge clk);

    trigger_in = 1;
    #50
    @(posedge clk);

    $finish();


end



parameter V_TIMEOUT = 10000;

initial begin :time_out
    #V_TIMEOUT
    $display("timeout reached");
    $finish();
end


endmodule