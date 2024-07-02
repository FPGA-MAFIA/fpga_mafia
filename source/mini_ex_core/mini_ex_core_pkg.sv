package mini_ex_core_pkg;

parameter int DATA_WIDTH = 32;

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







typedef enum logic[6:0]{
    I_TYPE1  = 7'b0010011,
    I_TYPE2  = 7'b0000011,
    I_TYPE3  = 7'b1100111,
    R_TYPE  = 7'b0110011,
    B_TYPE  = 7'b1100011,
    S_TYPE =  7'b0100011,
    J_TYPE  = 7'b1101111, 
    //U_TYPE  = 6 no need U type
} t_op_type;


typedef struct packed {
    logic [DATA_WIDTH - 1 : 0] RegSrc1Q101H;
    logic [DATA_WIDTH - 1 : 0] RegSrc2Q101H;
    t_alu_op     AluOp;
} t_alu_in;

typedef struct packed {
    logic [4:0]                DstRegQ100H;
    logic                      WriteEnableQ100H;
    logic [DATA_WIDTH - 1 : 0] WriteValueQ100H;
} t_rg_write;

typedef struct packed {
    logic [4:0]                ReadReg1Q100H;
    logic [4:0]                ReadReg2Q100H;
} t_rg_read;

typedef struct packed {
    logic [DATA_WIDTH - 1 : 0] Reg1Val;
    logic [DATA_WIDTH - 1 : 0] Reg2Val;
} t_rg_val;

//typedef struct packed {
    logic [6:0] opcode;
    logic [4:0] rd_idx;
    logic [2:0] func3;
    logic  [4:0] rs1_idx;
    logic  [4:0] rs2_idx;
    logic [6:0] func7;
    logic  [11:0] immItype;
    logic  [4:0] immStype5;
    logic  [6:0] immStype7;
    logic  [19:0] immUtype;
} t_instr_fields;

typedef struct packed {
    logic       JmpEnableQ100H,
    logic       RegWrEnableQ101H,
    logic       AluMux1SelQ101H,
    logic       AluMux2SelQ101H,
    logic [1:0] WbMuxSelQ102H
} t_contoller_out;

endpackage
