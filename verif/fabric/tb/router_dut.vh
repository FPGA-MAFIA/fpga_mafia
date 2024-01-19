logic in_north_req_valid;
logic in_south_req_valid;
logic in_east_req_valid;
logic in_west_req_valid;
logic in_local_req_valid;

logic        [5:1]input_gen_valid ;// North[1], East[2], South[3], West[4], Local[5]
t_tile_trans [5:1]input_gen       ;// North[1], East[2], South[3], West[4], Local[5]

logic        [5:1]output_gen_valid ;// North[1], East[2], South[3], West[4], Local[5]
t_tile_trans [5:1]output_gen       ;// North[1], East[2], South[3], West[4], Local[5]

t_fab_ready  [5:1]input_gen_ready ;// North[1], East[2], South[3], West[4], Local[5]
t_fab_ready  [5:1]output_gen_ready;// North[1], East[2], South[3], West[4], Local[5]
initial begin : default_values
    input_gen_valid = '0;
    for(int i = 1; i < 6; i = i + 1) begin
        input_gen[i].data                  = '0;
        input_gen[i].address               = '0;
        input_gen[i].opcode                = NULL;
        input_gen[i].requestor_id          = 8'h00;
        input_gen[i].next_tile_fifo_arb_id = NULL_CARDINAL;
        input_gen_ready[i] = 5'b11111;
    end
end

logic [7:0] local_tile_id;
assign local_tile_id = 8'h33;

router router_inst // TODO - a4d logic to outputs. 
(
 .clk                  (clk),     //   input   logic      clk,
 .rst                  (rst),     //   input   logic      rst,
 .local_tile_id        (local_tile_id),   //   input   t_tile_id  local_tile_id,
 //========================================
 // North Interface
 //========================================
 // input request & output ready
 .in_north_req_valid   (input_gen_valid [NORTH]),// input   logic         in_north_req_valid,
 .in_north_req         (input_gen       [NORTH]),// input   t_tile_trans  in_north_req,
 .out_north_ready      (output_gen_ready[NORTH]),// output  t_fab_ready   out_north_ready, // .east_arb, .west_arb, .south_arb
 // output request & input ready
 .out_north_req_valid  (output_gen_valid[NORTH]),// output  logic         out_north_req_valid,
 .out_north_req        (output_gen      [NORTH]),// output  t_tile_trans  out_north_req,
 .in_north_ready       (input_gen_ready [NORTH]),// input   t_fab_ready   in_north_ready, // east_arb, west_arb, north_arb
 //========================================
 // East Interface
 //========================================
 .in_east_req_valid    (input_gen_valid [EAST]),// input logic in_east_req_valid,
 .in_east_req          (input_gen       [EAST]),// input t_tile_trans in_east_req,
 .out_east_ready       (output_gen_ready[EAST]),// output
 // output request & input ready
 .out_east_req_valid   (output_gen_valid[EAST]),// output logic out_east_req_valid,
 .out_east_req         (output_gen      [EAST]),// output t_tile_trans  out_east_req,
 .in_east_ready        (input_gen_ready [EAST]),// input   t_fab_ready   in_east_ready, // east_arb, west_arb, east_arb
 //========================================
 // South Interface
 //========================================
 .in_south_req_valid   (input_gen_valid [SOUTH]),// input logic in_south_req_valid,
 .in_south_req         (input_gen       [SOUTH]),// input logic in_south_req_valid,
 .out_south_ready      (output_gen_ready[SOUTH]),// output
 // output request & input ready
 .out_south_req_valid   (output_gen_valid[SOUTH]),// output logic out_south_req_valid,
 .out_south_req         (output_gen      [SOUTH]),// output t_tile_trans  out_south_req,
 .in_south_ready        (input_gen_ready [SOUTH]),// input   t_fab_ready   in_south_ready, 
 //========================================
 // West Interface
 //========================================
 .in_west_req_valid   (input_gen_valid [WEST]),// input logic in_west_req_valid,
 .in_west_req         (input_gen       [WEST]),// input logic in_west_req_valid,
 .out_west_ready      (output_gen_ready[WEST]),// output
 // output request & input ready
 .out_west_req_valid   (output_gen_valid[WEST]),// output logic out_west_req_valid,
 .out_west_req         (output_gen      [WEST]),// output t_tile_trans  out_west_req,
 .in_west_ready        (input_gen_ready [WEST]),// input   t_fab_ready   in_west_ready, 
 //========================================
 // Local Interface
 //========================================
 .in_local_req_valid   (input_gen_valid [LOCAL]),// input logic in_local_req_valid,
 .in_local_req         (input_gen       [LOCAL]),// input logic in_local_req_valid,
 .out_local_ready      (output_gen_ready[LOCAL]),// output
 // output request & input ready
 .out_local_req_valid   (output_gen_valid[LOCAL]),// output logic out_local_req_valid,
 .out_local_req         (output_gen      [LOCAL]),// output t_tile_trans  out_local_req,
 .in_local_ready        (input_gen_ready [LOCAL])// input   t_fab_ready   in_local_ready, 
);
