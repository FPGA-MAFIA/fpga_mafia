include "macros.vh"
import rv32i_ref_pkg::*;
module fabric_rv32i_ref_flat_mem
(
    input logic clk,
    input logic rst,
    input logic run,
    input logic core2mem_req,
    input logic [31:0] core2mem_req.Data,
    input logic core2mem_req.WrEn,
    input logic core2mem_req.RdEn,
    input logic [31:0] core2mem_req.Address,
    input logic [3:0] core2mem_req.ByteEn,   
    input logic [2:0] core2mem_req.TileId
);

    // Memory declarations
    logic [7:0] IMem [I_MEM_SIZE + I_MEM_OFFSET - 1 : I_MEM_OFFSET];
    logic [7:0] DMem [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];
    logic [7:0] NextDMem [D_MEM_SIZE + D_MEM_OFFSET - 1 : D_MEM_OFFSET];

    // Clock generation
    initial begin
        forever begin
            #5 clk = 1'b0; // Half period for clock where #5 is the delay #5 time units #5 means 5 time units
            #5 clk = 1'b1;
        end
    end

    // Reset generation
    initial begin
        rst = 1'b1;
        #40 rst = 1'b0; // Release reset after 40 time units
    end

    `MAFIA_DFF(IMem, IMem, clk) // Memory for instructions
    // `MAFIA_DFF(DMem, DMem, clk) // Original line
    `MAFIA_DFF(DMem, NextDMem, clk) // Memory for data, using NextDMem to allow for backdoor updates
    // Test sequence will be executed by the testbench
    initial begin   
        if ($value$plusargs("STRING=%s", test_name))
            $display("STRING value %s", test_name);
        
        // Load initial memory contents or perform other setup tasks
        // This is a placeholder for the actual memory initialization
        // You can load instructions into IMem and data into DMem as needed
        // For example:
        // IMem[0] = 8'h00; // Load first instruction
        // DMem[0] = 8'hFF; // Load initial data

        // Wait for run signal to start processing
        wait(run);
        
        // Main processing loop
        while (run) begin
            @(posedge clk);
            if (rst) begin
                // Handle reset logic if needed
            end else begin
                // Process core2mem_req signals here
                if (core2mem_req.WrEn) begin
                    DMem[core2mem_req.Address] <= core2mem_req.Data;
                end else if (core2mem_req.RdEn) begin
                    core2mem_req.Data <= DMem[core2mem_req.Address];
                end
            end
        end
    end

    // Additional logic for handling core2mem_req can be added here
    // For example, you can implement read/write operations based on core2mem_req signals
    // This is a placeholder for the actual memory operations
    // if (core2mem_req.WrEn) begin
        //     DMem[core2mem_req.Address] <= core2mem_req.Data;
        // end else if (core2mem_req.RdEn) begin
        //     core2mem_req.Data <= DMem[core2mem_req.Address];
        // end
    // end // initial test_seq
    // End of test sequence
    // You can add more functionality here, such as loading initial memory contents or handling specific commands           
//now we can instantiate the fabric_rv32i_ref module with the flat memory


endmodule
// 
// 
// //we need 2KB for each mem of fabric is measured in bytes and 2KB = 2048 bytes 2048 = 2^11, so we need 11 bits to address the memory