module uart_tx_shift_register_tb;
import uart_tx_pkg::*;

logic       clk;
logic       resetN;
logic [7:0] data_in; 
logic       pre_load;
logic       shift_en;
logic       dint;

//./build.py -dut uart_tx -top uart_tx_shift_register_tb -hw -sim -clean

uart_tx_shift_register uart_tx_shift_register
(
    .clk        (clk),
    .resetN     (resetN),
    .data_in    (data_in), 
    .pre_load   (pre_load),
    .shift_en   (shift_en),
    .dint       (dint)
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

initial begin: main_test
    data_in  = 8'b11000110;
    resetN   = 1'b0;
    pre_load = 1'b0; 
    shift_en = 1'b0;
    #30
    @(posedge clk);
    
    resetN   = 1'b1;
    pre_load = 1'b1;
    #10
    @(posedge clk);

    shift_en = 1'b1;
    pre_load = 1'b0;
    #40
    @(posedge clk);

    shift_en = 1'b0;
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
