
module sc_rrv_tb;

logic        Clk;
logic        Rst;
logic        SimulationDone;


localparam TOP_IMEM_SIZE = 65536;
localparam TOP_DMEM_SIZE = 65536;
localparam D_MEM_SIZE    = 65536;
localparam D_MEM_OFFSET  = 65536;

logic  [7:0] IMem     [TOP_IMEM_SIZE-1 : 0];
logic  [7:0] NextIMem [TOP_IMEM_SIZE-1 : 0];
logic  [7:0] DMem     [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];
logic  [7:0] NextDMem [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];


localparam SET_TIME = 1000;
localparam DELAY    = 10;
string  test_name;

integer trk_rf_pointer;

`include "sc_rrv_tasks.vh"


//=========================================
// Instantiating the rrv_top_core - DUT
//=========================================
    sc_top sc_top(
        .Clk(Clk),
        .Rst(Rst), 
        .SimulationDone(SimulationDone)
);

// ========================
// clock gen
// ========================
initial begin: clock_gen
    forever begin
        #5 Clk = 1'b0;
        #5 Clk = 1'b1;
    end //forever
end//initial clock_gen

// ========================
// reset generation
// ========================
initial begin: reset_gen
    Rst = 1'b1;
#40 Rst = 1'b0;
end: reset_gen

initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);

    //======================================
    //load the program to the TB
    //======================================
    $readmemh({"../../../target/sc_rrv/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    force sc_top.I_Mem.I_mem = IMem;
    
    trk_rf_pointer = $fopen({"../../../target/sc_rrv/tests/",test_name,"/gcc_files/trk_rf.txt"} , "w");
    
    #40;

    while(1) begin
        if(SimulationDone) begin
            $fclose(trk_rf_pointer);
            $display("Simulation Done");
            $finish();
        end
        else begin 
            trk_rf();
            #DELAY;
        end
    end
        
    #SET_TIME;
    $finish();

end // load instruction memory

endmodule //rrv_tb_core