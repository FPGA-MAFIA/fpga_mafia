`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS ONE PORT INSTRUCTION BRAM OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module inst_ram(
     input      [$clog2(`INST_DEPTH)-1:0]  addra,
     input                                 clka,
     input      [`INST_WIDTH-1:0]          dina, 
     output reg [`INST_WIDTH-1:0]          douta,
     input                                 ena, 
     input                                 wea,
     input                                 rsta 
);


    reg [`INST_WIDTH-1:0] inst_ram [0:`INST_DEPTH-1];
     
    always@(posedge clka) begin
        if(rsta) 
            douta <= 0;
        else if(ena) begin
                if(wea)
                    inst_ram[addra] <= dina;
                else
                    douta <= inst_ram[addra];
        end   
    end
       
endmodule
