// macros file
`ifndef CPUC_MACROS
`define CPUC_MACROS

`define CPUC_DFF(q, i, clk)         \
    always_ff @(posedge clk) begin  \
            q <= i;                 \
    end

`define CPUC_RST_DFF(q, i, rst, clk)       \
    always_ff @(posedge clk) begin  \
        if(rst)                     \
            q <= '0;                \
        else                        \
            q <= i;                 \
    end

`endif
