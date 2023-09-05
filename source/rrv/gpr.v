`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS REGISTER FILE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module gpr(
      input                       clk,
      input                       we,
      input                       en,
      input  [$clog2(`GPRN)-1:0]  addr_rs1,
      input  [$clog2(`GPRN)-1:0]  addr_rs2,
      input  [$clog2(`GPRN)-1:0]  addr_rd,
      input  [`REG_WIDTH-1:0]     data_rd,
      output [`REG_WIDTH-1:0]     data_rs1,
      output [`REG_WIDTH-1:0]     data_rs2 
);


    reg [`REG_WIDTH-1:0] gpr_mem [0:`GPRN-1];
   
    `ifdef YES_INIT_GPR 
    initial 
        $readmemh("reg_file_init_tb.mem", gpr_mem);
    `endif
    
    always@(posedge clk) begin
        if(we & en) 
            gpr_mem[addr_rd] <= data_rd;
    end
          
    assign data_rs1 = (!addr_rs1 | !en) ? 32'h00000000: gpr_mem[addr_rs1];
    assign data_rs2 = (!addr_rs2 | !en) ? 32'h00000000: gpr_mem[addr_rs2];
            
endmodule
