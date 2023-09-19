`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS STALL UNIT OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
// for example:
// lw  t1, 0(t2)
// add t3, t1, t5
// General implementation logic : when the need for stall detected that 
// disable PC, disable IF/ID register, insert zeros to EX stage
////////////////////////////////////////////////////////////////////

//`include "defines.v"
`define INST_WIDTH     32
`define REG_ADDR_WIDTH 5
`define addr_rs1       instruction[19:15]
`define addr_rs2       instruction[24:20]
`define op_code        instruction[6:0] 
`define r_type         7'b0110011
`define i_type_arithm  7'b0010011

module stall_unit(
    input  [`INST_WIDTH-1:0]     instruction,
    input  [`REG_ADDR_WIDTH-1:0] rd_addr,
    input                        data_mem_en,
    output reg                   pc_dis,        // prevent PC reg from changing
    output reg                   rst_id_ex_reg  // insert zeros(bubble) to excution stage
);
       
    always@(*) begin
        default_assign();
            if (data_mem_en) begin
                case(`op_code)
                    `r_type: 
                        if((rd_addr == `addr_rs1) | (rd_addr == `addr_rs2)) begin
                             pc_dis        = 1'b1;
                             rst_id_ex_reg = 1'b1;  
                         end
                     `i_type_arithm:
                        if(rd_addr == `addr_rs1) begin
                             pc_dis        = 1'b1;
                             rst_id_ex_reg = 1'b1;  
                         end
                endcase
            end // end if(data_mem_wr)
    end // end always
        
    task default_assign(); begin
        pc_dis        = 1'b0;
        rst_id_ex_reg = 1'b0;
    end
    endtask
        
endmodule
