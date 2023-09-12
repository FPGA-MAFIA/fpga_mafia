`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS MEMORY STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem_stage(
    input                           clk, 
    input                           rst,
    
    //----- from execution stage -----//
    input                              data_mem_en,    // enables memory in load-store instructions
    input                              data_mem_we,    // write enable in store instructions
    input [`REG_WIDTH-1:0]             rs2_mem,        // used in store instructions
    input [$clog2(`DATA_DEPTH)-1:0]    addr_mem,       // adder to store rs2 or load to rd
    input [`FUNCT3_WIDTH-1:0]          funct3_mem,     // defines what type of load instruction
    input                              mem_wb,         // when '1' is load instruction. when '0' something else
    
    //----- to write back stage -----//
    input                              gpr_en_ex,       
    input                              gpr_we_ex,        // write enable to gpr. pass as is to next stage
    input [`REG_ADDR_WIDTH-1:0]        addr_rd_ex,       // rd address to write back into. pass as is to next stage
    input [`REG_WIDTH-1:0]             data_rd_ex,       // rd data to write back into. 
    output reg                         gpr_en_wb,    
    output reg                         gpr_we_wb,        // write enable to gpr. pass as is to next stage
    output reg [`REG_ADDR_WIDTH-1:0]   addr_rd_wb,       // rd address to write back into. pass as is to next stage
    output [`REG_WIDTH-1:0]            data_rd_wb,       // rd data to write back into when no memory is used.
    output [`REG_WIDTH-1:0]            data_rd_wb_mem,   // rd data to write back into when loaded from memory. 
    output reg [`FUNCT3_WIDTH-1:0]     funct3_mem_wb,    // defines what type of load instruction. pass as is to next stage
    output reg                         mem_mem_wb        // when '1' is load instruction. when '0' something else. pass as is to next stage
    
 );
  
      wire [`REG_WIDTH-1:0] mem_out;
      reg  [`REG_WIDTH-1:0] data_rd_ex_ns; // use this reg to create flip flop while passig rd to next state. caused of memory read latency = 1
     
      data_ram data_ram(
     .addr(addr_mem),
     .clk(clk),
     .din(rs2_mem), 
     .dout(mem_out),
     .en(data_mem_en), 
     .we(data_mem_we),
     .rst(rst)  
);

     always@(posedge clk) begin
        if(rst) begin
            gpr_en_wb     <= 1'b0;
            gpr_we_wb     <= 1'b0;
            addr_rd_wb    <= 0;
            funct3_mem_wb <= 3'b000;
            mem_mem_wb    <= 1'b0;
        end
        else begin
            gpr_en_wb     <= gpr_en_ex;
            gpr_we_wb     <= gpr_we_ex;
            addr_rd_wb    <= addr_rd_ex;
            funct3_mem_wb <= funct3_mem;
            mem_mem_wb    <= mem_wb;
        end
    end

    // creating flip flop caused by the need to synchronize read memory 1 latency. 
     always @(posedge clk) begin
        if(rst)
            data_rd_ex_ns <= 32'h00000000;
        else
            data_rd_ex_ns <= data_rd_ex;
     end
     
     assign data_rd_wb     = data_rd_ex_ns;
     assign data_rd_wb_mem = mem_out;
     
                  
endmodule
