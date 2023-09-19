`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS ONE PORT INSTRUCTION BRAM OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module inst_ram(
     input  [$clog2(`INST_DEPTH)-1:0]  addr,
     input                             clk,
     input  [`INST_MEM_WIDTH-1:0]      din, 
     output [`INST_WIDTH-1:0]          dout,
     input                             en, 
     input                             we,
     input                             rst 
);


    reg [`INST_MEM_WIDTH-1:0] inst_ram [0:`INST_DEPTH-1];
    
         
    //initial 
    //    $readmemh("instruction_init_tb.mem", inst_ram);
    
        
    always@(posedge clk) begin
        if(en & we)
            inst_ram[addr] <= din;
    end
    
    //little endian
    assign dout = (en & !rst) ? {inst_ram[addr + 3], inst_ram[addr + 2], inst_ram[addr + 1], inst_ram[addr + 0]} : 0;
    
     
         
endmodule
