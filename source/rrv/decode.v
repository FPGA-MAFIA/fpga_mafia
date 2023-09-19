`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS DECODE STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////

`include "defines.v"

module decode(
    input                               clk,
    input                               rst,
    input                               flash_id_ex,   // transfers zeros to next stage
    input                               flash_id_ex_s, // from stall unit
    
    //----- from fetch stage -----//
    input  [`INST_WIDTH-1:0]            instruction,
    input  [`PC_WIDTH-1:0]              pc_from_if,
    
   //----- to execution stage -----//
    output reg [`REG_WIDTH-1:0]         alu_in1,       // alu1 input  
    output reg [`REG_WIDTH-1:0]         alu_in2,       // alu2 input 
    output reg [`FUNC_SIZE-1:0]         funct3_alu,    // op code passed to alu
    output reg [`PC_WIDTH-1:0]          pc2ex,         // pass pc to execution stage
    output reg [`OP_CODE_WIDTH-1:0]     op_code2ex,    // instruction[6:0]
    output reg [`FUNCT3_WIDTH-1:0]      funct3,        // instruction[14:12]
    output reg [`IMM_ID-1:0]            immidiate_ex,  // used for adding value to pc or other immidiate value
       
    //----- to data memory stage -----//
    output reg                  data_mem_en_idex,   // enables memory read in load-store instructions
    output reg                  data_mem_we_idex,   // write enable in store instructions
    output reg [`REG_WIDTH-1:0] rs2_idex,           // used in store instructions in mem stage
    
    //----- to write back stage -----//
    output reg                         gpr_en_idex,    
    output reg                         gpr_we_idex,     // write enable when write to gpr
    output reg [`REG_ADDR_WIDTH-1:0]   addr_rd_idex,    // rd address to write back into
    
    //----- from write back stage -----//
    input                               gpr_en_wb,     
    input                               gpr_we_wb,
    input [`REG_WIDTH-1:0]              rd_in_wb,       // value of rd from rightback. calculated at execution stage or load instruction in mem stage
    input [`REG_ADDR_WIDTH-1:0]         addr_rd_wb,     // rd address to write back into

    //----- rs1, rs2 to execution unit -----//
    output reg [`REG_ADDR_WIDTH-1:0]    addr_rs1_ex,   // inputs for forwarding unit
    output reg [`REG_ADDR_WIDTH-1:0]    addr_rs2_ex       
    
);
        
    wire [`REG_WIDTH-1:0] rs1;     // data of rs1 and rs2 
    wire [`REG_WIDTH-1:0] rs2;
    reg  [`REG_WIDTH-1:0] rs1_fw;  // data of rs1 when forward 
    reg  [`REG_WIDTH-1:0] rs2_fw;  // data of rs2 when forward

    gpr gpr_module(
      .clk(clk),
      .we(gpr_we_wb),
      //.en(gpr_en_wb),
      .en(1'b1),
      .addr_rs1(`addr_rs1),
      .addr_rs2(`addr_rs2),
      .addr_rd(addr_rd_wb),
      .data_rd(rd_in_wb),
      .data_rs1(rs1),
      .data_rs2(rs2)
    );
    
    // forwarding from WB to decode
    // for example: we need we need rx at decode but it available in WB
    always@(*) begin
        rs1_fw = rs1;
        rs2_fw = rs2;
        if(`addr_rs1 == addr_rd_wb)
            rs1_fw = rd_in_wb;
        if(`addr_rs2 == addr_rd_wb)
            rs2_fw = rd_in_wb;
    end
    
    wire [`IMM_ID-1:0] immidiate;
    
    imm_generator imm_generator_module(
        .instruction(instruction),
        .immidiate(immidiate)
    );
    
    // passing register info to next stage
    always@(posedge clk) begin
        if(rst)
            pc2ex <= 32'h00000000;
        else
            pc2ex <= pc_from_if;
    end
   
   reg [`FUNC_SIZE-1:0]      funct3_alu_ns;
   reg [`REG_WIDTH-1:0]      alu_in1_ns;
   reg [`REG_WIDTH-1:0]      alu_in2_ns;
   reg                       data_mem_en_idex_ns;
   reg                       data_mem_we_idex_ns;
   reg                       gpr_we_idex_ns;
   reg                       gpr_en_idex_ns;
   reg [`REG_ADDR_WIDTH-1:0] addr_rd_idex_ns;
   reg [`REG_ADDR_WIDTH-1:0] addr_rs2_ex_ns;  // in case of forwarding for example add r1, r2, r3 and than addi r4, r5, 1
      
   always@(posedge clk) begin
        if(rst | flash_id_ex | flash_id_ex_s) begin
            funct3_alu       <= 32'h00000000;
            alu_in1          <= 32'h00000000;
            alu_in2          <= 32'h00000000; 
            data_mem_en_idex <= 1'b0;
            data_mem_we_idex <= 1'b0;
            gpr_en_idex      <= 1'b0; 
            gpr_we_idex      <= 1'b0;
            addr_rd_idex     <= 5'b00000;
            op_code2ex       <= 7'b0000000;
            funct3           <= 3'b000;
            rs2_idex         <= 32'h00000000;
            immidiate_ex     <= 32'h00000000; 
            addr_rs1_ex      <= 32'b00000;
            addr_rs2_ex      <= 32'b00000;
        end
        else begin
            funct3_alu       <= funct3_alu_ns;
            alu_in1          <= alu_in1_ns;
            alu_in2          <= alu_in2_ns;
            data_mem_en_idex <= data_mem_en_idex_ns;
            data_mem_we_idex <= data_mem_we_idex_ns;
            gpr_en_idex      <= gpr_en_idex_ns;
            gpr_we_idex      <= gpr_we_idex_ns; 
            addr_rd_idex     <= addr_rd_idex_ns;
            op_code2ex       <= instruction[6:0];
            funct3           <= instruction[14:12];
            rs2_idex         <= rs2_fw;
            immidiate_ex     <= immidiate;
            addr_rs1_ex      <= `addr_rs1;
            addr_rs2_ex      <=  addr_rs2_ex_ns; 
        end
   end
      
    //----- DECODER -----//
    always@(*) begin
        set_default();
        case(`op_code)
            `r_type: begin
                //to execution stage
                funct3_alu_ns       = {`bit, `funct3};
                alu_in1_ns          = rs1_fw;
                alu_in2_ns          = rs2_fw;
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;            
            end
            `i_type_arithm: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                // to forwarding unit
                addr_rs2_ex_ns      = 5'b00000; 
                //to execution stage
                alu_in1_ns    = rs1_fw; 
                if(`funct3 == 3'b001 | `funct3 == 3'b101) begin
                    funct3_alu_ns = {`bit, `funct3};
                    alu_in2_ns    = {{27{1'b0}},`shamt};
                end
                else begin
                   funct3_alu_ns = {1'b0, `funct3};
                   alu_in2_ns    = immidiate;
                end
            end
            `s_type: begin
                 //to execution stage
                 funct3_alu_ns      = `add;
                 alu_in1_ns         = rs1_fw;
                 alu_in2_ns         = immidiate;
                //to memory stage
                data_mem_en_idex_ns = 1'b1;
                data_mem_we_idex_ns = 1'b1;
                //to write back stage
                gpr_en_idex_ns      = 1'b0;
                gpr_we_idex_ns      = 1'b0;
                addr_rd_idex_ns     = `addr_rd; 
            end     
            `i_type_dmem: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b1;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns  = `add;
                alu_in1_ns    = rs1;
                alu_in2_ns    = immidiate;
            end   
           `b_type: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b0;
                gpr_we_idex_ns      = 1'b0;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = rs1_fw;
                alu_in2_ns    = rs2_fw; 
           end
           `i_type_jalr: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = rs1_fw;
                alu_in2_ns    = immidiate; 
           end
           `j_type: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = pc_from_if;
                alu_in2_ns    = immidiate;         
            end
            `u_type_auipc: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = pc_from_if;
                alu_in2_ns    = immidiate;
            end
            `u_type_lui: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = immidiate;
                alu_in2_ns    = 32'h00000000;
            end
            
        endcase  
    end

    task set_default(); begin
        funct3_alu_ns       = `add;
        alu_in1_ns          = 32'h00000000;
        alu_in2_ns          = 32'h00000000;
        data_mem_en_idex_ns = 1'b0;
        data_mem_we_idex_ns = 1'b0;
        gpr_en_idex_ns      = 1'b0;
        gpr_we_idex_ns      = 1'b0;
        addr_rd_idex_ns     = 5'b00000;
        addr_rs2_ex_ns      = `addr_rs2;              
        end
    endtask
   
endmodule
