logic in_north_req_valid;
logic in_south_req_valid;
logic in_east_req_valid;
logic in_west_req_valid;

t_tile_trans in_north_req;
t_tile_trans input_gen [3:0];


router router_inst // TODO - add logic to outputs. 
(
 .clk                  (clk),         //   input   logic               clk,
 .rst                  (rst),         //   input   logic               rst,
 .local_tile_id        (8'h3_3),     //   input   t_tile_id           local_tile_id,
 //========================================
 // North Interface
 //========================================
 // input request & output ready
 .in_north_req_valid   (in_north_req_valid),//   input   logic               in_north_req_valid,
 .in_north_req         (in_north_req),              //   input   t_tile_trans            in_north_req,
 .out_north_ready      (               ),   //   output  t_fab_ready         out_north_ready, // .east_arb, .west_arb, .south_arb
 // output request & input ready
 .out_north_req_valid  (                   ),//   output  logic               out_north_req_valid,
 .out_north_req        (             ),      //   output  t_tile_trans            out_north_req,
 .in_north_ready       (5'b11111),     //   input   t_fab_ready         in_north_ready, // east_arb, west_arb, north_arb
 //========================================
 // East Interface
 //========================================
 // input request & output ready
 .in_east_req_valid    (in_east_req_valid),  //   input   logic               in_east_req_valid,
 .in_east_req          ('0),        //   input   t_tile_trans            in_east_req,
 .out_east_ready       (              ),     //   output  t_fab_ready         out_east_ready, // .north_arb, .west_arb, .south_arb
 // output request & input ready
 .out_east_req_valid   (                  ), //   output  logic               out_east_req_valid,
 .out_east_req         (            ),       //   output  t_tile_trans            out_east_req,
 .in_east_ready        (5'b11111),      //   input   t_fab_ready         in_east_ready, // north_arb, east_arb, south_arb
 //========================================
 // West Interface
 //========================================
 // input request & output ready
 .in_west_req_valid    (in_west_req_valid),  //   input   logic               in_west_req_valid,
 .in_west_req          ('0),        //   input   t_tile_trans            in_west_req,
 .out_west_ready       (              ),     //   output  t_fab_ready         out_west_ready, // .north_arb, .east_arb, .south_arb
 // output request & input ready
 .out_west_req_valid   (                  ), //   output  logic               out_west_req_valid,
 .out_west_req         (            ),       //   output  t_tile_trans            out_west_req,
 .in_west_ready        (5'b11111),      //   input   t_fab_ready         in_west_ready, // north_arb, west_arb, south_arb
 //========================================
 // South Interface
 //========================================
 // input request & output ready
 .in_south_req_valid   (in_south_req_valid), //   input   logic               in_south_req_valid,
 .in_south_req         ('0),       //   input   t_tile_trans            in_south_req,
 .out_south_ready      (               ),    //   output  t_fab_ready         out_south_ready, // .north_arb, .east_arb, .west_arb
 // output request & input ready
 .out_south_req_valid  (                   ),//   output  logic               out_south_req_valid,
 .out_south_req        (             ),      //   output  t_tile_trans            out_south_req,
 .in_south_ready       (5'b11111)      //   input   t_fab_ready         in_south_ready  // south_arb, east_arb, west_arb
);