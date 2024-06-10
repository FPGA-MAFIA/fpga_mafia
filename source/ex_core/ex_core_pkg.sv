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
} t_ctrl_alu;

typedef struct packed {
    logic [4:0] RegSrc1;
    logic [4:0] RegSrc2;
    logic [4:0] RegDst;
    logic       RegWrEn;
} t_ctrl_rf;

typedef enum logic [6:0] {
   LUI    = 7'b0110111 ,
   AUIPC  = 7'b0010111 ,
   JAL    = 7'b1101111 ,
   JALR   = 7'b1100111 ,
   BRANCH = 7'b1100011 ,
   LOAD   = 7'b0000011 ,
   STORE  = 7'b0100011 ,
   I_OP   = 7'b0010011 ,
   R_OP   = 7'b0110011 ,
   FENCE  = 7'b0001111 ,
   SYSCAL = 7'b1110011
} t_opcode ;

endpackage