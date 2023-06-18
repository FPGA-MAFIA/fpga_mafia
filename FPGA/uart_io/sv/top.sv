`include "lotr_defines.sv"
module top(
        input  logic        CLK_50,
        input  logic [9:0]  SW,
        input  logic [1:0]  BUTTON,
        input  logic [15:0] Arduino_IO,

        input logic         UART_TXD,
        output logic        UART_RXD,
        output logic        INTERRUPT,

        output logic [7:0]  HEX0,
        output logic [7:0]  HEX1,
        output logic [7:0]  HEX2,
        output logic [7:0]  HEX3,
        output logic [7:0]  HEX4,
        output logic [7:0]  HEX5,
        output logic [9:0]  LED,

        output logic [3:0]  RED,
        output logic [3:0]  GREEN,
        output logic [3:0]  BLUE,
        output logic        h_sync,
        output logic        v_sync
    );

import lotr_pkg::*;



logic        C2F_RspValidQ502H   ;  
t_opcode     C2F_RspOpcodeQ502H  ;  
logic [1:0]  C2F_RspThreadIDQ502H;  
logic [31:0] C2F_RspDataQ502H    ;
logic        C2F_RspStall        ;
// C2F_Req
logic        C2F_ReqValidQ500H   ;
t_opcode     C2F_ReqOpcodeQ500H  ;
logic [1:0]  C2F_ReqThreadIDQ500H;
logic [31:0] C2F_ReqAddressQ500H ;
logic [31:0] C2F_ReqDataQ500H    ;

uart_io  uart_io_inst
    (
    .clk                    (CLK_50)               ,//input
    .rstn                   (BUTTON[0])            ,//input
    .core_id                ('0)                   ,//input
    //================================================
    //        Core to Fabric
    //================================================
    // input - Rsp to Core
    .C2F_RspValidQ502H      (C2F_RspValidQ502H)   ,//input
    .C2F_RspOpcodeQ502H     (RD_RSP)  ,//input
    .C2F_RspThreadIDQ502H   ('0)                  ,//input
    .C2F_RspDataQ502H       (C2F_RspDataQ502H)    ,//input
    .C2F_RspStall           ('0)                  ,//input
    // output - Req from Core
    .C2F_ReqValidQ500H      (C2F_ReqValidQ500H)   ,//output
    .C2F_ReqOpcodeQ500H     (C2F_ReqOpcodeQ500H)  ,//output
    .C2F_ReqThreadIDQ500H   (                    ),//output
    .C2F_ReqAddressQ500H    (C2F_ReqAddressQ500H) ,//output
    .C2F_ReqDataQ500H       (C2F_ReqDataQ500H)    ,//output
    // UART RX/TX
    .uart_master_tx         (UART_TXD)      ,
    .uart_master_rx         (UART_RXD)      ,
    .interrupt              (INTERRUPT)
    );


logic [7:0]  NEXT_HEX0;
logic [7:0]  NEXT_HEX1;
logic [7:0]  NEXT_HEX2;
logic [7:0]  NEXT_HEX3;
logic [7:0]  NEXT_HEX4;
logic [7:0]  NEXT_HEX5;
logic [9:0]  NEXT_LED ;
logic [9:0]  SW_CR ;

`LOTR_MSFF(HEX0,  NEXT_HEX0, CLK_50)
`LOTR_MSFF(HEX1,  NEXT_HEX1, CLK_50)
`LOTR_MSFF(HEX2,  NEXT_HEX2, CLK_50)
`LOTR_MSFF(HEX3,  NEXT_HEX3, CLK_50)
`LOTR_MSFF(HEX4,  NEXT_HEX4, CLK_50)
`LOTR_MSFF(HEX5,  NEXT_HEX5, CLK_50)
`LOTR_MSFF(LED,   NEXT_LED,  CLK_50)
`LOTR_MSFF(SW_CR, SW,        CLK_50)

assign RED    = 4'b0000;
assign GREEN  = 4'b0000;
assign BLUE   = 4'b0000;
assign h_sync = 1'b0;
assign v_sync = 1'b0;

always_comb begin : write_block
// default values
    NEXT_HEX0 = HEX0;
    NEXT_HEX1 = HEX1;
    NEXT_HEX2 = HEX2;
    NEXT_HEX3 = HEX3;
    NEXT_HEX4 = HEX4;
    NEXT_HEX5 = HEX5;
    NEXT_LED  = LED ;
    if(C2F_ReqValidQ500H && (C2F_ReqOpcodeQ500H == WR)) begin
        unique case (C2F_ReqAddressQ500H[9:0])
            10'h000:  NEXT_HEX0 = C2F_ReqDataQ500H[7:0];
            10'h001:  NEXT_HEX1 = C2F_ReqDataQ500H[7:0];
            10'h002:  NEXT_HEX2 = C2F_ReqDataQ500H[7:0];
            10'h003:  NEXT_HEX3 = C2F_ReqDataQ500H[7:0];
            10'h004:  NEXT_HEX4 = C2F_ReqDataQ500H[7:0];
            10'h005:  NEXT_HEX5 = C2F_ReqDataQ500H[7:0];
            10'h006:  NEXT_LED  = C2F_ReqDataQ500H[9:0];
                    default:  NEXT_LED  = 10'hFF;
        endcase
    end
end

logic [31:0] read_data;
always_comb begin : read_block
    read_data = '0;
    if(C2F_ReqValidQ500H && (C2F_ReqOpcodeQ500H == RD)) begin
        unique case (C2F_ReqAddressQ500H[9:0])
            10'h000:  read_data = {24'b0, HEX0};
            10'h001:  read_data = {24'b0, HEX1};
            10'h002:  read_data = {24'b0, HEX2};
            10'h003:  read_data = {24'b0, HEX3};
            10'h004:  read_data = {24'b0, HEX4};
            10'h005:  read_data = {24'b0, HEX5};
            10'h006:  read_data = {22'b0, LED};
            10'h007:  read_data = {22'b0, SW_CR};
            default:  read_data  = '0;
        endcase
    end
end

`LOTR_MSFF(C2F_RspDataQ502H,  read_data,                                       CLK_50)
`LOTR_MSFF(C2F_RspValidQ502H, C2F_ReqValidQ500H && (C2F_ReqOpcodeQ500H == RD), CLK_50)


endmodule
