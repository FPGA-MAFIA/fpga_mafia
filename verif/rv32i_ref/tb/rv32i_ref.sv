//=============================
// this is a reference model for the RV32I mini_core DUT
// Will be using a simple case statement to model the:
`include "macros.sv"
module rv32i_ref 
#(  
    parameter I_MEM_LSB = 'h0_0000,
    parameter I_MEM_MSB = 'h1_0000 - 1'h1,
    parameter D_MEM_LSB = 'h1_0000,
    parameter D_MEM_MSB = 'h2_0000 - 1'h1 
) (
    input clk,
    input rst,
    input run
);
import rv32i_ref_pkg::*;
// Define VGA memory sizes
parameter SIZE_VGA_MEM          = 38400; 
parameter VGA_MEM_REGION_FLOOR  = 32'h00FF_0000;
parameter VGA_MEM_REGION_ROOF   = VGA_MEM_REGION_FLOOR + SIZE_VGA_MEM - 1;

// VGA Memory array 
logic [7:0]  VGAMem     [VGA_MEM_REGION_ROOF:VGA_MEM_REGION_FLOOR]; 
logic [7:0]  NextVGAMem [VGA_MEM_REGION_ROOF:VGA_MEM_REGION_FLOOR]; 
t_rv32i_instr instr_type;
logic [31:0] instruction;
logic [31:0] pc, next_pc;
logic [7:0] imem        [I_MEM_MSB:I_MEM_LSB];
logic [7:0] next_imem   [I_MEM_MSB:I_MEM_LSB];
logic [7:0] dmem        [D_MEM_MSB:D_MEM_LSB];
logic [7:0] next_dmem   [D_MEM_MSB:D_MEM_LSB];
logic [7:0] dmem_33     [D_MEM_MSB:D_MEM_LSB];
logic [7:0] next_dmem_33[D_MEM_MSB:D_MEM_LSB];
logic [31:0][31:0]  next_regfile; 
logic [31:0][31:0]  regfile; 
logic [4:0] rd, rs1, rs2;
logic [31:0] U_ImmediateQ101H;
logic [31:0] I_ImmediateQ101H;
logic [31:0] S_ImmediateQ101H;
logic [31:0] B_ImmediateQ101H;
logic [31:0] J_ImmediateQ101H;
logic [31:0] data_rd1, data_rd2;
logic [31:0] mem_rd_addr;
logic [31:0] mem_wr_addr;
logic        illegal_instruction;
logic        ebreak_was_called;
logic        ecall_was_called;
logic        en_end_of_simulation;
logic        end_of_simulation;
logic [2:0]  funct3;
logic [6:0]  funct7;
logic [31:0] lb_data    , lh_data    , lw_data    , lbu_data    , lhu_data;
logic [31:0] vga_lb_data, vga_lh_data, vga_lw_data, vga_lbu_data, vga_lhu_data;
logic        hit_vga_mem_rd;
logic        hit_vga_mem_wr;
logic [31:0] reg_wr_data;
logic        reg_wr_en;


t_debug_info debug_info;
assign debug_info.clk         = clk;
assign debug_info.pc          = pc;
assign debug_info.instruction = instruction;
assign debug_info.instr_type  = instr_type;
assign debug_info.rd          = rd;
assign debug_info.rs1         = rs1;
assign debug_info.rs2         = rs2;
assign debug_info.mem_rd_addr = mem_rd_addr;
assign debug_info.mem_wr_addr = mem_wr_addr;
assign debug_info.data_rd1    = data_rd1;
assign debug_info.data_rd2    = data_rd2;
assign debug_info.reg_wr_data = reg_wr_data;


//=======================================================
// DFF - the synchronous elements in the reference RV32I model
//=======================================================
`MAFIA_EN_DFF    (regfile, next_regfile,  clk, run);
`MAFIA_EN_DFF    (dmem,    next_dmem,     clk, run);
`MAFIA_EN_DFF    (dmem_33, next_dmem_33,  clk, run);
`MAFIA_EN_DFF    (imem,    next_imem,     clk, run);
`MAFIA_EN_DFF    (VGAMem,  NextVGAMem,    clk, run);
`MAFIA_EN_RST_DFF(pc  ,    next_pc,       clk , ((!end_of_simulation) && run) , rst);

`MAFIA_EN_RST_DFF(end_of_simulation,  1'b1   , clk , en_end_of_simulation , rst)
//=======================================================
// The instruction enumerates & terms for the reference model
//=======================================================
assign instruction[7:0]  = imem[pc+0];
assign instruction[15:8] = imem[pc+1];
assign instruction[23:16]= imem[pc+2];
assign instruction[31:24]= imem[pc+3];
//=======================================================
assign U_ImmediateQ101H = {     instruction[31:12], 12'b0 } ;                                                             // U_Immediate
assign I_ImmediateQ101H = { {20{instruction[31]}} , instruction[31:20] };                                                 // I_Immediate
assign S_ImmediateQ101H = { {20{instruction[31]}} , instruction[31:25] , instruction[11:7]  };                            // S_Immediate
assign B_ImmediateQ101H = { {20{instruction[31]}} , instruction[7]     , instruction[30:25] , instruction[11:8]  , 1'b0}; // B_Immediate
assign J_ImmediateQ101H = { {12{instruction[31]}} , instruction[19:12] , instruction[20]    , instruction[30:21] , 1'b0}; // J_Immediate
assign rd               = instruction[11:7];
assign rs1              = instruction[19:15];
assign rs2              = instruction[24:20];
assign funct3           = instruction[14:12];
assign funct7           = instruction[31:25];
assign data_rd1         = regfile[rs1];
assign data_rd2         = regfile[rs2];
assign mem_rd_addr      = data_rd1 + I_ImmediateQ101H;
assign mem_wr_addr      = data_rd1 + S_ImmediateQ101H;
assign reg_wr_data      = next_regfile[rd];
//=======================================================
// load data from memory - byte, half-word, word
//=======================================================
logic DMemRdEn;
logic DMemWrEn;
logic hit_local_mem_rd;
logic hit_local_mem_wr;
logic hit_33_mem_rd;
logic hit_33_mem_wr;
logic hit_who_am_i;
assign  DMemWrEn         = (instr_type == SB) || (instr_type == SH) || (instr_type == SW);
assign  DMemRdEn         = (instr_type == LB) || (instr_type == LH) || (instr_type == LW) || (instr_type == LBU) || (instr_type == LHU);
assign  hit_vga_mem_rd   = (mem_rd_addr>=VGA_MEM_REGION_FLOOR) && (mem_rd_addr<VGA_MEM_REGION_ROOF) && DMemRdEn;
assign  hit_vga_mem_wr   = (mem_wr_addr>=VGA_MEM_REGION_FLOOR) && (mem_wr_addr<VGA_MEM_REGION_ROOF) && DMemWrEn;
assign  hit_local_mem_rd = (mem_rd_addr[31:24]==8'h0 ) && (mem_rd_addr[23:0]<D_MEM_MSB) && DMemRdEn;
assign  hit_local_mem_wr = (mem_wr_addr[31:24]==8'h0 ) && (mem_wr_addr[23:0]<D_MEM_MSB) && DMemWrEn;
assign  hit_33_mem_rd    = (mem_rd_addr[31:24]==8'h33) && (mem_rd_addr[23:0]<D_MEM_MSB) && DMemRdEn;
assign  hit_33_mem_wr    = (mem_wr_addr[31:24]==8'h33) && (mem_wr_addr[23:0]<D_MEM_MSB) && DMemWrEn;
assign  hit_who_am_i     = (mem_rd_addr[31:24]==8'h0 ) && (mem_rd_addr[23:0]==24'hFFFFFF) && DMemRdEn;
assign lb_data [31:0] = hit_local_mem_rd ? { {8{dmem  [mem_rd_addr+0][7]}}       ,{8{dmem  [mem_rd_addr+0][7]}}       ,{8{dmem  [mem_rd_addr+0][7]}}       , dmem   [mem_rd_addr+0]}: 
                        hit_vga_mem_rd   ? { {8{VGAMem[mem_rd_addr+0][7]}}       ,{8{VGAMem[mem_rd_addr+0][7]}}       ,{8{VGAMem[mem_rd_addr+0][7]}}       , VGAMem [mem_rd_addr+0]}:
                        hit_33_mem_rd    ? { {8{dmem_33[mem_rd_addr[23:0]+0][7]}},{8{dmem_33[mem_rd_addr[23:0]+0][7]}},{8{dmem_33[mem_rd_addr[23:0]+0][7]}}, dmem_33[mem_rd_addr[23:0]+0]}:
                        hit_who_am_i     ? 32'h0000022                                                                                                            :
                                                                                                                                           32'b0                  ;
assign lh_data [31:0] = hit_local_mem_rd ? { {8{dmem  [mem_rd_addr+1][7]}}       ,{8{dmem  [mem_rd_addr+1][7]}}       ,   dmem  [mem_rd_addr+1]        , dmem   [mem_rd_addr+0]} :
                        hit_vga_mem_rd   ? { {8{VGAMem[mem_rd_addr+1][7]}}       ,{8{VGAMem[mem_rd_addr+1][7]}}       ,   VGAMem[mem_rd_addr+1]        , VGAMem [mem_rd_addr+0]} :
                        hit_33_mem_rd    ? { {8{dmem_33[mem_rd_addr[23:0]+1][7]}},{8{dmem_33[mem_rd_addr[23:0]+1][7]}},   dmem_33[mem_rd_addr[23:0]+1] , dmem_33[mem_rd_addr[23:0]+0]} :
                        hit_who_am_i     ? 32'h0000022                                                                                                            :
                                                                                                                                          32'b0                   ;
assign lw_data [31:0] = hit_local_mem_rd ? {    dmem[mem_rd_addr+3]          ,   dmem  [mem_rd_addr+2]       ,   dmem  [mem_rd_addr+1]        , dmem   [mem_rd_addr+0]} :
                        hit_vga_mem_rd   ? {    VGAMem[mem_rd_addr+3]        ,   VGAMem[mem_rd_addr+2]       ,   VGAMem[mem_rd_addr+1]        , VGAMem [mem_rd_addr+0]} :
                        hit_33_mem_rd    ? {    dmem_33[mem_rd_addr[23:0]+3] ,   dmem_33[mem_rd_addr[23:0]+2],   dmem_33[mem_rd_addr[23:0]+1] , dmem_33[mem_rd_addr[23:0]+0]} :
                        hit_who_am_i     ? 32'h0000022                                                                                                            :
                                                                                                                                          32'b0                   ;
assign lbu_data[31:0] = hit_local_mem_rd ? { {8{1'b0}} ,{8{1'b0}} ,{8{1'b0}}                     , dmem   [mem_rd_addr+0]} :
                        hit_vga_mem_rd   ? { {8{1'b0}} ,{8{1'b0}} ,{8{1'b0}}                     , VGAMem [mem_rd_addr+0]} :
                        hit_33_mem_rd    ? { {8{1'b0}} ,{8{1'b0}} ,{8{1'b0}}                     , dmem_33[mem_rd_addr[23:0]+0]} :
                        hit_who_am_i     ? 32'h0000022                                                                    :
                                                                                                  32'b0                   ;
assign lhu_data[31:0] = hit_local_mem_rd ? { {8{1'b0}} ,{8{1'b0}} , dmem  [mem_rd_addr+1]        , dmem   [mem_rd_addr+0]}       :  
                        hit_vga_mem_rd   ? { {8{1'b0}} ,{8{1'b0}} , VGAMem[mem_rd_addr+1]        , VGAMem [mem_rd_addr+0]}       :
                        hit_33_mem_rd    ? { {8{1'b0}} ,{8{1'b0}} , dmem_33[mem_rd_addr[23:0]+1] , dmem_33[mem_rd_addr[23:0]+0]} :
                        hit_who_am_i     ? 32'h0000022                                                                           :
                                                                                                    32'b0                        ;

//=======================================================
// This main logic of the reference model
//=======================================================
// using a single always_comb block with a case statement
// to decode+execute+mem+write_back
//=======================================================
always_comb begin
    //=======================
    // default assignments       
    //=======================
    next_pc             = pc + 4;
    next_regfile        = regfile;
    reg_wr_en           = 1'b0;
    illegal_instruction = 1'b0;
    ebreak_was_called   = 1'b0;
    ecall_was_called    = 1'b0;
    next_dmem           = dmem;
    next_dmem_33        = dmem_33;
    next_imem           = imem;
    NextVGAMem          = VGAMem;
    instr_type          = NULL;
    if(rst) NextVGAMem  = '{default: '0};
    //=================================================================
    // decode+execute+mem+write_back 
    // using a single case statement on the instruction
    //=================================================================
    casez (instruction)
    //=======================================================
    // LUI
    //=======================================================
    32'b????????????????????_?????_0110111: begin
        instr_type       = LUI;
        next_regfile[rd] = U_ImmediateQ101H;
        reg_wr_en        = 1'b1;
    end
    //=======================================================
    // AUIPC
    //=======================================================
    32'b????????????????????_?????_0010111: begin
        instr_type       = AUIPC;
        next_regfile[rd] = pc + U_ImmediateQ101H;
        reg_wr_en        = 1'b1;
    end
    //=======================================================
    //  JAL
    //=======================================================
    32'b????????????????????_?????_1101111: begin
        instr_type       = JAL ;
        next_regfile[rd] = pc + 4;
        reg_wr_en        = 1'b1;
        next_pc = pc + J_ImmediateQ101H;
    end
    //=======================================================
    //  JALR
    //=======================================================
    32'b????????????_?????_???_?????_1100111: begin
        instr_type       = JALR;
        next_regfile[rd] = pc + 4;
        reg_wr_en        = 1'b1;
        next_pc = regfile[rs1] + I_ImmediateQ101H;
    end
    //=======================================================
    //BEQ/BNE/BLT/BGE/BLTU/BGEU
    //=======================================================
    32'b???????_?????_?????_000_?????_1100011: begin
        instr_type       = BEQ;
        if(data_rd1==data_rd2) next_pc = pc + B_ImmediateQ101H;
    end
    32'b???????_?????_?????_001_?????_1100011: begin
        instr_type       = BNE;
        if(data_rd1!=data_rd2) next_pc = pc + B_ImmediateQ101H;
    end
    32'b???????_?????_?????_100_?????_1100011: begin
        instr_type       = BLT;
        if($signed(data_rd1)<$signed(data_rd2)) next_pc = pc + B_ImmediateQ101H;
    end
    32'b???????_?????_?????_101_?????_1100011: begin
        instr_type       = BGE;
        if(~($signed(data_rd1)<$signed(data_rd2))) next_pc = pc + B_ImmediateQ101H;
    end
    32'b???????_?????_?????_110_?????_1100011: begin
        instr_type       = BLTU;
        if(data_rd1<data_rd2) next_pc = pc + B_ImmediateQ101H;
    end
    32'b???????_?????_?????_111_?????_1100011: begin
        instr_type       = BGEU;
        if(~(data_rd1<data_rd2)) next_pc = pc + B_ImmediateQ101H;
    end
    //=======================================================
    //LB/LH/LW/LBU/LHU
    //=======================================================
    32'b???????_?????_?????_000_?????_0000011: begin
        instr_type       = LB;
        next_regfile[rd] = lb_data;
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_001_?????_0000011: begin
        instr_type       = LH;
        next_regfile[rd] = lh_data;
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_010_?????_0000011: begin
        instr_type       = LW;
        next_regfile[rd] = lw_data;
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_100_?????_0000011: begin
        instr_type       = LBU;
        next_regfile[rd] = lbu_data;
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_101_?????_0000011: begin
        instr_type       = LHU;
        next_regfile[rd] = lhu_data;
        reg_wr_en        = 1'b1;
    end
    //=======================================================
    //SB/SH/SW
    //=======================================================
    32'b???????_?????_?????_000_?????_0100011: begin
        instr_type       = SB;
            if(hit_local_mem_wr) next_dmem[mem_wr_addr+0]  = data_rd2[ 7: 0];//SB
            if(hit_vga_mem_wr)   NextVGAMem[mem_wr_addr+0] = data_rd2[ 7: 0];//SB
            if(hit_33_mem_wr)    next_dmem_33[mem_wr_addr+0]  = data_rd2[ 7: 0];//SB
    end
    32'b???????_?????_?????_001_?????_0100011: begin
        instr_type       = SH;
            if(hit_local_mem_wr) next_dmem[mem_wr_addr+0]  = data_rd2[ 7: 0];//SH
            if(hit_local_mem_wr) next_dmem[mem_wr_addr+1]  = data_rd2[15: 8];//SH
            if(hit_vga_mem_wr)   NextVGAMem[mem_wr_addr+0] = data_rd2[ 7: 0];//SH
            if(hit_vga_mem_wr)   NextVGAMem[mem_wr_addr+1] = data_rd2[15: 8];//SH
            if(hit_33_mem_wr)    next_dmem_33[mem_wr_addr+0]  = data_rd2[ 7: 0];//SH
            if(hit_33_mem_wr)    next_dmem_33[mem_wr_addr+1]  = data_rd2[15: 8];//SH
    end
    32'b???????_?????_?????_010_?????_0100011: begin
        instr_type       = SW;
            if(hit_local_mem_wr) next_dmem[mem_wr_addr+0]  = data_rd2[ 7: 0];//SW
            if(hit_local_mem_wr) next_dmem[mem_wr_addr+1]  = data_rd2[15: 8];//SW
            if(hit_local_mem_wr) next_dmem[mem_wr_addr+2]  = data_rd2[23:16];//SW
            if(hit_local_mem_wr) next_dmem[mem_wr_addr+3]  = data_rd2[31:24];//SW
            if(hit_vga_mem_wr)   NextVGAMem[mem_wr_addr+0] = data_rd2[ 7: 0];//SW
            if(hit_vga_mem_wr)   NextVGAMem[mem_wr_addr+1] = data_rd2[15: 8];//SW
            if(hit_vga_mem_wr)   NextVGAMem[mem_wr_addr+2] = data_rd2[23:16];//SW
            if(hit_vga_mem_wr)   NextVGAMem[mem_wr_addr+3] = data_rd2[31:24];//SW
            if(hit_33_mem_wr)    next_dmem_33[mem_wr_addr[23:0]+0]  = data_rd2[ 7: 0];//SW
            if(hit_33_mem_wr)    next_dmem_33[mem_wr_addr[23:0]+1]  = data_rd2[15: 8];//SW
            if(hit_33_mem_wr)    next_dmem_33[mem_wr_addr[23:0]+2]  = data_rd2[23:16];//SW
            if(hit_33_mem_wr)    next_dmem_33[mem_wr_addr[23:0]+3]  = data_rd2[31:24];//SW
    end
    //=======================================================
    //ADDI/SLTI/SLTIU/XORI/ORI/ANDI/SLLI/SRLI/SRAI
    //=======================================================
    32'b???????_?????_?????_000_?????_0010011: begin
        instr_type       = ADDI;
        next_regfile[rd] = data_rd1 + I_ImmediateQ101H;//ADDI
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_010_?????_0010011: begin
        instr_type       = SLTI;
        next_regfile[rd] = data_rd1 < I_ImmediateQ101H;//SLTI
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_011_?????_0010011: begin
        instr_type       = SLTIU;
        next_regfile[rd] = data_rd1 < I_ImmediateQ101H;//SLTIU
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_100_?????_0010011: begin
        instr_type       = XORI;
        next_regfile[rd] = data_rd1 ^ I_ImmediateQ101H;//XORI
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_110_?????_0010011: begin
        instr_type       = ORI;
        next_regfile[rd] = data_rd1 | I_ImmediateQ101H;//ORI
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_111_?????_0010011: begin
        instr_type       = ANDI;
        next_regfile[rd] = data_rd1 & I_ImmediateQ101H;//ANDI
        reg_wr_en        = 1'b1;
    end
    32'b???????_?????_?????_001_?????_0010011: begin
        instr_type       = SLLI;
        next_regfile[rd] = data_rd1 << I_ImmediateQ101H;//SLLI
        reg_wr_en        = 1'b1;
    end
    32'b0000000_?????_?????_101_?????_0010011: begin
        instr_type       = SRLI;
        next_regfile[rd] = data_rd1 >> I_ImmediateQ101H[4:0];//SRLI
        reg_wr_en        = 1'b1;
    end
    32'b0100000_?????_?????_101_?????_0010011: begin
        instr_type       = SRAI;
        next_regfile[rd] = $signed(data_rd1) >>> I_ImmediateQ101H[4:0];//SRAI
        reg_wr_en        = 1'b1;
    end
    //=======================================================
    //ADD/SUB/SLL/SLT/SLTU/XOR/SRL/SRA/OR/AND
    //=======================================================
    32'b0000000_?????_?????_000_?????_0110011: begin
        instr_type       = ADD;
        next_regfile[rd] = data_rd1 + data_rd2;//ADD
        reg_wr_en        = 1'b1;
    end
    32'b0100000_?????_?????_000_?????_0110011: begin
        instr_type       = SUB;
        next_regfile[rd] = data_rd1 - data_rd2;//SUB
        reg_wr_en        = 1'b1;
    end
    32'b0000000_?????_?????_001_?????_0110011: begin
        instr_type       = SLL;
        next_regfile[rd] = data_rd1 << data_rd2[4:0];//SLL
        reg_wr_en        = 1'b1;
    end
    32'b0000000_?????_?????_010_?????_0110011: begin
        instr_type       = SLT;
        next_regfile[rd] = data_rd1 < data_rd2;//SLT
        reg_wr_en        = 1'b1;
    end
    32'b0000000_?????_?????_011_?????_0110011: begin
        instr_type       = SLTU;
        next_regfile[rd] = data_rd1 < data_rd2;//SLTU
        reg_wr_en        = 1'b1;
    end
    32'b0000000_?????_?????_100_?????_0110011: begin
        instr_type       = XOR;
        next_regfile[rd] = data_rd1 ^ data_rd2;//XOR
        reg_wr_en        = 1'b1;
    end
    32'b0000000_?????_?????_101_?????_0110011: begin
        instr_type       = SRL;
        next_regfile[rd] = data_rd1 >> data_rd2[4:0];//SRL
        reg_wr_en        = 1'b1;
    end
    32'b0100000_?????_?????_101_?????_0110011: begin
        instr_type       = SRA;
        next_regfile[rd] = $signed(data_rd1) >>> data_rd2[4:0];//SRA
        reg_wr_en        = 1'b1;
    end
    32'b0000000_?????_?????_110_?????_0110011: begin
        instr_type       = OR;
        next_regfile[rd] = data_rd1 | data_rd2;//OR
        reg_wr_en        = 1'b1;
    end
    32'b0000000_?????_?????_111_?????_0110011: begin
        instr_type       = AND;
        next_regfile[rd] = data_rd1 & data_rd2;//AND
        reg_wr_en        = 1'b1;
    end
    //=======================================================
    //  FENCE
    //=======================================================
    32'b????????????_?????_???_?????_0001111: begin
        instr_type       = FENCE;
        //do nothing -> order is preserved without doing anything
    end
    //=======================================================
    //  ECALL
    //=======================================================
    32'b000000000000_00000_000_00000_1110011: begin
        instr_type       = ECALL;
        ecall_was_called  = 1'b1;
    end
    //=======================================================
    //  EBREAK
    //=======================================================
    32'b000000000001_00000_000_00000_1110011: begin
        instr_type       = EBREAK;
        ebreak_was_called = 1'b1;
    end
    //=======================================================
    // default
    //=======================================================
    default: begin
        instr_type       = NULL;
        illegal_instruction = 1'b1 && ~rst;
    end
    endcase

    next_regfile[0] = '0; // x0 is always zero

end// always_comb

assign en_end_of_simulation = ecall_was_called || ebreak_was_called || illegal_instruction;



endmodule