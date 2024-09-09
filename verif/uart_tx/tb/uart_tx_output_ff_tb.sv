module uart_tx_output_ff_tb;

// ./build.py -dut uart_tx -top uart_tx_output_ff_tb -hw -sim  -clean -gui &

logic clk;
logic resetN;
logic set;
logic enable;
logic data_in;
logic clear;
logic data_out;

uart_tx_output_ff uart_tx_output_ff
(
    .clk(clk),
    .resetN(resetN), 
    .set(set),
    .enable(enable),
    .data_in(data_in), 
    .clear(clear),
    .data_out(data_out) 

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
    enable = 0;
    set    = 0;
    clear  = 0;
    #20
    @(posedge clk);

    resetN = 1;
    set    = 1;
    #50
    @(posedge clk);

    set    = 0;
    clear  = 1;
    #50
    @(posedge clk);

    set     = 0;
    clear   = 0;
    enable  = 1;
    data_in = 1;
    #10
    @(posedge clk);

    data_in = 1;
    #10
    @(posedge clk);

    data_in = 1;
    #10
    @(posedge clk);

    data_in = 1;
    #10
    @(posedge clk);


    data_in = 0;
    #10
    @(posedge clk);


    data_in = 1;
    #40
    @(posedge clk);

   

    $finish();



end

parameter V_TIMEOUT = 1000;

initial begin :time_out
    #V_TIMEOUT
    $display("timeout reached");
    $finish();
end



endmodule