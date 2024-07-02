`include "macros.vh"

module mini_ex_core_pc
    import mini_ex_core_pkg::*;
(
    input  logic  Clock,
    input  logic  Rst,
    input  logic  JmpEnableQ100H,
    input  logic [31:0]  JmpAddressQ100H,
    output logic [31:0]  PcPlus4Q101H, 
    output logic [31:0]  PcCurrQ101H 
);

     logic [31:0]  PcPlus4Q100H; 
     logic [31:0]  PcCurrQ100H; 

always_ff @(posedge Clock) begin
    if(Rst) begin
        PcCurrQ101H <= 0;
        PcPlus4Q101H <= 4;
    end else if(JmpEnableQ100H) begin
        PcPlus4Q101H <= PcCurrQ100H + 4;
        PcCurrQ101H <= JmpAddressQ100H;
    end else begin
        PcCurrQ101H <= PcCurrQ100H + 4;
        PcPlus4Q101H <= PcCurrQ100H + 8;
    end 
end 

always_comb begin
    PcCurrQ100H = PcCurrQ101H;
    PcPlus4Q100H = PcPlus4Q101H;
end

endmodule