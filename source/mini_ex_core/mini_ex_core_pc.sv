`include "macros.vh"

module mini_ex_core_pc
    import mini_ex_core_pkg::*;
(
    input  logic  Clock,
    input  logic  Rst,
    input  logic  JmpEnableQ100H,
    input  logic [31:0]  JmpAddressQ100H,
    output logic [31:0]  PcPlus4Q100H, 
    output logic [31:0]  PcCurrQ100H 
);


always_ff @(posedge Clock) begin
    if(Rst) begin
        PcCurrQ100H <= 0;
        PcPlus4Q100H <= 4;
    end else if(JmpEnableQ100H) begin
        PcPlus4Q100H <= PcCurrQ100H + 4;
        PcCurrQ100H <= JmpAddressQ100H;
    end else begin
        PcCurrQ100H <= PcCurrQ100H + 4;
        PcPlus4Q100H <= PcCurrQ100H + 8;
    end 
end 


endmodule