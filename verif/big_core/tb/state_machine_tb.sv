module state_machine_tb;

     logic clk;
     logic rst;
     logic red;
     logic yellow;
     logic green;
     logic count_end;


always #1 clk = ~clk;  


state_machine traffic_light (
        .clk(clk),
        .rst(rst),
        .red(red),
        .yellow(yellow),
        .green(green),
        .count_end(count_end)
    );

     // Simulation control
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;


        // Reset pulse
       // #700;
        //rst = 0;

        // Let the simulation run long enough to observe full cycles
        #1000;

        $finish;
    end

endmodule