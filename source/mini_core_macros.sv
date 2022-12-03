//-----------------------------------------------------------------------------
// Title            : riscv as-fast-as-possible 
// Project          : rvc_asap
//-----------------------------------------------------------------------------
// File             : rvc_asap_macros.sv
// Original Author  : Amichai Ben-David
// Code Owner       : 
// Created          : 11/2021
//-----------------------------------------------------------------------------
// Description :
// usfule macros for thie RVC_ASAP project.
// Flip-Flops, FindFIrst, Counters etc...
//-----------------------------------------------------------------------------

`ifndef RVC_MINI_CORE_MACROS
`define RVC_MINI_CORE_MACROS

`define  RVC_MSFF(q,i,clk)              \
         always_ff @(posedge clk)       \
            q<=i;

`define  RVC_EN_MSFF(q,i,clk,en)        \
         always_ff @(posedge clk)       \
            if(en) q<=i;

`define  RVC_RST_MSFF(q,i,clk,rst)      \
         always_ff @(posedge clk) begin \
            if (rst) q <='0;            \
            else     q <= i;            \
         end

`define  RVC_EN_RST_MSFF(q,i,clk,en,rst)\
         always_ff @(posedge clk)       \
            if (rst)    q <='0;         \
            else if(en) q <= i;
`endif

