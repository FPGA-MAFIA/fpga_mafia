`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS WRITE BACK STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module write_back(

    //----- from memory stage -----//
    input [`FUNCT3_WIDTH-1:0]       funct3_mem_wb,    // defines what type of load instruction. 
    input                           mem_mem_wb,       // when '1' is load instruction. when '0' something else.
    input                           gpr_en_mem,       
    input                           gpr_we_mem,       // write enable to gpr. 
    input   [`REG_ADDR_WIDTH-1:0]   addr_rd_mem,      // rd address to write back into. 
    input   [`REG_WIDTH-1:0]        data_rd_mem,      // rd data to write back into when memory not used
    input   [`REG_WIDTH-1:0]        data_rd_mem_load, // rd data to write back into when loaded from memory. 
    
    //----- to decode stage -----// 
    output                          gpr_en_id,    
    output                          gpr_we_id,        // write enable to gpr. 
    output  [`REG_ADDR_WIDTH-1:0]   addr_rd_id,       // rd address to write back into. 
    output reg [`REG_WIDTH-1:0]     data_rd_id        // rd data to write back into. 
    
 );

    assign gpr_en_id   = gpr_en_mem;
    assign gpr_we_id   = gpr_we_mem;
    assign addr_rd_id  =  addr_rd_mem;
    
    
    always@(*) begin
        data_rd_id = 32'h00000000;
        case(mem_mem_wb)
            `pass: 
                data_rd_id = data_rd_mem;
            `load: begin
                if(funct3_mem_wb == 3'b000)
                    data_rd_id = {{24{data_rd_mem_load[7]}},data_rd_mem_load[7:0]};
                else if(funct3_mem_wb == 3'b001)
                    data_rd_id = {{16{data_rd_mem_load[15]}},data_rd_mem_load[15:0]};
                else if(funct3_mem_wb == 3'b010)
                    data_rd_id = data_rd_mem_load;
                else if(funct3_mem_wb == 3'b100)
                    data_rd_id = {{24{1'b0}},data_rd_mem_load[7:0]};
                else if(funct3_mem_wb == 3'b101)
                    data_rd_id = {{16{1'b0}},data_rd_mem_load[15:0]};
                else
                    data_rd_id = 32'h00000000;  
              end
            
        endcase
    
    
    end
endmodule
