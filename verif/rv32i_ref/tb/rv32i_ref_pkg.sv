
package rv32i_ref_pkg;

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


//systemverilog packed struct for debugging
typedef struct packed {
    logic        clk;
    logic [31:0] pc;
    logic [31:0] instruction;
    t_rv32i_instr instr_type;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [31:0] mem_rd_addr;
    logic [31:0] mem_wr_addr;
    logic [31:0] data_rd1;
    logic [31:0] data_rd2;
    logic [31:0] reg_wr_data;
} t_debug_info;

endpackage