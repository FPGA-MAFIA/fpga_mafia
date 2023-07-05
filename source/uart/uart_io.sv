`timescale 1ns/1ns

`include "uart_defines.v"
`include "macros.sv"

module uart_io
  import common_pkg::*;
  (
   input  logic            clk,
   input  logic            rstn,
   input  logic [7:0]   core_id,
   //RC <---> Core C2F
   // Request
   output logic         InFabricReqValidQ500H      ,
   output logic         InFabricReqOpcodeQ500H     , //1 for write, 0 for read
   output logic  [31:0] InFabricReqAddressQ500H    ,
   output logic  [31:0] InFabricReqDataQ500H       ,
   // Response
   input  logic         OutFabricRspValidQ502H      ,
   input  logic  [31:0] OutFabricRspDataQ502H       ,
   input  logic         OutFabricRspStall           ,
   // uart RX/TX signals
   input   logic        uart_master_tx, 
   output  logic        uart_master_rx,
   output  logic        interrupt
   );
   
  logic uart_interrupt;
  logic write_resp_valid;
  logic read_resp_valid;
  logic write_transfer_valid;
  logic read_transfer_valid;

  t_tile_opcode      OutFabricRspOpcodeQ502H;
  assign OutFabricRspOpcodeQ502H   = RD_RSP;
  assign interrupt               = uart_interrupt;
  assign InFabricReqValidQ500H    = (write_transfer_valid | read_transfer_valid);
  assign InFabricReqOpcodeQ500H   = ((write_transfer_valid) ? 1'b1 : 1'b0);
  assign write_resp_valid     = (OutFabricRspValidQ502H & (OutFabricRspOpcodeQ502H==WR));
  assign read_resp_valid      = (OutFabricRspValidQ502H & (OutFabricRspOpcodeQ502H==RD_RSP));

   // wishbone interface
   wishbone 
     #(
       .ADDR_W   (`UART_ADDR_WIDTH),
       .DATA_W   (`UART_DATA_WIDTH),
       .SELECT_W (4)
       ) wb_if();
   
   // UART wrapper inst
   uart_wrapper
     uart_wrapper_inst
       (
        .clk            (clk),
        .rstn           (rstn),
        .wb_slave       (wb_if),
        .uart_master_tx (uart_master_tx),
        .uart_master_rx (uart_master_rx),
        .interrupt      (uart_interrupt)
        );
   
   // Gateway
   gateway
     gateway_inst
       (
        .wb_master            (wb_if),
        .clk                  (clk),
        .rstn                 (rstn),
        .interrupt            (uart_interrupt),
        .address              (InFabricReqAddressQ500H),
        .data_out             (InFabricReqDataQ500H),
        .data_in              (OutFabricRspDataQ502H),
        .write_transfer_valid (write_transfer_valid), // once address and data are ready, pulse for one cycle.
        .write_resp_valid     (write_resp_valid),     // is pulsed to indicate write_data is valid from RC.
        .read_transfer_valid  (read_transfer_valid),  // once address and data are ready, pulse for one cycle.
        .read_resp_valid      (read_resp_valid)      // is pulsed to indicate read_data is valid from RC.
        );

endmodule // uart_io