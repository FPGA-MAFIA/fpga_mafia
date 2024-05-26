package ex_core_pkg;

typedef enum logic [3:0] {
    ADD  = 4'b0000,
    SUB  = 4'b0001,
    AND  = 4'b0010,
    OR   = 4'b0011,
    XOR  = 4'b0100,
    SLL  = 4'b0101,
    SRL  = 4'b0110,
    SRA  = 4'b0111,
    SLT  = 4'b1000,
    SLTU = 4'b1001
} t_alu_op;

typedef struct packed {
    logic [4:0] RegSrc1;
    logic [4:0] RegSrc2;
    logic [4:0] RegDst;
    logic       RegWrEn;
} t_ctrl_rf;

endpackage