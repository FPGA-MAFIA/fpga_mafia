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

`define  MAFIA_DFF(q,i,clk)              \
         always_ff @(posedge clk)      \
            q<=i;

`define  MAFIA_EN_DFF(q,i,clk,en)        \
         always_ff @(posedge clk)      \
            if(en) q<=i;

`define  MAFIA_RST_DFF(q,i,clk,rst)      \
         always_ff @(posedge clk) begin\
            if (rst) q <='0;           \
            else     q <= i;           \
         end

`define  MAFIA_RST_VAL_DFF(q,i,clk,rst,val)      \
         always_ff @(posedge clk) begin\
            if (rst) q <=val;          \
            else     q <= i;           \
         end


`define  MAFIA_EN_RST_DFF(q,i,clk,en,rst)\
         always_ff @(posedge clk)      \
            if (rst)    q <='0;        \
            else if(en) q <= i;


`define  FIND_FIRST(first , candidates )                    \
    always_comb begin                                       \
        first = '0;                                         \
        for(int i =0; i < $bits(candidates); i++) begin     \
            first[i] = candidates[i] & (!(|first));         \
        end                                                 \
    end                                        


`define  ENCODER(encoded , valid, decoded )             \
	always_comb begin                                   \
        encoded = '0 ;                                 	\
        valid   = |decoded;                             \
        for (int i = 0 ; i <$bits(decoded) ;i++) begin  \
	        if (decoded[i])                             \
    	        encoded = i ;                           \
    	end                                             \
    end 

`define  DECODER(decoded , encoded, valid )  \
    always_comb begin                        \
	    decoded = '0 ;                       \
        if(valid) decoded[encoded] = 1'b1 ;  \
	end 

`define ASSERT(name, expr, en, msg) \
   always @(posedge clk) begin \
      if (en && expr) begin \
         $error($sformatf("%s: %s", name, msg)); \
      end \
   end





`endif //MACROS_VS
