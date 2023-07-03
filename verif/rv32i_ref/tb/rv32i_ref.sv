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
    input rst
);

typedef enum logic [5:0] {
    NULL  = 6'd0,
    LUI   = 6'd1,
    AUIPC = 6'd2,
    JAL   = 6'd3,
    JALR  = 6'd4,
    BEQ   = 6'd5,
    BNE   = 6'd6,
    BLT   = 6'd7,
    BGE   = 6'd8,
    BLTU  = 6'd9,
    BGEU  = 6'd10,
    LB    = 6'd11,
    LH    = 6'd12,
    LW    = 6'd13,
    LBU   = 6'd14,
    LHU   = 6'd15,
    SB    = 6'd16,
    SH    = 6'd17,
    SW    = 6'd18,
    ADDI  = 6'd19,
    SLTI  = 6'd20,
    SLTIU = 6'd21,
    XORI  = 6'd22,
    ORI   = 6'd23,
    ANDI  = 6'd24,
    SLLI  = 6'd25,
    SRLI  = 6'd26,
    SRAI  = 6'd27,
    ADD   = 6'd28,
    SUB   = 6'd29,
    SLL   = 6'd30,
    SLT   = 6'd31,
    SLTU  = 6'd32,
    XOR   = 6'd33,
    SRL   = 6'd34,
    SRA   = 6'd35,
    OR    = 6'd36,
    AND   = 6'd37,
    FENCE = 6'd38,
    ECALL = 6'd39,
    EBREAK= 6'd40,
    CSRRW = 6'd41,
    CSRRS = 6'd42,
    CSRRC = 6'd43,
    CSRRWI= 6'd44,
    CSRRSI= 6'd45,
    CSRRCI= 6'd46
  } t_rv32i_instr;

// Define VGA memory sizes
parameter SIZE_VGA_MEM          = 38400; 
parameter VGA_MEM_REGION_FLOOR  = 32'h00FF_0000;
parameter VGA_MEM_REGION_ROOF   = VGA_MEM_REGION_FLOOR + SIZE_VGA_MEM - 1;
// VGA Memory array 
logic [7:0]  VGAMem     [VGA_MEM_REGION_ROOF:VGA_MEM_REGION_FLOOR]; //80 x 480
logic [7:0]  NextVGAMem [VGA_MEM_REGION_ROOF:VGA_MEM_REGION_FLOOR]; 
t_rv32i_instr instr_type;
logic [31:0] instruction;
logic [31:0] pc, next_pc;
logic [7:0] imem        [I_MEM_MSB:I_MEM_LSB];
logic [7:0] next_imem   [I_MEM_MSB:I_MEM_LSB];
logic [7:0] dmem        [D_MEM_MSB:D_MEM_LSB];
logic [7:0] next_dmem   [D_MEM_MSB:D_MEM_LSB];
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
//=======================================================
// DFF - the synchronous elements in the reference RV32I model
//=======================================================
`MAFIA_DFF       (regfile, next_regfile,  clk);
`MAFIA_DFF       (dmem,    next_dmem,     clk);
`MAFIA_DFF       (imem,    next_imem,     clk);
`MAFIA_DFF       (VGAMem,  NextVGAMem,    clk);
`MAFIA_EN_RST_DFF(pc  ,    next_pc,       clk , (!end_of_simulation) , rst);

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
assign rd           = instruction[11:7];
assign rs1          = instruction[19:15];
assign rs2          = instruction[24:20];
assign funct3       = instruction[14:12];
assign funct7       = instruction[31:25];
assign data_rd1     = regfile[rs1];
assign data_rd2     = regfile[rs2];
assign mem_rd_addr  = data_rd1 + I_ImmediateQ101H;
assign mem_wr_addr  = data_rd1 + S_ImmediateQ101H;

logic [31:0] lb_data    , lh_data    , lw_data    , lbu_data    , lhu_data;
logic [31:0] vga_lb_data, vga_lh_data, vga_lw_data, vga_lbu_data, vga_lhu_data;
logic hit_vga_mem_rd;
logic hit_vga_mem_wr;
//=======================================================
// load data from memory - byte, half-word, word
//=======================================================
assign lb_data [31:0] = { {8{dmem[mem_rd_addr+0][7]}}  ,{8{dmem[mem_rd_addr+0][7]}}   ,{8{dmem[mem_rd_addr+0][7]}}, dmem[mem_rd_addr+0]};//LB
assign lh_data [31:0] = { {8{dmem[mem_rd_addr+1][7]}}  ,{8{dmem[mem_rd_addr+1][7]}}   ,  dmem[mem_rd_addr+1]      , dmem[mem_rd_addr+0]};//LH
assign lw_data [31:0] = {   dmem[mem_rd_addr+3]        ,  dmem[mem_rd_addr+2]         ,  dmem[mem_rd_addr+1]      , dmem[mem_rd_addr+0]};//LW
assign lbu_data[31:0] = { {8{1'b0}}                    ,{8{1'b0}}                     ,{8{1'b0}}                  , dmem[mem_rd_addr+0]};//LBU
assign lhu_data[31:0] = { {8{1'b0}}                    ,{8{1'b0}}                     ,  dmem[mem_rd_addr+1]      , dmem[mem_rd_addr+0]};//LHU
//=======================================================
// load data from VGA memory - byte, half-word, word
assign vga_lb_data [31:0] = { {8{VGAMem[mem_rd_addr+0][7]}} ,{8{VGAMem[mem_rd_addr+0][7]}} ,{8{VGAMem[mem_rd_addr+0][7]}}, VGAMem[mem_rd_addr+0]};//LB
assign vga_lh_data [31:0] = { {8{VGAMem[mem_rd_addr+1][7]}} ,{8{VGAMem[mem_rd_addr+1][7]}} ,  VGAMem[mem_rd_addr+1]      , VGAMem[mem_rd_addr+0]};//LH
assign vga_lw_data [31:0] = {    VGAMem[mem_rd_addr+3]      ,  VGAMem[mem_rd_addr+2]       ,  VGAMem[mem_rd_addr+1]      , VGAMem[mem_rd_addr+0]};//LW
assign vga_lbu_data[31:0] = { {8{1'b0}}                     ,{8{1'b0}}                     ,{8{1'b0}}                    , VGAMem[mem_rd_addr+0]};//LBU
assign vga_lhu_data[31:0] = { {8{1'b0}}                     ,{8{1'b0}}                     ,  VGAMem[mem_rd_addr+1]      , VGAMem[mem_rd_addr+0]};//LHU

assign  hit_vga_mem_rd = (mem_rd_addr>=VGA_MEM_REGION_FLOOR) && (mem_rd_addr<VGA_MEM_REGION_ROOF);
assign  hit_vga_mem_wr = (mem_wr_addr>=VGA_MEM_REGION_FLOOR) && (mem_wr_addr<VGA_MEM_REGION_ROOF);
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
    illegal_instruction = 1'b0;
    ebreak_was_called   = 1'b0;
    ecall_was_called    = 1'b0;
    next_dmem           = dmem;
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
    end
    //=======================================================
    // AUIPC
    //=======================================================
    32'b????????????????????_?????_0010111: begin
        instr_type       = AUIPC;
        next_regfile[rd] = pc + U_ImmediateQ101H;
    end
    //=======================================================
    //  JAL
    //=======================================================
    32'b????????????????????_?????_1101111: begin
        instr_type       = JAL ;
        next_regfile[rd] = pc + 4;
        next_pc = pc + J_ImmediateQ101H;
    end
    //=======================================================
    //  JALR
    //=======================================================
    32'b????????????_?????_???_?????_1100111: begin
        instr_type       = JALR;
        next_regfile[rd] = pc + 4;
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
        if(data_rd1<data_rd2) next_pc = pc + B_ImmediateQ101H;
    end
    //=======================================================
    //LB/LH/LW/LBU/LHU
    //=======================================================
    32'b???????_?????_?????_000_?????_0000011: begin
        instr_type       = LB;
        next_regfile[rd] = hit_vga_mem_rd ? vga_lb_data  : lb_data;
    end
    32'b???????_?????_?????_001_?????_0000011: begin
        instr_type       = LH;
        next_regfile[rd] = hit_vga_mem_rd ? vga_lh_data  : lh_data;
    end
    32'b???????_?????_?????_010_?????_0000011: begin
        instr_type       = LW;
        next_regfile[rd] = hit_vga_mem_rd ? vga_lw_data  : lw_data;
    end
    32'b???????_?????_?????_100_?????_0000011: begin
        instr_type       = LBU;
        next_regfile[rd] = hit_vga_mem_rd ? vga_lbu_data : lbu_data;
    end
    32'b???????_?????_?????_101_?????_0000011: begin
        instr_type       = LHU;
        next_regfile[rd] = hit_vga_mem_rd ? vga_lhu_data : lhu_data;
    end
    //=======================================================
    //SB/SH/SW
    //=======================================================
    32'b???????_?????_?????_000_?????_0100011: begin
        instr_type       = SB;
            if(!hit_vga_mem_wr) next_dmem[mem_wr_addr+0] = data_rd2[ 7: 0];//SB
            if(hit_vga_mem_wr) NextVGAMem[mem_wr_addr+0] = data_rd2[ 7: 0];//SB
    end
    32'b???????_?????_?????_001_?????_0100011: begin
        instr_type       = SH;
            if(!hit_vga_mem_wr) next_dmem[mem_wr_addr+0] = data_rd2[ 7: 0];//SH
            if(!hit_vga_mem_wr) next_dmem[mem_wr_addr+1] = data_rd2[15: 8];//SH
            if(hit_vga_mem_wr) NextVGAMem[mem_wr_addr+0] = data_rd2[ 7: 0];//SH
            if(hit_vga_mem_wr) NextVGAMem[mem_wr_addr+1] = data_rd2[15: 8];//SH
    end
    32'b???????_?????_?????_010_?????_0100011: begin
        instr_type       = SW;
            if(!hit_vga_mem_wr) next_dmem[mem_wr_addr+0] = data_rd2[ 7: 0];//SW
            if(!hit_vga_mem_wr) next_dmem[mem_wr_addr+1] = data_rd2[15: 8];//SW
            if(!hit_vga_mem_wr) next_dmem[mem_wr_addr+2] = data_rd2[23:16];//SW
            if(!hit_vga_mem_wr) next_dmem[mem_wr_addr+3] = data_rd2[31:24];//SW
            if(hit_vga_mem_wr) NextVGAMem[mem_wr_addr+0] = data_rd2[ 7: 0];//SW
            if(hit_vga_mem_wr) NextVGAMem[mem_wr_addr+1] = data_rd2[15: 8];//SW
            if(hit_vga_mem_wr) NextVGAMem[mem_wr_addr+2] = data_rd2[23:16];//SW
            if(hit_vga_mem_wr) NextVGAMem[mem_wr_addr+3] = data_rd2[31:24];//SW
    end
    //=======================================================
    //ADDI/SLTI/SLTIU/XORI/ORI/ANDI/SLLI/SRLI/SRAI
    //=======================================================
    32'b???????_?????_?????_000_?????_0010011: begin
        instr_type       = ADDI;
        next_regfile[rd] = data_rd1 + I_ImmediateQ101H;//ADDI
    end
    32'b???????_?????_?????_010_?????_0010011: begin
        instr_type       = SLTI;
        next_regfile[rd] = data_rd1 < I_ImmediateQ101H;//SLTI
    end
    32'b???????_?????_?????_011_?????_0010011: begin
        instr_type       = SLTIU;
        next_regfile[rd] = data_rd1 < I_ImmediateQ101H;//SLTIU
    end
    32'b???????_?????_?????_100_?????_0010011: begin
        instr_type       = XORI;
        next_regfile[rd] = data_rd1 ^ I_ImmediateQ101H;//XORI
    end
    32'b???????_?????_?????_110_?????_0010011: begin
        instr_type       = ORI;
        next_regfile[rd] = data_rd1 | I_ImmediateQ101H;//ORI
    end
    32'b???????_?????_?????_111_?????_0010011: begin
        instr_type       = ANDI;
        next_regfile[rd] = data_rd1 & I_ImmediateQ101H;//ANDI
    end
    32'b???????_?????_?????_001_?????_0010011: begin
        instr_type       = SLLI;
        next_regfile[rd] = data_rd1 << I_ImmediateQ101H;//SLLI
    end
    32'b0000000_?????_?????_101_?????_0010011: begin
        instr_type       = SRLI;
        next_regfile[rd] = data_rd1 >> I_ImmediateQ101H[4:0];//SRLI
    end
    32'b0100000_?????_?????_101_?????_0010011: begin
        instr_type       = SRAI;
        next_regfile[rd] = $signed(data_rd1) >>> I_ImmediateQ101H[4:0];//SRAI
    end
    //=======================================================
    //ADD/SUB/SLL/SLT/SLTU/XOR/SRL/SRA/OR/AND
    //=======================================================
    32'b0000000_?????_?????_000_?????_0110011: begin
        instr_type       = ADD;
        next_regfile[rd] = data_rd1 + data_rd2;//ADD
    end
    32'b0100000_?????_?????_000_?????_0110011: begin
        instr_type       = SUB;
        next_regfile[rd] = data_rd1 - data_rd2;//SUB
    end
    32'b0000000_?????_?????_001_?????_0110011: begin
        instr_type       = SLL;
        next_regfile[rd] = data_rd1 << data_rd2[4:0];//SLL
    end
    32'b0000000_?????_?????_010_?????_0110011: begin
        instr_type       = SLT;
        next_regfile[rd] = data_rd1 < data_rd2;//SLT
    end
    32'b0000000_?????_?????_011_?????_0110011: begin
        instr_type       = SLTU;
        next_regfile[rd] = data_rd1 < data_rd2;//SLTU
    end
    32'b0000000_?????_?????_100_?????_0110011: begin
        instr_type       = XOR;
        next_regfile[rd] = data_rd1 ^ data_rd2;//XOR
    end
    32'b0000000_?????_?????_101_?????_0110011: begin
        instr_type       = SRL;
        next_regfile[rd] = data_rd1 >> data_rd2[4:0];//SRL
    end
    32'b0100000_?????_?????_101_?????_0110011: begin
        instr_type       = SRA;
        next_regfile[rd] = $signed(data_rd1) >>> data_rd2[4:0];//SRA
    end
    32'b0000000_?????_?????_110_?????_0110011: begin
        instr_type       = OR;
        next_regfile[rd] = data_rd1 | data_rd2;//OR
    end
    32'b0000000_?????_?????_111_?????_0110011: begin
        instr_type       = AND;
        next_regfile[rd] = data_rd1 & data_rd2;//AND
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