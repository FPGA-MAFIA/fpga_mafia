`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS FORWARDING UNIT OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module forwarding_unit(
     input [`REG_ADDR_WIDTH-1:0] rs1_addr,      // rs1 address from execution stage
     input [`REG_ADDR_WIDTH-1:0] rs2_addr,      // rs2 address from execution stage
     input [`REG_ADDR_WIDTH-1:0] rd_addr_mem,   // rd address from memory stage
     input [`REG_ADDR_WIDTH-1:0] rd_addr_wb,    // rd address from wb stage
     input [`REG_WIDTH-1:0]      rd_data_mem,   // rd data from mem stage 
     input [`REG_WIDTH-1:0]      rd_data_wb,    // rd data from wb stage
     input                       we_mem,        // gpr enable in memory stage
     input                       we_wb,         // gpr enable in write back stage
     input                       data_mem_we,   // when '1' forwarding may occure in store (add r1, r2, r3 , sw r1, x(r1))). from exectuion stage
     
     //----- to execution stage -----//
     output reg                  mux_alu1,
     output reg                  mux_alu2,
     output reg                  mux_store,
     output reg [`REG_WIDTH-1:0] rd,
     output reg [`REG_WIDTH-1:0] rd_store_fw
         
);
  
  always@(*) begin
    mux_alu1    = 1'b0;
    mux_alu2    = 1'b0;
    mux_store   = 1'b0;
    rd          = 32'h00000000;
    rd_store_fw = 32'h00000000;
    if((rs1_addr == rd_addr_mem) & (we_mem | data_mem_we)) begin   // when data_mem_we = '1', forward occures when rd is the adress of store instruction (sw, x, x(rd))
        mux_alu1  = 1'b1;
        mux_alu2  = 1'b0;
        mux_store = 1'b0;
        rd       = rd_data_mem;
        if(we_mem & data_mem_we) begin //forward occures when rd is the content of store instruction (sw, rd, x(x))
            if(rs2_addr == rd_addr_mem) begin
                mux_store   = 1'b1;
                rd_store_fw = rd_data_mem; 
            end
        end
    end
    else if((rs2_addr == rd_addr_mem) & we_mem) begin 
            mux_alu1  = 1'b0;
            mux_alu2  = 1'b1;
            mux_store = 1'b0;
            rd        = rd_data_mem;
    end
    else if((rs1_addr == rd_addr_wb) & we_wb) begin
        mux_alu1  = 1'b1;
        mux_alu2  = 1'b0;
        mux_store = 1'b0;
        rd       = rd_data_wb;
    end
    else if((rs2_addr == rd_addr_wb) & we_wb)begin
        mux_alu1  = 1'b0;
        mux_alu2  = 1'b1;
        mux_store = 1'b0;
        rd       = rd_data_wb;
    end
          
    end      
           
endmodule
