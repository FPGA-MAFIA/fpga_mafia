package ex_core_pkg;

typedef enum logic [5:0] {
    ADD  = 6'b100000,
    SUB  = 6'b100010,
    AND  = 6'b100100,
    OR   = 6'b100101,
    XOR  = 6'b100110,
    SLL  = 6'b000000,
    SRL  = 6'b000010,
    SRA  = 6'b000011,
    SLT  = 6'b101010,
    SLTU = 6'b101011
} t_alu_op;

typedef struct packed {
    t_alu_op AluOp;
    logic [4:0] RegSrc1;
    logic [4:0] RegSrc2;
    logic [4:0] RegDst;
    logic       RegWrEn;
} t_ctrl_alu;

typedef struct packed {
    logic [4:0] RegSrc1;
    logic [4:0] RegSrc2;
    logic [4:0] RegDst;
    logic       RegWrEn;
} t_ctrl_rf;

typedef enum logic [5:0] {
    R_TYPE = 6'b000000,  // R-type instructions
    J      = 6'b000010,  // Jump
    JAL    = 6'b000011,  // Jump and Link
    JALR   = 6'b110011,  // Jump and Link Register
    BEQ    = 6'b000100,  // Branch if Equal
    BNE    = 6'b000101,  // Branch if Not Equal
    ADDI   = 6'b001000,  // Add Immediate
    ANDI   = 6'b001100,  // AND Immediate
    ORI    = 6'b001101,  // OR Immediate
    XORI   = 6'b001110,  // XOR Immediate
    SLTI   = 6'b001010,  // Set on Less Than Immediate
    SLTIU  = 6'b001011,  // Set on Less Than Immediate Unsigned
    LW     = 6'b100011,  // Load Word
    SW     = 6'b101011   // Store Word
} t_opcode;


endpackage