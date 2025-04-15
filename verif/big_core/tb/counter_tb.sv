module counter_tb;

 logic clk;
logic rst;
   //  input  logic count_enable,
 logic [3:0] count;
 logic count_end;

 always #1 clk = ~clk;  


counter timer (

.clk(clk),
.rst(rst),
.count(count),
.count_end(count_end)

);


initial begin
        // Initialize signals
        clk = 0;
        rst = 1;


        // Reset pulse
       // #700;
        //rst = 0;

        // Let the simulation run long enough to observe full cycles
        #500;

        $finish;
    end


endmodule