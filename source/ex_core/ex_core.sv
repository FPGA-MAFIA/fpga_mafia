`include "macros.vh"
`include "../common/mem.sv"

module ex_core
import ex_core_pkg::*;
(
    input logic Clk,
    input logic Rst
);

    // Pipeline registers for instructions and data between stages
    logic [31:0] PcQ100H, NextPcQ101H, instructionQ101H;
    logic [31:0] RegRdData1, RegRdData2, AluOut, MemRdData, RegWrData;
    logic [31:0] immQ102H, instrQ102H;
    t_opcode opcodeQ102H;
    logic [2:0] funct3Q102H;
    logic [6:0] funct7Q102H;
    t_ctrl_alu CtrlAluQ102H;
    t_ctrl_rf CtrlRfQ102H;

    // Control signals
    logic [1:0] sel_pc;
    logic zero;
    logic JMP_OR_BRNCH;

    assign JMP_OR_BRNCH = (opcodeQ102H == J) || (opcodeQ102H == JAL) || (opcodeQ102H == JALR) || (opcodeQ102H == BEQ) || (opcodeQ102H == BNE);

    //==============================================================================
    // Cycle 100 -> the instruction fetch
    //==============================================================================
    // Fetch: Set PC & read instruction from memory
    //==============================================================================
    assign NextPcQ101H = (sel_pc == JMP_OR_BRNCH) ? AluOut : PcQ100H + 32'd4;
    `MAFIA_DFF_RST(PcQ100H, NextPcQ101H, Clk, Rst)

    // Instantiate the instruction memory (I_MEM)
    mem #(32, 8) i_mem (
        .clock(Clk),
        .address_a(PcQ100H[9:2]), // Using bits [9:2] for addressing to match 8-bit address space
        .wren_a(1'b0),
        .byteena_a(4'b1111),
        .data_a(32'b0),
        .q_a(instructionQ101H),
        .address_b(),
        .wren_b(),
        .byteena_b(),
        .data_b(),
        .q_b()
    );

    //==============================================================================
    // Cycle 101 -> the instruction decode + read RegFile + Execute
    //==============================================================================
    // Decode: instruction + read RegFile
    // Execute: perform ALU operation
    // Send MEM read/write signals
    //==============================================================================
    `MAFIA_DFF(instrQ102H, instructionQ101H, Clk)

    ex_core_decoder decoder (
        .clk(Clk),
        .instruction(instrQ102H),
        .opcode(opcodeQ102H),
        .CtrlAlu(CtrlAluQ102H),
        .CtrlRf(CtrlRfQ102H),
        .funct3(funct3Q102H),
        .funct7(funct7Q102H),
        .imm(immQ102H)
    );

    ex_core_rf rf (
        .clk(Clk),
        .Ctrl(CtrlRfQ102H),
        .RegWrData(RegWrData),
        .RegRdData1(RegRdData1),
        .RegRdData2(RegRdData2)
    );

    ex_core_alu alu(
        .operand1(RegRdData1),
        .operand2(RegRdData2),
        .Ctrl(CtrlAluQ102H),
        .result(AluOut),
        .zero(zero)
    );

    //==============================================================================
    // Cycle 102 -> the memory access + write back
    //==============================================================================
    //  WRITE BACK: Mux the result of the ALU operation with the data read from memory + write to RegFile
    //==============================================================================
    logic [31:0] AluOutQ103H, MemRdDataQ103H, immQ103H;
    logic [4:0]  RegDstQ103H;
    logic        RegWrEnQ103H;

    `MAFIA_DFF(AluOutQ103H, AluOut, Clk)
    `MAFIA_DFF(MemRdDataQ103H, MemRdData, Clk)
    `MAFIA_DFF(immQ103H, immQ102H, Clk)
    `MAFIA_DFF(RegDstQ103H, CtrlRfQ102H.RegDst, Clk)
    `MAFIA_DFF(RegWrEnQ103H, CtrlRfQ102H.RegWrEn, Clk)

    // Instantiate the data memory (D_MEM)
    mem #(32, 8) d_mem (
        .clock(Clk),
        .address_a(AluOutQ103H[9:2]), // Using bits [9:2] for addressing to match 8-bit address space
        .wren_a(CtrlRfQ102H.RegWrEn),
        .byteena_a(4'b1111),
        .data_a(RegRdData2),
        .q_a(MemRdData),
        .address_b(),
        .wren_b(),
        .byteena_b(),
        .data_b(),
        .q_b()
    );

    // Write back stage: Mux the result of the ALU operation with the data read from memory + write to RegFile
    assign RegWrData = (opcodeQ102H == LW) ? MemRdDataQ103H : AluOutQ103H;

    //==============================================================================
    // Control Signals and additional logic
    //==============================================================================
    // Determine the source for the next PC value (for branching/jump instructions)
    always_comb begin
        if (opcodeQ102H == BEQ && zero) begin
            sel_pc = JMP_OR_BRNCH;
        end else if (opcodeQ102H == JAL || opcodeQ102H == JALR) begin
            sel_pc = JMP_OR_BRNCH;
        end else begin
            sel_pc = 2'b00; // Default case
        end
    end

endmodule
