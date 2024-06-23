package mini_ex_core_pkg;

typedef enum logic[3:0]{
    ADD  = 4'b0000 ,
    SUB  = 4'b1000 ,
    SLT  = 4'b0010 ,
    SLTU = 4'b0011 ,
    SLL  = 4'b0001 , 
    SRL  = 4'b0101 ,
    SRA  = 4'b1101 ,
    XOR  = 4'b0100 ,
    OR   = 4'b0110 ,
    AND  = 4'b0111 
} t_alu_op;

typedef struct packed {
    logic  [31:0] RegSrc1Q101H;
    logic  [31:0] RegSrc2Q101H;
    logic [31:0] AluOutQ101H;
    t_alu_op            AluOp;
} t_alu_ctrl;



endpackage