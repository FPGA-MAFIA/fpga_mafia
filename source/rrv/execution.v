`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS EXECUTION STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////

`include "defines.v"

module execution(
    input clk,
    input rst,
    
    //----- from decode stage -----//
    input [`REG_WIDTH-1:0]         alu_in1,    // alu1 input  
    input [`REG_WIDTH-1:0]         alu_in2,    // alu2 input 
    input [`FUNC_SIZE-1:0]         funct3_alu, // op code passed to alu
    input [`PC_WIDTH-1:0]          pc   ,      // pass from decode stage
    input [`OP_CODE_WIDTH-1:0]     op_code,    // instruction[6:0]
    input [`FUNCT3_WIDTH-1:0]      funct3,     // instruction[14:12]
   
    //----- to data memory stage -----//
    input                                data_mem_en_idex,   // enables memory read in load-store instructions. pass as is to next stage
    input                                data_mem_we_idex,   // write enable in store instructions. pass as is to next stage
    input [`REG_WIDTH-1:0]               rs2_idex,           // used in store instructions in mem stage. pass as is to next stage
    input [`IMM_ID-1:0]                  immidiate,          // used in branch instructions to be added to pc 
    output reg                           data_mem_en_mem,    // enables memory in load-store instructions. passed as is to next stage
    output reg                           data_mem_we_mem,    // write enable in store instructions. passed as is to next stage
    output reg [`REG_WIDTH-1:0]          rs2_mem,            // used in store instructions. passed as is to next stage
    output reg [$clog2(`DATA_DEPTH)-1:0] addr_mem,           // adder to store rs2 or load to rd
    output reg [`FUNCT3_WIDTH-1:0]       funct3_mem,         // defines what type of load instruction
    output reg                           mem_wb,             // when '1' is load instruction. when '0' something else
    
    //----- to write back stage -----//
    input                              gpr_en_idex,       
    input                              gpr_we_idex,      // write enable to gpr. pass as is to next stage
    input [`REG_ADDR_WIDTH-1:0]        addr_rd_idex,     // rd address to write back into. pass as is to next stage
    output reg                         gpr_en_wb,    
    output reg                         gpr_we_wb,        // write enable to gpr. pass as is to next stage
    output reg [`REG_ADDR_WIDTH-1:0]   addr_rd_wb,       // rd address to write back into. pass as is to next stage
    output reg [`REG_WIDTH-1:0]        data_rd_wb,       // rd data to write back into. 
    
    //----- to fetch stage -----//
    output reg [`PC_WIDTH-1:0]         pc_fetch,
    output reg                         jump_en,           // when '1' then update pc with pc_fetch value

    //----- rs1, rs2 to forwardng unit -----//
    input  [`REG_ADDR_WIDTH-1:0]   addr_rs1_ex,           // inputs for forwarding unit
    input  [`REG_ADDR_WIDTH-1:0]   addr_rs2_ex,    
    output [`REG_ADDR_WIDTH-1:0]   addr_rs1_fw,           
    output [`REG_ADDR_WIDTH-1:0]   addr_rs2_fw,
    
    //----- from forwarding unit -----//
     input                  mux_alu1,
     input                  mux_alu2,
     input                  mux_store,    // forwarding when sw, rd, x(x)
     input [`REG_WIDTH-1:0] rd,
     input [`REG_WIDTH-1:0] rd_store_fw   // forwarding when sw, rd, x(x)
     
     
);
    
    
    assign addr_rs1_fw = (!rst) ? addr_rs1_ex : 5'b00000;
    assign addr_rs2_fw = (!rst) ? addr_rs2_ex : 5'b00000;
         
    wire [`REG_WIDTH-1:0] result; 
    wire [`FLAGN-1 :0]    flag;
    
    reg [`REG_WIDTH-1:0]  alu_in1_mux;  
    reg [`REG_WIDTH-1:0]  alu_in2_mux; 
    
    reg [`REG_WIDTH-1:0]  store_rd_mem;  
    
    alu alu_module (
        .func_code(funct3_alu),
        .in1(alu_in1_mux),
        .in2(alu_in2_mux),
        .result(result),
        .flag(flag)      
    );
    
    
    // first forwarding mux
    always @(*) begin
        case(mux_alu1)
            1'b0:
                alu_in1_mux = alu_in1;
            1'b1: 
                alu_in1_mux = rd;      
        endcase
    end
    
    // second forwarding mux
   always @(*) begin
        case(mux_alu2)
            1'b0:
                alu_in2_mux = alu_in2;
            1'b1: 
                alu_in2_mux = rd;      
        endcase
    end
    
    // mux for store forwarding
    always@(*) begin
        case(mux_store)
            1'b0: 
               store_rd_mem =  rs2_idex;  
            1'b1:
               store_rd_mem =  rd_store_fw; 
            default:
               store_rd_mem = 32'h00000000;   
        endcase
    end  
    
    
    
    reg [`REG_WIDTH-1:0]          data_rd_wb_ns;
    //reg [`PC_WIDTH-1:0]           pc_fetch_ns;
    reg [$clog2(`DATA_DEPTH)-1:0] addr_mem_ns;
    reg [`REG_WIDTH-1:0]          rs2_mem_ns;       // used in store instructions in mem stage. pass as is to next stage
    reg [`FUNCT3_WIDTH-1:0]       funct3_mem_ns;    // defines what type of load instruction
    reg                           mem_wb_ns;        // when '1' is load instruction. when '0' something else
        
    always@(posedge clk) begin
        if(rst) begin
           data_mem_en_mem <= 1'b0;
           data_mem_we_mem <= 1'b0;
           rs2_mem         <= 32'h00000000;
           gpr_en_wb       <= 1'b0;
           gpr_we_wb       <= 1'b0;        
           addr_rd_wb      <= 0;
           data_rd_wb      <= 32'h00000000;
           addr_mem        <= 0;
           funct3_mem      <= 3'b000;
           mem_wb          <= 1'b0;
        end
        else begin
           data_mem_en_mem <= data_mem_en_idex;
           data_mem_we_mem <= data_mem_we_idex;
           rs2_mem         <= rs2_mem_ns;
           gpr_en_wb       <= gpr_en_idex;
           gpr_we_wb       <= gpr_we_idex;        
           addr_rd_wb      <= addr_rd_idex;
           data_rd_wb      <= data_rd_wb_ns;
           addr_mem        <= addr_mem_ns;
           funct3_mem      <= funct3_mem_ns;
           mem_wb          <= mem_wb_ns; 
        end
    end

    always@(*) begin
        set_default();
        case(op_code)
            `r_type: 
                data_rd_wb_ns = result;           
            `i_type_arithm:
                data_rd_wb_ns = result;  
            `s_type: begin
                addr_mem_ns   = result;
                if(funct3 == 3'b000)
                    rs2_mem_ns = store_rd_mem[7:0];
                else if(funct3 == 3'b001)
                    rs2_mem_ns = store_rd_mem[15:0];
                else
                    rs2_mem_ns = store_rd_mem; 
            end                     
           `i_type_dmem: begin
                addr_mem_ns   = result;
                funct3_mem_ns = funct3;    
                mem_wb_ns     = 1'b1;
            end
           `b_type: begin
                if(funct3 == 3'b000) begin
                    if(flag[2]) begin
                        pc_fetch = pc + immidiate;
                        jump_en  = 1'b1;
                    end
                end
                else if(funct3 == 3'b001) begin
                    if(!flag[2]) begin
                        pc_fetch = pc + immidiate;
                        jump_en  = 1'b1;
                    end
                end
                else if(funct3 == 3'b100) begin 
                    if(flag[0]) begin
                        pc_fetch = pc + immidiate;
                        jump_en  = 1'b1;
                    end
                end
                else if(funct3 == 3'b101) begin
                    if(!flag[0]) begin
                        pc_fetch = pc + immidiate;
                        jump_en  = 1'b1;
                    end
               end
               else if(funct3 == 3'b110) begin
                    if(flag[2]) begin
                        pc_fetch = pc + immidiate;
                        jump_en  = 1'b1;
                    end
               end
               else if(funct3 == 3'b110) begin
                    if(!flag[2]) begin
                        pc_fetch = pc + immidiate;
                        jump_en  = 1'b1;
                    end
               end       
           end
           `i_type_jalr: begin
                data_rd_wb_ns = pc + 4; 
                pc_fetch      = result;
                jump_en       = 1'b1;
           end
           `j_type: begin
                data_rd_wb_ns = pc + 4;
                pc_fetch      = result;
                jump_en       = 1'b1;  
            end
            `u_type_auipc: 
               data_rd_wb_ns = pc + immidiate;  
            `u_type_lui: begin
               data_rd_wb_ns = immidiate;
            end
            
        endcase  
    end
    
    task set_default(); begin
        data_rd_wb_ns = 0;
        addr_mem_ns   = 0;
        rs2_mem_ns    = 0;
        pc_fetch      = 0;
        jump_en       = 0;
        funct3_mem_ns = 0;    
        mem_wb_ns     = 0;     
    end
    endtask
    
endmodule
