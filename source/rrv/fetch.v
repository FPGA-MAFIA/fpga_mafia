`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS FETCH STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////

`include "defines.v"

module fetch(
    input                       clk,
    input                       rst,
    input                       jump_en,   // load enable incase of branches 
    input  [`PC_WIDTH-1:0]      load_pc,   // pc from execution stage in case of branch
    input                       pc_en, 
    input                       inst_mem_en,
    input                       inst_mem_we,
    input                       inst_mem_rst,  //IF = 0
    output [`INST_WIDTH-1:0]    inst_fetch_out,
    output reg [`PC_WIDTH-1:0]  pc2id
);

    reg [`PC_WIDTH-1:0] PC, N_PC;
    
    always@(posedge clk) begin
        if(rst) 
            PC <= 32'h00000000;
        else 
            PC <= N_PC;
    end    

    
    always@(*) begin
        if(pc_en) begin
           if(jump_en) begin
                N_PC  = load_pc;
                pc2id = PC;
           end
           else begin
                N_PC = PC + 1;
                pc2id = PC;
           end
        end
        else begin
            N_PC = PC;
            pc2id = PC;
        end     
    end
      
    inst_ram inst_ram_module(
     .addra(PC), 
     .clka(clk),
     .dina(), 
     .douta(inst_fetch_out),
     .ena(inst_mem_en), 
     .wea(inst_mem_we),
     .rsta(inst_mem_rst)
);
  
endmodule
