//=============================
// this is a reference model for the RV32I mini_core DUT
// Will be using a simple case statement to model the:


module ref_rv32i (
    input clk,
    input rst
)

logic [31:0] instruction;
logic [31:0] pc, next_pc;
logic [31:0] regfile  [31:0];
logic [7:0] dmem [MSB_D_MEM:0];
logic [7:0] next_dmem [MSB_D_MEM:0];
logic [7:0] imem [MSB_I_MEM:0];
logic [7:0] next_imem [MSB_I_MEM:0];


`MAFIA_DFF(pc,      next_pc,      clk, rst);
`MAFIA_DFF(regfile, next_regfile, clk, rst);
`MAFIA_DFF(dmem,    next_dmem,    clk, rst);
`MAFIA_DFF(imem,    next_imem,    clk, rst);
always_comb begin
  unique casez (OpcodeQ101H) // Mux
    JALR, I_OP, LOAD : SelImmTypeQ101H = I_TYPE;
    LUI, AUIPC       : SelImmTypeQ101H = U_TYPE;
    JAL              : SelImmTypeQ101H = J_TYPE;
    BRANCH           : SelImmTypeQ101H = B_TYPE;
    STORE            : SelImmTypeQ101H = S_TYPE;
    default          : SelImmTypeQ101H = I_TYPE;
  endcase
  unique casez (SelImmTypeQ101H) // Mux
    U_TYPE : ImmediateQ101H = {     InstructionQ101H[31:12], 12'b0 } ;                                                                            // U_Immediate
    I_TYPE : ImmediateQ101H = { {20{InstructionQ101H[31]}} , InstructionQ101H[31:20] };                                                           // I_Immediate
    S_TYPE : ImmediateQ101H = { {20{InstructionQ101H[31]}} , InstructionQ101H[31:25] , InstructionQ101H[11:7]  };                                 // S_Immediate
    B_TYPE : ImmediateQ101H = { {20{InstructionQ101H[31]}} , InstructionQ101H[7]     , InstructionQ101H[30:25] , InstructionQ101H[11:8]  , 1'b0}; // B_Immediate
    J_TYPE : ImmediateQ101H = { {12{InstructionQ101H[31]}} , InstructionQ101H[19:12] , InstructionQ101H[20]    , InstructionQ101H[30:21] , 1'b0}; // J_Immediate
    default: ImmediateQ101H = {     InstructionQ101H[31:12], 12'b0 };                                                                             // U_Immediate
  endcase
end
always_comb begin
    instruction  = imem[pc];
    rd           = instruction[11:7];
    rs1          = instruction[19:15];
    rs2          = instruction[24:20];
    funct3       = instruction[14:12];
    funct7       = instruction[31:25];
    next_pc      = pc + 4;
    next_regfile = regfile;
    next_dmem    = dmem;
    next_imem    = imem;
    unique case (instruction)
    32'b????????????????????_?????_0110111: begin // LUI
        next_regfile[rd] = ImmediateQ101H;
    end
    32'b????????????????????_?????_0010111: begin // AUIPC
        next_regfile[rd] = pc + ImmediateQ101H
    end
    32'b????????????????????_?????_1101111: begin // JAL
        next_regfile[rd] = pc + 4;
        next_pc = pc + ImmediateQ101H
    end
    // TODO...


    //BEQ/BNE/BLT/BGE/BLTU/BGEU
    32'b???????_?????_?????_???_?????_1100011: begin
        if((funct3 == 000) && (regfile[rs1] == regfile[rs2]) next_pc = pc + 
            end



        default: begin
            default_case
        end
    endcase


endmodule