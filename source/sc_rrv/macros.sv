//-----------------------------------------------------------------------------
// Title            : simple core  design
// Project          : single cycle core
//-----------------------------------------------------------------------------
// File             : macros
// Original Author  : Roman Gilgor
// Code Owner       : 
// Created          : 10/2023
//-----------------------------------------------------------------------------
// Description :
// This file will be a macro's file for single cycle core implemenation of the RV32I RISCV
// specification
//-----------------------------------------------------------------------------

`ifndef MACROS_VS
`define MACROS_VS


`define MAFIA_DFF(q, i, clk) \
    always_ff @(posedge clk) \
           q <= i;
     
 
`define MAFIA_EN_DFF(q, i, clk, en) \
    always_ff @(posedge clk)        \
        if(en)                      \
            q <= i;


`define MAFIA_RST_DFF(q, i, clk, rst) \
    always_ff @(posedge clk)          \
        if(rst) q <= 0;              \
        else    q <=  i;
     
     
`define MAFIA_ASYNC_RST_DFF(q, i, clk, rst) \
    always_ff @(posedge clk or posedge rst) \
        if(rst) q <= 0;                    \
        else    q <= i;
 
                        
`endif

 
           