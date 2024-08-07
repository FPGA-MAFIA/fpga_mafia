
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
    input  logic [31:0] address_b,
    input  logic [31:0] data_b,
    input  logic        wren_b,
    output logic [31:0] q_b
);

t_cr cr;
t_cr next_cr;

// Data-Path signals
logic [31:0] pre_q;
logic [31:0] pre_q_b;

accel_core_xor accel_core_xor (
    .Rst(Rst),
    .x(cr.SEG7_0),
    .y(cr.SEG7_1),
    .out(next_cr.SEG7_2)
);

`MAFIA_DFF(cr, next_cr, Clk)
//==============================
// Memory Access
//------------------------------
// 1. Access CR_MEM for Wrote (STORE) and Reads (LOAD)
//==============================
always_comb begin
    if(Rst) begin 
        next_cr.SEG7_0       = 0;
        next_cr.SEG7_1       = 0;
        // next_cr.SEG7_2    = 0; used by accel core
        next_cr.SEG7_3       = 0;
        next_cr.SEG7_4       = 0;
        next_cr.SEG7_5       = 0;
    end else begin
        next_cr.SEG7_0       = cr.SEG7_0 ;
        next_cr.SEG7_1       = cr.SEG7_1;
        // next_cr.SEG7_2    = cr.SEG7_2 ; used by accel core
        next_cr.SEG7_3       = cr.SEG7_3 ;
        next_cr.SEG7_4       = cr.SEG7_4 ;
        next_cr.SEG7_5       = cr.SEG7_5 ;
    end
    if(wren) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_SEG7_0       : next_cr.SEG7_0       = data[7:0];
            CR_SEG7_1       : next_cr.SEG7_1       = data[7:0];
           // CR_SEG7_2       : next_cr.SEG7_2       = data[7:0]; used by accel core
            CR_SEG7_3       : next_cr.SEG7_3       = data[7:0];
            CR_SEG7_4       : next_cr.SEG7_4       = data[7:0];
            CR_SEG7_5       : next_cr.SEG7_5       = data[7:0];
            // ---- Other ----
            default   : /* Do nothing */;
        endcase
    end

    
end

// This is the load
always_comb begin
    pre_q   = 32'b0;
    pre_q_b = 32'b0;
    if(rden) begin
        unique casez (address) // address holds the offset
            // ---- RW memory ----
            CR_SEG7_0       : pre_q = {24'b0 , cr.SEG7_0}     ; 
            CR_SEG7_1       : pre_q = {24'b0 , cr.SEG7_1}     ;
            CR_SEG7_2       : pre_q = {24'b0 , cr.SEG7_2}     ;
            CR_SEG7_3       : pre_q = {24'b0 , cr.SEG7_3}     ;
            CR_SEG7_4       : pre_q = {24'b0 , cr.SEG7_4}     ;
            CR_SEG7_5       : pre_q = {24'b0 , cr.SEG7_5}     ;
            default        : pre_q = 32'b0                    ;
        endcase
    end
    
    //Fabric Read
    unique casez (address_b) // address holds the offset
        // ---- RW memory ----
        CR_SEG7_0      : pre_q_b = {24'b0 , cr.SEG7_0}   ; 
        CR_SEG7_1      : pre_q_b = {24'b0 , cr.SEG7_1}   ;
        CR_SEG7_2      : pre_q_b = {24'b0 , cr.SEG7_2}   ;
        CR_SEG7_3      : pre_q_b = {24'b0 , cr.SEG7_3}   ;
        CR_SEG7_4      : pre_q_b = {24'b0 , cr.SEG7_4}   ;
        CR_SEG7_5      : pre_q_b = {24'b0 , cr.SEG7_5}   ;
        default        : pre_q_b = 32'b0                    ;
    endcase
end


// Sample the data load - synchorus load
`MAFIA_DFF(q,   pre_q, Clk)
`MAFIA_DFF(q_b, pre_q_b, Clk)

endmodule // Module 