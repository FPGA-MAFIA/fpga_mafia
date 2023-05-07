//The mini_core_tile is a module that connects the mini_core & the router + IO to the fabric
module mini_core_tile
import router_pkg::*;
(
    input   logic               clk,
    input   logic               rst,
    input   t_tile_id           local_tile_id,
    //========================================
    // North Interface
    //========================================
    // input request & output ready
    input   logic               in_north_req_valid,
    input   var t_tile_trans    in_north_req,
    output  t_fab_ready         out_north_ready, // .east_arb, .west_arb, .south_arb, .local_arb
    // output request & input ready
    output  logic               out_north_req_valid,
    output  t_tile_trans        out_north_req,
    input   var t_fab_ready     in_north_ready, // east_arb, west_arb, north_arb, local_arb
    //========================================
    // East Interface
    //========================================
    // input request & output ready
    input   logic               in_east_req_valid,
    input   var t_tile_trans    in_east_req,
    output  t_fab_ready         out_east_ready, // .north_arb, .west_arb, .south_arb, .local_arb
    // output request & input ready
    output  logic               out_east_req_valid,
    output  t_tile_trans        out_east_req,
    input   var t_fab_ready     in_east_ready, // north_arb, east_arb, south_arb, local_arb
    //========================================
    // West Interface
    //========================================
    // input request & output ready
    input   logic               in_west_req_valid,
    input   var t_tile_trans    in_west_req,
    output  t_fab_ready         out_west_ready, // .north_arb, .east_arb, .south_arb, .local_arb
    // output request & input ready
    output  logic               out_west_req_valid,
    output  t_tile_trans        out_west_req,
    input   var t_fab_ready     in_west_ready, // north_arb, west_arb, south_arb, local_arb
    //========================================
    // South Interface
    //========================================
    // input request & output ready
    input   logic               in_south_req_valid,
    input   var t_tile_trans    in_south_req,
    output  t_fab_ready         out_south_ready, // .north_arb, .east_arb, .west_arb, .local_arb
    // output request & input ready
    output  logic               out_south_req_valid,
    output  t_tile_trans        out_south_req,
    input   var t_fab_ready     in_south_ready
);


// Will be connected to the local mini core
logic in_local_req_valid  ; 
t_tile_trans in_local_req ; 
t_fab_ready in_local_ready; 

logic out_local_req_valid  ; 
t_tile_trans out_local_req ; 
t_fab_ready out_local_ready; 

router router_inst // TODO - a4d logic to outputs. 
(
 .clk                  (clk),     //   input   logic      clk,
 .rst                  (rst),     //   input   logic      rst,
 .local_tile_id        (local_tile_id),   //   input   t_tile_id  local_tile_id,
 //========================================
 // North Interface
 //========================================
 // input request & output ready
 .in_north_req_valid   (in_north_req_valid),// input   logic         in_north_req_valid,
 .in_north_req         (in_north_req),// input   t_tile_trans  in_north_req,
 .out_north_ready      (out_north_ready),// output  t_fab_ready   out_north_ready, // .east_arb, .west_arb, .south_arb
 // output request & input ready
 .out_north_req_valid  (out_north_req_valid),// output  logic         out_north_req_valid,
 .out_north_req        (out_north_req),// output  t_tile_trans  out_north_req,
 .in_north_ready       (in_north_ready),// input   t_fab_ready   in_north_ready, // east_arb, west_arb, north_arb
 //========================================
 // East Interface
 //========================================
 .in_east_req_valid    (in_east_req_valid),// input logic in_east_req_valid,
 .in_east_req          (in_east_req),// input t_tile_trans in_east_req,
 .out_east_ready       (out_east_ready),// output
 // output request & input ready
 .out_east_req_valid   (out_east_req_valid),// output logic out_east_req_valid,
 .out_east_req         (out_east_req),// output t_tile_trans  out_east_req,
 .in_east_ready        (in_east_ready),// input   t_fab_ready   in_east_ready, // east_arb, west_arb, east_arb
 //========================================
 // South Interface
 //========================================
 .in_south_req_valid   (in_south_req_valid),// input logic in_south_req_valid,
 .in_south_req         (in_south_req),// input logic in_south_req_valid,
 .out_south_ready      (out_south_ready),// output
 // output request & input ready
 .out_south_req_valid   (out_south_req_valid),// output logic out_south_req_valid,
 .out_south_req         (out_south_req),// output t_tile_trans  out_south_req,
 .in_south_ready        (in_south_ready),// input   t_fab_ready   in_south_ready, 
 //========================================
 // West Interface
 //========================================
 .in_west_req_valid   (in_west_req_valid),// input logic in_west_req_valid,
 .in_west_req         (in_west_req),// input logic in_west_req_valid,
 .out_west_ready      (out_west_ready),// output
 // output request & input ready
 .out_west_req_valid   (out_west_req_valid),// output logic out_west_req_valid,
 .out_west_req         (out_west_req),// output t_tile_trans  out_west_req,
 .in_west_ready        (in_west_ready),// input   t_fab_ready   in_west_ready, 
 //========================================
 // Local Interface
 //========================================
 .in_local_req_valid   (in_local_req_valid),// input logic in_local_req_valid,
 .in_local_req         (in_local_req),// input logic in_local_req_valid,
 .out_local_ready      (out_local_ready),// output
 // output request & input ready
 .out_local_req_valid   (out_local_req_valid),// output logic out_local_req_valid,
 .out_local_req         (out_local_req),// output t_tile_trans  out_local_req,
 .in_local_ready        (in_local_ready)// input   t_fab_ready   in_local_ready, 
);


// Temp TODO FIXME - override with xmt for TB
//This is the local mini_core output placeholder (inputs into the router)
assign in_local_req_valid = '0;
assign in_local_req       = '0;
assign in_local_ready     = 4'b1111;


//========================================
// mini core - Local
//========================================
//mini_top mini_top (
//.Clock               (Clk),
//.Rst                 (Rst),
//// //============================================
//// //      fabric interface
//// //============================================


endmodule 