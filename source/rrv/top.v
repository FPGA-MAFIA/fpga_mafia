`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART CONNECTS ALL STAGES OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////

`include "defines.v"

module top #(parameter OP = "READ")(
        input                           clk,
        input                           rst
);
    
    wire mem_we, mem_en;
    
    assign mem_en = ((OP == "READ") | (OP == "WRITE")) ? 1'b1 : 1'b0;
    assign mem_we = (OP == "WRITE") ? 1'b1 : 1'b0;
  
    wire [`INST_WIDTH-1:0] inst_fetch_id;
    wire [`PC_WIDTH-1:0]   pc_fetch_id;
    wire                   jump_en;   // from execution stage 
    wire [`PC_WIDTH-1:0]   load_pc;   // from execution stage 
    
    //----- fetch stage instantiation -----// 
    fetch fetch_module(
    .clk(clk),
    .rst(rst),
    .jump_en(jump_en),      // load enable incase of branches from execution stage 
    .load_pc(load_pc),      // pc from execution stage in case of branch
    .pc_en(1'b1), 
    .inst_mem_en(mem_en),
    .inst_mem_we(mem_we),
    .inst_mem_rst(rst),  
    .inst_fetch_out(inst_fetch_id),
    .pc2id(pc_fetch_id)
    );
     
    
       
    wire [`REG_WIDTH-1:0]      alu_in1;            // alu1 input  
    wire [`REG_WIDTH-1:0]      alu_in2;            // alu2 input 
    wire [`FUNC_SIZE-1:0]      funct3_alu;         // op code passed to alu
    wire [`PC_WIDTH-1:0]       pc2ex;              // pass pc to execution stage
    wire [`OP_CODE_WIDTH-1:0]  op_code2ex;         // instruction[6:0]
    wire [`FUNCT3_WIDTH-1:0]   funct3;             // instruction[14:12]
    wire [`IMM_ID-1:0]         immidiate_ex;       // used for adding value to pc or xther immidiate
    wire                       data_mem_en_idex;   // enables memory read in load-store instructions
    wire                       data_mem_we_idex;   // write enable in store instructions
    wire [`REG_WIDTH-1:0]      rs2_idex;           // used in store instructions in mem stage
    wire                       gpr_en_idex;    
    wire                       gpr_we_idex;        // write enable when write to gpr
    wire [`REG_ADDR_WIDTH-1:0] addr_rd_idex;       // rd address to write back into
    
    
    wire                         gpr_en_id;    
    wire                         gpr_we_id;      // write enable to gpr. 
    wire [`REG_ADDR_WIDTH-1:0]   addr_rd_id;     // rd address to write back into. 
    wire [`REG_WIDTH-1:0]        data_rd_id;     // rd data to write back into. 
    
    //----- decode stage instantiation -----//
     decode decode_module(
    .clk(clk),
    .rst(rst),
    
    //from fetch stage
    .instruction(inst_fetch_id),
    .pc_from_if(pc_fetch_id),
    
   //to execution stage
    .alu_in1(alu_in1),            // alu1 input  
    .alu_in2(alu_in2),            // alu2 input 
    .funct3_alu(funct3_alu),      // op code passed to alu
    .pc2ex(pc2ex),                // pass pc to execution stage
    .op_code2ex(op_code2ex),      // instruction[6:0]
    .funct3(funct3),              // instruction[14:12]
    .immidiate_ex(immidiate_ex),  // used for adding value to pc
       
    //to data memory stage
    .data_mem_en_idex(data_mem_en_idex),   // enables memory read in load-store instructions
    .data_mem_we_idex(data_mem_we_idex),   // write enable in store instructions
    .rs2_idex(rs2_idex),                   // used in store instructions in mem stage
    
    //to write back stage 
    .gpr_en_idex(gpr_en_idex),    
    .gpr_we_idex(gpr_we_idex),       // write enable when write to gpr
    .addr_rd_idex(addr_rd_idex),     // rd address to write back into
    
    //from write back stage
    .gpr_en_wb(gpr_en_id),     
    .gpr_we_wb(gpr_we_id),
    .rd_in_wb(data_rd_id),       // value of rd from rightback. calculated at execution stage or load instruction in mem stage
    .addr_rd_wb(addr_rd_id)      // rd address to write back into
    );
    
    
    
    wire                           data_mem_en_mem;    // enables memory in load-store instructions. passed as is to next stage
    wire                           data_mem_we_mem;    // write enable in store instructions. passed as is to next stage
    wire [`REG_WIDTH-1:0]          rs2_mem;            // used in store instructions. passed as is to next stage
    wire [$clog2(`DATA_DEPTH)-1:0] addr_mem;           // adder to store rs2 or load to rd
    wire                           gpr_en_wb;    
    wire                           gpr_we_wb;          // write enable to gpr. pass as is to next stage
    wire [`REG_ADDR_WIDTH-1:0]     addr_rd_wb;         // rd address to write back into. pass as is to next stage
    wire [`REG_WIDTH-1:0]          data_rd_wb;         // rd data to write back into. 
    wire [`FUNCT3_WIDTH-1:0]       funct3_mem;         // defines what type of load instruction
    wire                           mem_wb;             // when '1' is load instruction. when '0' something else
    
    
    //----- execution stage instantiation -----//
    execution execution_module(
    .clk(clk),
    .rst(rst),
    
    //from decode stage
    .alu_in1(alu_in1),       // alu1 input  
    .alu_in2(alu_in2),       // alu2 input 
    .funct3_alu(funct3_alu), // op code passed to alu
    .pc(pc2ex)   ,           // pass from decode stage
    .op_code(op_code2ex),    // instruction[6:0]
    .funct3(funct3),         // instruction[14:12]
   
    //to data memory stage 
    .data_mem_en_idex(data_mem_en_idex),   // enables memory read in load-store instructions. pass as is to next stage
    .data_mem_we_idex(data_mem_we_idex),   // write enable in store instructions. pass as is to next stage
    .rs2_idex(rs2_idex),                   // used in store instructions in mem stage. pass as is to next stage
    .immidiate(immidiate_ex),              // used in branch instructions to be added to pc 
    .data_mem_en_mem(data_mem_en_mem),     // enables memory in load-store instructions. passed as is to next stage
    .data_mem_we_mem(data_mem_we_mem),     // write enable in store instructions. passed as is to next stage
    .rs2_mem(rs2_mem),                     // used in store instructions. passed as is to next stage
    .addr_mem(addr_mem),                   // adder to store rs2 or load to rd
    .funct3_mem(funct3_mem),               // defines what type of load instruction
    .mem_wb(mem_wb),                       // when '1' is load instruction. when '0' something else
    
    //to write back stage
    .gpr_en_idex(gpr_en_idex),       
    .gpr_we_idex(gpr_we_idex),       // write enable to gpr. pass as is to next stage
    .addr_rd_idex(addr_rd_idex),     // rd address to write back into. pass as is to next stage
    .gpr_en_wb(gpr_en_wb),    
    .gpr_we_wb(gpr_we_wb),        // write enable to gpr. pass as is to next stage
    .addr_rd_wb(addr_rd_wb),       // rd address to write back into. pass as is to next stage
    .data_rd_wb(data_rd_wb),       // rd data to write back into. 
    
    //to fetch stage
    .pc_fetch(load_pc),
    .jump_en(jump_en)           // when '1' then update pc with pc_fetch value
    );



    wire                         gpr_en;    
    wire                         gpr_we;           // write enable to gpr. pass as is to next stage
    wire [`REG_ADDR_WIDTH-1:0]   addr_rd;          // rd address to write back into. pass as is to next stage
    wire [`REG_WIDTH-1:0]        data_rd;          // rd data to write back into. when load npt used
    wire [`REG_WIDTH-1:0]        data_rd_mem_load; // rd data to write back into when loaded from memory. 
    wire [`FUNCT3_WIDTH-1:0]     funct3_mem_wb;    // defines what type of load instruction. pass as is to next stage
    wire                         mem_mem_wb;       // when '1' is load instruction. when '0' something else. pass as is to next stage
    

    //----- memory stage instantiation -----//
    mem_stage mem_stage_module(
    .clk(clk), 
    .rst(rst),
    
    //from execution stage
    .data_mem_en(data_mem_en_mem),  // enables memory in load-store instructions
    .data_mem_we(data_mem_we_mem),  // write enable in store instructions
    .rs2_mem(rs2_mem),              // used in store instructions
    .addr_mem(addr_mem),            // adder to store rs2 or load to rd
    .funct3_mem(funct3_mem),        // defines what type of load instruction
    .mem_wb(mem_wb),                // when '1' is load instruction. when '0' something else
    
    //to write back stage 
    .gpr_en_ex(gpr_en_wb),       
    .gpr_we_ex(gpr_we_wb),              // write enable to gpr. pass as is to next stage
    .addr_rd_ex(addr_rd_wb),            // rd address to write back into. pass as is to next stage
    .data_rd_ex(data_rd_wb),            // rd data to write back into.
    .data_rd_wb_mem(data_rd_mem_load),
    .gpr_en_wb(gpr_en),    
    .gpr_we_wb(gpr_we),                 // write enable to gpr. pass as is to next stage
    .addr_rd_wb(addr_rd),                // rd address to write back into. pass as is to next stage
    .data_rd_wb(data_rd),                // rd data to write back into.
    .funct3_mem_wb(funct3_mem_wb),       // defines what type of load instruction. pass as is to next stage
    .mem_mem_wb(mem_mem_wb)             // when '1' is load instruction. when '0' something else. pass as is to next stage
     
    );
   
    //----- write back stage instantiation -----//
    write_back write_back_module(
    //to decode stage
    .gpr_en_mem(gpr_en),       
    .gpr_we_mem(gpr_we),          // write enable to gpr. 
    .addr_rd_mem(addr_rd),        // rd address to write back into. 
    .data_rd_mem(data_rd),        // rd data to write back into.
    .data_rd_mem_load(data_rd_mem_load),
    .gpr_en_id(gpr_en_id),    
    .gpr_we_id(gpr_we_id),         // write enable to gpr. 
    .addr_rd_id(addr_rd_id),       // rd address to write back into. 
    .data_rd_id(data_rd_id),        // rd data to write back into. 
    .funct3_mem_wb(funct3_mem_wb),    // defines what type of load instruction. 
    .mem_mem_wb(mem_mem_wb)       // when '1' is load instruction. when '0' something else. 
    
    );
 
endmodule
