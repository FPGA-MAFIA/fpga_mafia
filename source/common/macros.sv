//-----------------------------------------------------------------------------
// Title            : simple core  design
// Project          : simple_core
//-----------------------------------------------------------------------------
// File             : core
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 9/2022
//-----------------------------------------------------------------------------
// Description :
// This file will be a single cycle core implemenation of the RV32I RISCV specification
// Fetch, Decode, Exe, Mem, Write_Back
//-----------------------------------------------------------------------------

`ifndef MACROS_VS
`define MACROS_VS

`define  RVC_DFF(q,i,clk)              \
         always_ff @(posedge clk)      \
            q<=i;

`define  RVC_EN_DFF(q,i,clk,en)        \
         always_ff @(posedge clk)      \
            if(en) q<=i;

`define  RVC_RST_DFF(q,i,clk,rst)      \
         always_ff @(posedge clk) begin\
            if (rst) q <='0;           \
            else     q <= i;           \
         end

`define  RVC_EN_RST_DFF(q,i,clk,en,rst)\
         always_ff @(posedge clk)      \
            if (rst)    q <='0;        \
            else if(en) q <= i;

`endif //MACROS_VS
