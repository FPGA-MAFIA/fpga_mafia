
`define MAFIA_DFF(q, i, clk)        \
    always_ff@(posedge clk) begin   \
        q <= i;                     \
    end

    
`define MAFIA_DFF_RST(q, i, clk, rst)   \
    always_ff@(posedge clk)   begin     \
        if(rst) q <= '0;                \
        else    q <= i;                 \
    end

`define MAFIA_EN_DFF(q, i, clk,  en)  \
    always_ff@(posedge clk)  begin   \
        if(en)   q <= i;             \
    end