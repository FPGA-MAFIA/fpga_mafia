
`include "macros.vh"

module accel_core_cr_mem 
import accel_core_pkg::*;

(
    input  logic       Clk,
    input  logic       Rst,
    // Core interface
    input  logic [31:0] data,
    input  logic [31:0] address,
    input  logic        wren,
    input  logic        rden,
    output logic [31:0] q,
    // Fabric interface
    //input  logic [31:0] address_b,
    //input  logic [31:0] data_b,
    //input  logic        wren_b,
    //output logic [31:0] q_b,
    // CR for accelerator farm
    input  logic [7:0] xor_result,
    output logic [7:0] xor_inp1,
    output logic [7:0] xor_inp2
);

t_cr cr;
t_cr next_cr;

assign xor_inp1 = cr.xor_inp1;
assign xor_inp2 = cr.xor_inp2;


// Data-Path signals
logic [31:0] pre_q;
//logic [31:0] pre_q_b;



`MAFIA_DFF(cr, next_cr, Clk)
//==============================
// Memory Access
//------------------------------
// 1. Access CR_MEM for Wrote (STORE) and Reads (LOAD)
//==============================
always_comb begin
    if(Rst) begin 
        next_cr = 0;
    end else begin
        next_cr = cr;
        next_cr.xor_result = xor_result;
    end
    if(wren) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_XOR_IN_1       : next_cr.xor_inp1       = data[7:0];//xor inp 1
            CR_XOR_IN_2       : next_cr.xor_inp2       = data[7:0];// xor inp 2
            // ---- Other ----
            default   : /* Do nothing */;
        endcase
    end

    
end

// This is the load
always_comb begin
    pre_q   = 32'b0;
    //pre_q_b = 32'b0;
    if(rden) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_XOR_IN_1       : pre_q = {24'b0 , cr.xor_inp1};
            CR_XOR_IN_2       : pre_q = {24'b0 , cr.xor_inp2};
            CR_XOR_OUT       : pre_q = {24'b0 , cr.xor_result};
            default        : pre_q = 32'b0;
        endcase
    end
    
    //Fabric Read
   // unique casez (address_b) // address holds the offset
        // ---- RW memory ----
      //  CR_0       : pre_q_b = {24'b0 , cr.xor_inp1};
      //  CR_1       : pre_q_b = {24'b0 , cr.xor_inp2};
       // CR_2       : pre_q_b = {24'b0 , cr.xor_result};
      //  default        : pre_q_b = 32'b0;
   // endcase
end


// Sample the data load - synchorus load
`MAFIA_DFF(q,   pre_q, Clk)
//`MAFIA_DFF(q_b, pre_q_b, Clk)

endmodule