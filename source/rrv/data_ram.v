`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS ONE PORT INSTRUCTION DATA BRAM OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module data_ram(
     input      [$clog2(`DATA_DEPTH)-1:0]  addr,
     input                                 clk,
     input      [`DATA_WIDTH-1:0]          din, 
     output reg [`DATA_WIDTH-1:0]          dout,
     input                                 en, 
     input                                 we,
     input                                 rst 
);


    reg [`DATA_WIDTH-1:0] data_ram [0:`DATA_DEPTH-1];
    
    `ifdef YES_INIT_DATA_RAM
        initial 
            $readmemh("data_init_tb.mem", data_ram); 
    `endif
    
    always@(posedge clk) begin
        if(rst) 
            dout <= 0;
        else if(en) begin
                if(we)
                    data_ram[addr] <= din;
                else
                    dout <= data_ram[addr];
        end   
    end
       
endmodule
