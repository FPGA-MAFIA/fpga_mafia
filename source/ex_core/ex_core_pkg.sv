package ex_core_pkg;

typedef struct packed {
    logic [4:0] RegSrc1;
    logic [4:0] RegSrc2;
    logic [4:0] RegDst;
    logic       RegWrEn;
} t_ctrl_rf;

endpackage