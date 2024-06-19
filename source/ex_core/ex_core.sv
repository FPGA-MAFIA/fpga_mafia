`include "macros.vh"
`include "../common/mem.sv"

module ex_core
import ex_core_pkg::*;
(
    input logic Clk,
    input logic Rst
);

    //==============================================================================
    // Pipeline registers for instructions and data between stages
    //==============================================================================
    // Program Counter
    logic [31:0] PcQ100H, NextPcQ101H;
    // Instruction Register
    logic [31:0] instructionQ101H;
    // Register File Data
    logic [31:0] RegRdData1Q101H, RegRdData2Q101H;
    // ALU Output
    logic [31:0] AluOutQ101H, AluOutQ102H;
    // Memory Data
    logic [31:0] MemRdDataQ102H;
    // Register Write Data
    logic [31:0] RegWrDataQ102H;
    // Immediate Value
    logic [31:0] immQ101H, immQ102H;
    // Opcode
    t_opcode opcodeQ101H, opcodeQ102H;
    // Function Codes
    logic [2:0] funct3Q101H;
    logic [6:0] funct7Q101H;
    // Control Signals
    t_ctrl_alu CtrlAluQ101H;
    t_ctrl_rf CtrlRfQ101H;
    logic [1:0] sel_pc;
    logic zero;

    // Jump or Branch detection
    logic jmp_or_brnch_Q101H;
    assign jmp_or_brnch_Q101H = (opcodeQ101H == JAL) || (opcodeQ101H == JALR) || (opcodeQ101H == BRANCH);

    //==============================================================================
    // Instruction Fetch (Cycle 100)
    //==============================================================================
    //assign NextPcQ101H = sel_pc ? PcQ100H + 32'd4 : AluOut ; // FIXME - need to allow indarect pc breanch/jump
    assign NextPcQ101H = PcQ100H + 32'd4;
    `MAFIA_DFF_RST(PcQ100H, NextPcQ101H, Clk, Rst)

    // Instruction Memory
    mem #(32, 10) i_mem (
        .clock      (Clk),
        .address_a  (PcQ100H[9:2]), // 8-bit address space
        .wren_a     (1'b0),
        .byteena_a  (4'b1111),
        .data_a     (32'b0),
        .q_a        (instructionQ101H),
        .address_b  ('0),
        .wren_b     ('0),
        .byteena_b  ('0),
        .data_b     ('0),
        .q_b        () // output
    );

    //==============================================================================
    // Instruction Decode, Read RegFile, Execute (Cycle 101)
    //==============================================================================
    ex_core_decoder decoder (
        .clk        (Clk),
        .instruction(instructionQ101H),
        .opcode     (opcodeQ101H),
        .CtrlAlu    (CtrlAluQ101H),
        .CtrlRf     (CtrlRfQ101H),
        .funct3     (funct3Q101H),
        .funct7     (funct7Q101H),
        .imm        (immQ101H)
    );

    // Register File
    logic RegWrEnQ102H;
    logic [4:0] RegDstQ102H;
    `MAFIA_DFF_RST(RegWrEnQ102H, CtrlRfQ101H.RegWrEn, Clk, Rst)
    `MAFIA_DFF_RST(RegDstQ102H, CtrlRfQ101H.RegDst, Clk, Rst)

    ex_core_rf rf (
        .clk        (Clk),
        .Ctrl       (CtrlRfQ101H),
        .RegWrData  (RegWrDataQ102H),
        .RegWrEn    (RegWrEnQ102H),
        .RegDst     (RegDstQ102H),
        .RegRdData1 (RegRdData1Q101H),
        .RegRdData2 (RegRdData2Q101H)
    );

    // Forwarding Logic to Handle Hazards
    logic [31:0] ForwardedRegRdData1Q101H, ForwardedRegRdData2Q101H;
    assign ForwardedRegRdData1Q101H = (CtrlRfQ101H.RegSrc1 == RegDstQ102H && RegWrEnQ102H) ? RegWrDataQ102H : RegRdData1Q101H;
    assign ForwardedRegRdData2Q101H = (CtrlRfQ101H.RegSrc2 == RegDstQ102H && RegWrEnQ102H) ? RegWrDataQ102H : RegRdData2Q101H;

    // ALU Inputs
    logic [31:0] AluIn1Q101H, AluIn2Q101H;
    assign AluIn1Q101H = ForwardedRegRdData1Q101H;
    assign AluIn2Q101H = (opcodeQ101H == I_OP) ? immQ101H : ForwardedRegRdData2Q101H;

    // ALU
    ex_core_alu alu(
        .operand1   (AluIn1Q101H),
        .operand2   (AluIn2Q101H),
        .Ctrl       (CtrlAluQ101H),
        .result     (AluOutQ101H),
        .zero       (zero)
    );

    //==============================================================================
    // Memory Access and Write Back (Cycle 102)
    //==============================================================================
    `MAFIA_DFF(AluOutQ102H, AluOutQ101H, Clk)
    `MAFIA_DFF(immQ102H, immQ101H, Clk)

    // Data Memory
    mem #(32, 10) d_mem (
        .clock      (Clk),
        .address_a  (AluOutQ101H[9:2]), // 8-bit address space
        .wren_a     (CtrlRfQ101H.RegWrEn),
        .byteena_a  (4'b1111),
        .data_a     (RegRdData1Q101H),
        .q_a        (MemRdDataQ102H),
        .address_b  ('0),
        .wren_b     ('0),
        .byteena_b  ('0),
        .data_b     ('0),
        .q_b        ()
    );

    `MAFIA_DFF(opcodeQ102H, opcodeQ101H, Clk)
    assign RegWrDataQ102H = (opcodeQ102H == LOAD) ? MemRdDataQ102H : AluOutQ102H;

    //==============================================================================
    // Control Signals and Additional Logic
    //==============================================================================
    always_comb begin
        sel_pc = (opcodeQ101H == BRANCH && zero) ? 1'b0 :
                 (opcodeQ101H == JAL)            ? 1'b0 :
                 (opcodeQ101H == JALR)           ? 1'b0 :
                                                   1'b1;
    end

endmodule
