module rrv_tb ;

logic        Clk;
logic        Rst;
logic [31:0] Instruction;
logic [31:0] DMemAddress;
logic [31:0] DMemData   ;
logic [3:0]  DMemByteEn ;
logic        DMemWrEn   ;
logic        DMemRdEn   ;
logic [31:0] DMemRspData;
localparam   TOP_IMEM_SIZE = 65536;
localparam   TOP_DMEM_SIZE = TOP_IMEM_SIZE + 65536;

logic  [7:0] IMem     [TOP_IMEM_SIZE - 1 : 0];
logic  [7:0] NextIMem [TOP_IMEM_SIZE - 1 : 0];

logic  [7:0] DMem     [TOP_DMEM_SIZE - 1 : TOP_IMEM_SIZE];
logic  [7:0] NextDMem [TOP_DMEM_SIZE - 1 : TOP_IMEM_SIZE];

//=========================================
// Instantiating the rrv - DUT
//=========================================
top top (
 .clk (Clk) ,// input  clk,
 .rst (Rst)  // input  rst
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


always_ff @(posedge Clk ) begin
    IMem <= NextIMem;
    DMem <= NextDMem;
end

string test_name;
integer file;
initial begin: test_seq
    if ($value$plusargs ("STRING=%s", test_name))
        $display("STRING value %s", test_name);
    //======================================
    //load the program to the TB
    //======================================
    // Check that inst_mem.sv exists
    file = $fopen({"../../../target/rrv/tests/",test_name,"/gcc_files/inst_mem.sv"}, "r");
    if (!file) begin
        $display("File was not open successfully : %0d", file);
        $error("File ../../../target/rrv/tests/%s/gcc_files/inst_mem.sv does not exist", test_name);
        $finish;
    end
    $readmemh({"../../../target/rrv/tests/",test_name,"/gcc_files/inst_mem.sv"} , IMem);
    $readmemh({"../../../target/rrv/tests/",test_name,"/gcc_files/inst_mem.sv"} , NextIMem);
    force top.fetch_module.inst_ram_module.inst_ram = IMem;

    file = $fopen({"../../../target/rrv/tests/",test_name,"/gcc_files/data_mem.sv"}, "r");
    if (file) begin
        $fclose(file);
        $readmemh({"../../../target/rrv/tests/",test_name,"/gcc_files/data_mem.sv"} , DMem);
        $readmemh({"../../../target/rrv/tests/",test_name,"/gcc_files/data_mem.sv"} , NextDMem);
        force top.mem_stage_module.data_ram.data_ram = DMem;
        #10
        release top.mem_stage_module.data_ram.data_ram;
    end

    #10000
    $error(" Timeout \n===================\n test %s ended timeout \n=====================", test_name);
    $finish;

end // test_seq

endmodule //big_core_tb

